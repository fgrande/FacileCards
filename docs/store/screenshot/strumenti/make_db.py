# Database di esempio per gli screenshot dello store: negozi inventati e
# codici finti (nessun marchio vero, nessun codice di tessere reali).
import sqlite3, sys, time, uuid, os
lang, out = sys.argv[1], sys.argv[2]
schema = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../../app/test/fixtures/schema_v1.sql')).read()
if os.path.exists(out): os.remove(out)
db = sqlite3.connect(out); db.executescript(schema)
def ean(d):  # cifra di controllo EAN
    s = sum(int(c)*(3 if i % 2 == (len(d) % 2 == 0) else 1) for i, c in enumerate(d))
    s = sum(int(c)*(3 if (len(d)-i) % 2 == 1 else 1) for i, c in enumerate(d))
    return d + str((10 - s % 10) % 10)
T = {
 'it': dict(gen='Generale', fam='Famiglia', sport='Sport', lib='Biblioteca civica', gym='Palestra Centro', pool='Piscina comunale', holder='Mario Rossi', note='Sconto del 10% il martedì'),
 'en': dict(gen='General', fam='Family', sport='Sport', lib='City library', gym='Fitness Centre', pool='Swimming pool', holder='Mario Rossi', note='10% off on Tuesdays'),
 'fr': dict(gen='Général', fam='Famille', sport='Sport', lib='Bibliothèque municipale', gym='Salle de sport', pool='Piscine municipale', holder='Mario Rossi', note='10 % de remise le mardi'),
}[lang]
now = int(time.time()); day = 86400
sec = {k: str(uuid.uuid4()) for k in ('gen', 'fam', 'sport')}
db.execute("INSERT INTO sections (id,name,is_default,hidden,sort_order) VALUES (?,?,1,0,0)", (sec['gen'], T['gen'])) if 'sort_order' in schema else None
cols = [r[1] for r in db.execute("PRAGMA table_info(sections)")]
db.execute("DELETE FROM sections")
for i, k in enumerate(('gen', 'fam', 'sport')):
    row = {'id': sec[k], 'name': T[k], 'is_default': 1 if k == 'gen' else 0, 'hidden': 0}
    if 'position' in cols: row['position'] = i
    if 'sort_order' in cols: row['sort_order'] = i
    db.execute(f"INSERT INTO sections ({','.join(row)}) VALUES ({','.join('?'*len(row))})", list(row.values()))
# Negozi inventati, con un colore ciascuno.
shops = [('demo-sole', 'Supermercato Sole', 0xFFF57C00), ('demo-pagina', 'Libreria Pagina', 0xFF6A3FB5),
         ('demo-verde', 'Farmacia Verde', 0xFF2E7D32), ('demo-aurora', 'Profumeria Aurora', 0xFFD81B60),
         ('demo-martello', 'Brico Martello', 0xFFC62828), ('demo-lux', 'Cinema Lux', 0xFF1E4DA1),
         ('demo-tazza', 'Caffè Tazza', 0xFF795548)]
for i, n, c in shops:
    db.execute("INSERT INTO card_types (id,name,color,category,is_generic) VALUES (?,?,?,?,0)", (i, n, c - (1 << 32) if c >= 1 << 31 else c, 'fedelta'))
cards = [  # tipo, nome, codice, formato, sezione, preferita, ultimo uso (giorni fa), scadenza (giorni), note
 ('demo-sole', 'Supermercato Sole', ean('800123456789'), 'ean13', 'gen', 1, 0, None, T['note']),
 ('demo-pagina', 'Libreria Pagina', ean('200456789012'), 'ean13', 'gen', 0, 3, None, None),
 ('demo-verde', 'Farmacia Verde', 'FV-2048-7731', 'code128', 'fam', 1, 1, None, None),
 ('demo-aurora', 'Profumeria Aurora', ean('290011223344'), 'ean13', 'fam', 0, 9, 12, None),
 ('demo-martello', 'Brico Martello', ean('801998877665'), 'ean13', 'gen', 0, 20, None, None),
 ('demo-lux', 'Cinema Lux', ean('4419283'), 'ean8', 'fam', 0, 6, None, None),
 ('demo-tazza', 'Caffè Tazza', 'TAZZA-000731', 'qrCode', 'gen', 0, 2, None, None),
 ('biblioteca', T['lib'], 'BIB0047215', 'code128', 'fam', 0, 15, None, None),
 ('palestra', T['gym'], 'PC-55102', 'qrCode', 'sport', 1, 2, 40, None),
 ('palestra', T['pool'], 'PISC-3371', 'code128', 'sport', 0, 30, None, None),
]
for t, n, code, fmt, s, fav, used, exp, note in cards:
    db.execute("INSERT INTO cards (id,type_id,name,code,code_format,notes,holder,expires_on,section_id,created_at,last_used_at,favorite) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
               (str(uuid.uuid4()), t, n, code, fmt, note, T['holder'], now + exp*day if exp else None, sec[s], now - 60*day, now - used*day - 3600, fav))
sets = {'setupDone': 'true', 'holderName': T['holder'], 'language': lang, 'adsIntroShown': 'true',
        'listView': 'all', 'listSort': 'lastUsed', 'expiryAlerts': 'true', 'expiryDays': '30', 'theme': 'light',
        'lastBackupAt': __import__('datetime').datetime.fromtimestamp(now - 2*day).isoformat()}
for k, v in sets.items(): db.execute("INSERT INTO settings (key,value) VALUES (?,?)", (k, v))
db.commit(); db.close()
print('ok', lang)
