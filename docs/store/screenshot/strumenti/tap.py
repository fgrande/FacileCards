# uso: tap.py "testo"  -> tocca il primo elemento il cui testo/descrizione inizia così
import subprocess, re, sys, os
A=os.path.expanduser('~/Library/Android/sdk/platform-tools/adb')
subprocess.run([A,'shell','uiautomator','dump','/sdcard/u.xml'],capture_output=True)
x=subprocess.run([A,'shell','cat','/sdcard/u.xml'],capture_output=True,text=True).stdout
want=sys.argv[1]
for m in re.finditer(r'<node [^>]*?text="([^"]*)"[^>]*?content-desc="([^"]*)"[^>]*?bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"',x):
    t=(m.group(1) or m.group(2)).replace('&#10;','\n')
    if t.startswith(want) or ('\n'+want) in t:
        cx=(int(m.group(3))+int(m.group(5)))//2; cy=(int(m.group(4))+int(m.group(6)))//2
        subprocess.run([A,'shell','input','tap',str(cx),str(cy)]); print('tap',want,cx,cy); sys.exit(0)
print('NON TROVATO',want); sys.exit(1)
