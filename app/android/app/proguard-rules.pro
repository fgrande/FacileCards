# Regole per la compressione del codice nella versione release (R8).
#
# La libreria degli annunci (google_mobile_ads) usa WorkManager, che apre un
# database Room creato per riflessione all'avvio dell'app. R8 toglieva la
# classe generata (WorkDatabase_Impl) e l'app si chiudeva appena aperta
# (versione 1.0.0+1, 24 nov 2026). Si conservano i database Room e il loro
# costruttore.
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
