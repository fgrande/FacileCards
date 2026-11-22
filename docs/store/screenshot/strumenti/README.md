# Screenshot dello store

Come si rifanno gli screenshot di `../it`, `../en`, `../fr` (1080×1920, 9:16 come chiede Google Play).

1. App in modalità screenshot (niente annunci, niente scritta DEBUG):
   `flutter build apk --debug --dart-define=SCREENSHOTS=true`, installata sull'emulatore.
2. Emulatore a 1080×1920: `adb shell wm size 1080x1920`; barra di stato pulita con la modalità demo di Android (ora 9:41, batteria piena).
3. Database di esempio, solo negozi inventati e codici finti: `python3 make_db.py it db_it.sqlite` (e `en`, `fr`).
4. `sh run.sh it "Per sezione" "Dati"`, `sh run.sh en "By section" "Data"`, `sh run.sh fr "Par section" "Données"`.
5. Alla fine: `adb shell wm size reset` e chiudere l'emulatore.

Nessun marchio vero nelle immagini dello store (Google può contestarli) e mai codici di tessere reali.
