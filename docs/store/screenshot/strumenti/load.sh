A=~/Library/Android/sdk/platform-tools/adb; S=$(cd "$(dirname "$0")" && pwd)
$A shell am force-stop eu.facilecards.app
$A push $S/db_$1.sqlite /data/local/tmp/fc.sqlite >/dev/null
$A shell "run-as eu.facilecards.app mkdir -p app_flutter"
$A shell "run-as eu.facilecards.app rm -f app_flutter/facilecards.sqlite app_flutter/facilecards.sqlite-wal app_flutter/facilecards.sqlite-shm app_flutter/facilecards.sqlite-journal"
$A shell "run-as eu.facilecards.app cp /data/local/tmp/fc.sqlite app_flutter/facilecards.sqlite"
$A shell monkey -p eu.facilecards.app -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
sleep 6
