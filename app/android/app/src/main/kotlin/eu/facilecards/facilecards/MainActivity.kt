package eu.facilecards.facilecards

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.DocumentsContract
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    // "Salva in…" in corso: file da copiare e risposta da dare a Flutter.
    private var pendingSave: Pair<File, MethodChannel.Result>? = null
    // "Importa tutto" in corso: dove copiare il file scelto e risposta.
    private var pendingOpen: Pair<File, MethodChannel.Result>? = null

    // "Apri con FacileCards" (tappa 3): file ricevuto da un'altra app, copiato
    // nella cache e tenuto qui finché Flutter non lo chiede ("takeIncomingFile").
    private var channel: MethodChannel? = null
    private var incomingToken = 0
    private var incomingCopying = false
    private var incomingPath: String? = null
    private var incomingError: String? = null
    private var waitingTake: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Solo al primo avvio dell'attività, non quando Android la ricrea.
        if (savedInstanceState == null) {
            File(cacheDir, "incoming").deleteRecursively()
            receive(intent)
        }
    }

    // App già aperta (launchMode singleTask): il file arriva qui.
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (receive(intent)) channel?.invokeMethod("incomingFile", null)
    }

    /// Copia il file di un'intenzione VIEW; il permesso di lettura dura poco.
    private fun receive(intent: Intent?): Boolean {
        if (intent?.action != Intent.ACTION_VIEW) return false
        val uri = intent.data ?: return false
        val token = ++incomingToken
        incomingCopying = true
        incomingPath = null
        incomingError = null
        val dir = File(cacheDir, "incoming").apply { mkdirs() }
        val target = File(dir, "ricevuto-${System.currentTimeMillis()}.facilecards")
        Thread {
            val error = try {
                copyLimited(uri, target)
                null
            } catch (e: TooBigException) {
                "too_big"
            } catch (e: Exception) {
                "read_failed"
            }
            runOnUiThread {
                if (token != incomingToken) {
                    target.delete()
                    return@runOnUiThread
                }
                incomingCopying = false
                if (error == null) incomingPath = target.path else incomingError = error
                waitingTake?.let {
                    waitingTake = null
                    deliverIncoming(it)
                }
            }
        }.start()
        return true
    }

    private fun deliverIncoming(result: MethodChannel.Result) {
        val path = incomingPath
        val error = incomingError
        incomingPath = null
        incomingError = null
        result.success(
            when {
                path != null -> mapOf("path" to path)
                error != null -> mapOf("error" to error)
                else -> null
            },
        )
    }

    /// Copia [uri] in [target] con un tetto alla dimensione (il file viene da fuori).
    private fun copyLimited(uri: Uri, target: File) {
        try {
            contentResolver.openInputStream(uri)!!.use { input ->
                target.outputStream().use { out ->
                    val buffer = ByteArray(64 * 1024)
                    var total = 0L
                    while (true) {
                        val n = input.read(buffer)
                        if (n < 0) break
                        total += n
                        if (total > MAX_OPEN_BYTES) throw TooBigException()
                        out.write(buffer, 0, n)
                    }
                }
            }
        } catch (e: Exception) {
            target.delete()
            throw e
        }
    }

    private class TooBigException : Exception()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Piccole funzioni di sistema senza plugin (vedi lib/system_settings.dart).
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "facilecards/system")
        channel = ch
        ch.setMethodCallHandler { call, result ->
                when (call.method) {
                    // File ricevuto con "Apri con FacileCards": {path} o {error},
                    // null se non c'è; se la copia è in corso si risponde alla fine.
                    "takeIncomingFile" -> {
                        if (incomingCopying) {
                            waitingTake?.success(null)
                            waitingTake = result
                        } else {
                            deliverIncoming(result)
                        }
                    }
                    // Pagina dell'app nelle impostazioni di Android (videata 24,
                    // permesso della fotocamera negato).
                    "openAppSettings" -> {
                        val intent = Intent(
                            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                            Uri.fromParts("package", packageName, null),
                        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(null)
                    }
                    // Apre un indirizzo web o di posta con l'app predefinita.
                    "openUrl" -> {
                        val uri = Uri.parse(call.argument<String>("url"))
                        val action = if (uri.scheme == "mailto") Intent.ACTION_SENDTO else Intent.ACTION_VIEW
                        try {
                            startActivity(Intent(action, uri).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                            result.success(true)
                        } catch (e: ActivityNotFoundException) {
                            result.success(false)
                        }
                    }
                    // Versione dell'app (versionName), per la videata Informazioni.
                    "appVersion" -> {
                        val info = packageManager.getPackageInfo(packageName, 0)
                        result.success(info.versionName)
                    }
                    // "Salva sul telefono" (decisione 112): selettore di Android,
                    // aperto dove si è salvato l'ultima volta; restituisce l'indirizzo
                    // del documento creato, o null se si annulla.
                    "saveDocument" -> {
                        val file = File(call.argument<String>("path")!!)
                        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT)
                            .addCategory(Intent.CATEGORY_OPENABLE)
                            .setType("application/octet-stream")
                            .putExtra(Intent.EXTRA_TITLE, call.argument<String>("name"))
                        val initial = call.argument<String>("initialUri")
                        if (initial != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, Uri.parse(initial))
                        }
                        pendingSave?.second?.success(null)
                        pendingSave = Pair(file, result)
                        try {
                            startActivityForResult(intent, SAVE_REQUEST)
                        } catch (e: ActivityNotFoundException) {
                            pendingSave = null
                            result.success(null)
                        }
                    }
                    // "Importa tutto": selettore di Android per scegliere un file;
                    // il file si copia in [path] e si restituisce true (false se
                    // si annulla).
                    "openDocument" -> {
                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT)
                            .addCategory(Intent.CATEGORY_OPENABLE)
                            .setType("*/*")
                        val initialOpen = call.argument<String>("initialUri")
                        if (initialOpen != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, Uri.parse(initialOpen))
                        }
                        pendingOpen?.second?.success(false)
                        pendingOpen = Pair(File(call.argument<String>("path")!!), result)
                        try {
                            startActivityForResult(intent, OPEN_REQUEST)
                        } catch (e: ActivityNotFoundException) {
                            pendingOpen = null
                            result.success(false)
                        }
                    }
                    // "Condividi…": pannello di condivisione di Android con il file.
                    "shareFile" -> {
                        val file = File(call.argument<String>("path")!!)
                        val uri = FileProvider.getUriForFile(this, "$packageName.files", file)
                        val send = Intent(Intent.ACTION_SEND)
                            .setType("application/octet-stream")
                            .putExtra(Intent.EXTRA_STREAM, uri)
                            .putExtra(Intent.EXTRA_TEXT, call.argument<String>("text"))
                            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        startActivity(Intent.createChooser(send, call.argument<String>("title")))
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    @Deprecated("Basta per un solo selettore; l'API nuova richiede una ComponentActivity")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == OPEN_REQUEST) {
            onOpenResult(resultCode, data)
            return
        }
        if (requestCode != SAVE_REQUEST) return
        val (file, result) = pendingSave ?: return
        pendingSave = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }
        // La copia può durare qualche istante: fuori dal thread dell'interfaccia.
        Thread {
            val ok = try {
                contentResolver.openOutputStream(uri, "wt")!!.use { out ->
                    file.inputStream().use { it.copyTo(out) }
                }
                true
            } catch (e: Exception) {
                false
            }
            runOnUiThread {
                if (ok) result.success(uri.toString())
                else result.error("write_failed", "Impossibile scrivere il file", null)
            }
        }.start()
    }

    private fun onOpenResult(resultCode: Int, data: Intent?) {
        val (target, result) = pendingOpen ?: return
        pendingOpen = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(false)
            return
        }
        Thread {
            // Il file viene da fuori: si copia con un tetto alla dimensione.
            val ok = try {
                copyLimited(uri, target)
                true
            } catch (e: Exception) {
                false
            }
            runOnUiThread {
                if (ok) result.success(true)
                else result.error("read_failed", "Impossibile leggere il file", null)
            }
        }.start()
    }

    companion object {
        private const val SAVE_REQUEST = 4201
        private const val OPEN_REQUEST = 4202
        // Come maxArchiveBytes in lib/transfer/archive_format.dart.
        private const val MAX_OPEN_BYTES = 300L * 1024 * 1024
    }
}
