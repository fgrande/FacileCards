package eu.facilecards.facilecards

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.BitmapFactory
import android.graphics.drawable.Icon
import android.os.Build

/// Scorciatoie in Home (decisioni 89 e 90, videate 16, 19, 20): icone fissate
/// sulla schermata Home che aprono una tessera. Si usa lo ShortcutManager di
/// Android (dalla 8.0); su Android 7 la funzione non c'è. Nessun plugin.
object Shortcuts {
    /// Azione dell'intenzione che apre la tessera (non è una VIEW: quelle
    /// sono i file di "Apri con FacileCards").
    const val ACTION_OPEN_CARD = "eu.facilecards.action.OPEN_CARD"
    const val EXTRA_CARD_ID = "cardId"
    const val EXTRA_CARD_NAME = "cardName"

    /// Avviso che Android manda quando l'icona è stata aggiunta.
    const val ACTION_PINNED = "eu.facilecards.action.SHORTCUT_PINNED"

    private fun manager(context: Context): ShortcutManager? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.getSystemService(ShortcutManager::class.java)
        } else {
            null
        }

    private fun shortcutId(cardId: String) = "card-$cardId"

    /// Il telefono (e il launcher) accetta icone fissate dalle app.
    fun canPin(context: Context): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            manager(context)?.isRequestPinShortcutSupported == true

    private fun build(context: Context, cardId: String, name: String, png: ByteArray): ShortcutInfo? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return null
        val bitmap = BitmapFactory.decodeByteArray(png, 0, png.size) ?: return null
        val intent = Intent(context, MainActivity::class.java)
            .setAction(ACTION_OPEN_CARD)
            .putExtra(EXTRA_CARD_ID, cardId)
            .putExtra(EXTRA_CARD_NAME, name)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        return ShortcutInfo.Builder(context, shortcutId(cardId))
            .setShortLabel(name)
            .setLongLabel(name)
            .setIcon(Icon.createWithAdaptiveBitmap(bitmap))
            .setIntent(intent)
            .build()
    }

    /// Chiede ad Android di fissare l'icona: compare la sua finestra di
    /// conferma; quando l'icona è aggiunta arriva [ACTION_PINNED].
    fun pin(context: Context, cardId: String, name: String, png: ByteArray): Boolean {
        val m = manager(context) ?: return false
        if (!canPin(context)) return false
        val info = build(context, cardId, name, png) ?: return false
        // Se era stata disattivata ("Elimina scorciatoia") e la tessera è
        // tornata, la si riattiva: Android rifiuta di fissare un'icona spenta.
        m.enableShortcuts(listOf(info.id))
        val pinned = PendingIntent.getBroadcast(
            context,
            0,
            Intent(ACTION_PINNED).setPackage(context.packageName),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        return try {
            m.requestPinShortcut(info, pinned.intentSender)
        } catch (e: IllegalArgumentException) {
            false
        } catch (e: IllegalStateException) {
            // L'app non è in primo piano.
            false
        }
    }

    /// Aggiorna nome e icona, se l'icona è sulla Home (tessera modificata).
    fun update(context: Context, cardId: String, name: String, png: ByteArray) {
        val m = manager(context) ?: return
        val id = shortcutId(cardId)
        if (m.pinnedShortcuts.none { it.id == id && it.isEnabled }) return
        val info = build(context, cardId, name, png) ?: return
        m.updateShortcuts(listOf(info))
    }

    /// "Elimina scorciatoia": Android non lascia togliere l'icona (B3), la si
    /// può solo spegnere; toccandola si legge [message].
    fun disable(context: Context, cardId: String, message: String) {
        val m = manager(context) ?: return
        m.disableShortcuts(listOf(shortcutId(cardId)), message)
    }
}
