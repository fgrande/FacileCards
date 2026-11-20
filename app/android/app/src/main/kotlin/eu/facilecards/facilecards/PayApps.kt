package eu.facilecards.facilecards

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.nfc.cardemulation.HostApduService
import android.nfc.cardemulation.OffHostApduService
import org.xmlpull.v1.XmlPullParser
import java.io.ByteArrayOutputStream

/**
 * App per pagare da aprire dalla tessera (decisione 118). Si cercano solo app
 * per pagare: quelle di [KNOWN], se installate, e quelle che si dichiarano
 * capaci di pagare avvicinando il telefono al POS (NFC). FacileCards non
 * vede le altre app del telefono: in AndroidManifest.xml il blocco <queries>
 * elenca solo questi pacchetti e le due azioni NFC.
 */
object PayApps {
    /** Pacchetti noti, nell'ordine in cui si propongono. Gli stessi nomi
     *  stanno nel blocco <queries> di AndroidManifest.xml. */
    val KNOWN = listOf(
        "com.satispay.customer",                    // Satispay
        "com.google.android.apps.walletnfcrel",     // Google Wallet
        "com.samsung.android.spay",                 // Samsung Wallet
        "com.paypal.android.p2pmobile",             // PayPal
        "posteitaliane.posteapp.apppostepay",       // Postepay
        "com.revolut.revolut",                      // Revolut
        "it.hype.app",                              // Hype
        "de.number26.android",                      // N26
        "com.imaginecurve.curve.prd",               // Curve
        "com.latuabancaperandroid",                 // Intesa Sanpaolo
        "com.fineco.it",                            // Fineco
    )

    private const val ANDROID_NS = "http://schemas.android.com/apk/res/android"

    /** Le app per pagare installate: [{package, label, icon}]. */
    fun find(context: Context): List<Map<String, Any>> {
        val packages = LinkedHashSet<String>()
        KNOWN.forEach { if (launchable(context, it)) packages.add(it) }
        val nfc = nfcPaymentPackages(context)
            .filter { it != context.packageName && it !in packages && launchable(context, it) }
            .sortedBy { label(context, it)?.lowercase() ?: it }
        packages.addAll(nfc)
        return packages.mapNotNull { info(context, it) }
    }

    /** Nome e icona di un'app installata, o null se non c'è (più). */
    fun info(context: Context, pkg: String): Map<String, Any>? {
        if (!launchable(context, pkg)) return null
        val label = label(context, pkg) ?: return null
        return mapOf("package" to pkg, "label" to label, "icon" to icon(context, pkg))
    }

    /** Apre l'app; false se non c'è più. */
    fun open(context: Context, pkg: String): Boolean {
        val intent = context.packageManager.getLaunchIntentForPackage(pkg) ?: return false
        context.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        return true
    }

    private fun launchable(context: Context, pkg: String) =
        context.packageManager.getLaunchIntentForPackage(pkg) != null

    private fun label(context: Context, pkg: String): String? = try {
        val pm = context.packageManager
        pm.getApplicationLabel(pm.getApplicationInfo(pkg, 0)).toString()
    } catch (e: PackageManager.NameNotFoundException) {
        null
    }

    private fun icon(context: Context, pkg: String): ByteArray {
        val drawable = context.packageManager.getApplicationIcon(pkg)
        val size = 96
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        drawable.setBounds(0, 0, size, size)
        drawable.draw(Canvas(bitmap))
        val out = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
        return out.toByteArray()
    }

    /** App con un servizio NFC di categoria "payment" (pagamento al POS). */
    private fun nfcPaymentPackages(context: Context): Set<String> {
        val pm = context.packageManager
        val found = HashSet<String>()
        val kinds = listOf(
            HostApduService.SERVICE_INTERFACE to HostApduService.SERVICE_META_DATA,
            OffHostApduService.SERVICE_INTERFACE to OffHostApduService.SERVICE_META_DATA,
        )
        for ((action, metaData) in kinds) {
            val services = pm.queryIntentServices(Intent(action), PackageManager.GET_META_DATA)
            for (resolve in services) {
                val service = resolve.serviceInfo ?: continue
                try {
                    service.loadXmlMetaData(pm, metaData)?.use { parser ->
                        var event = parser.eventType
                        while (event != XmlPullParser.END_DOCUMENT) {
                            if (event == XmlPullParser.START_TAG && parser.name == "aid-group" &&
                                parser.getAttributeValue(ANDROID_NS, "category") == "payment"
                            ) {
                                found.add(service.packageName)
                                break
                            }
                            event = parser.next()
                        }
                    }
                } catch (e: Exception) {
                    // Un'app con una dichiarazione illeggibile si salta.
                }
            }
        }
        return found
    }
}
