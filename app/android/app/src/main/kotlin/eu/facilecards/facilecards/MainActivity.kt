package eu.facilecards.facilecards

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Piccole funzioni di sistema senza plugin (vedi lib/system_settings.dart).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "facilecards/system")
            .setMethodCallHandler { call, result ->
                when (call.method) {
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
                    else -> result.notImplemented()
                }
            }
    }
}
