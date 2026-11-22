# uso: run.sh lingua "Per sezione" "Dati"
A=~/Library/Android/sdk/platform-tools/adb; S=$(cd "$(dirname "$0")" && pwd)
L=$1; mkdir -p $S/../$L
shot(){ sleep 2; $A exec-out screencap -p > $S/../$L/$1.png; }
sh $S/load.sh $L
shot 1-elenco
python3 $S/tap.py "Supermercato Sole" >/dev/null; shot 2-tessera; $A shell input keyevent 4; sleep 1
python3 $S/tap.py "$2" >/dev/null; shot 3-sezioni
$A shell input tap 890 137; shot 4-scadenze; $A shell input keyevent 4; sleep 1
$A shell input tap 1017 137; sleep 1; python3 $S/tap.py "$3" >/dev/null; shot 5-dati; $A shell input keyevent 4; sleep 1
# tema scuro: stessa tessera
sqlite3 $S/db_$L.sqlite "update settings set value='dark' where key='theme'"
sh $S/load.sh $L; python3 $S/tap.py "Palestra" >/dev/null; shot 6-tessera-scura
sqlite3 $S/db_$L.sqlite "update settings set value='light' where key='theme'"
