#!/usr/bin/env python3
"""Pubblica la cartella del sito sull'hosting statico di Porkbun (decisione 117).

Il sito online diventa una copia esatta della cartella: prima si inviano i
file, poi si cancella dal server ciò che nella cartella non c'è più (pagine
tolte o rinominate). I nomi che iniziano con un punto (per esempio
`.well-known`, usato per i certificati HTTPS) non si toccano mai.

Uso:
    python3 tools/deploy_site.py [--dry-run] [cartella] [dominio]

Valori predefiniti: cartella `site`, dominio `facilecards.eu`.
Le credenziali arrivano dalle variabili d'ambiente PB_API_KEY e PB_SECRET_KEY
(nella pipeline sono i segreti del repository). Con --dry-run non si invia e
non si cancella nulla: si mostra cosa partirebbe e, se le chiavi ci sono,
anche cosa verrebbe cancellato dal server.

API: https://porkbun.com/api/json/v3/documentation (POST /hosting/deploy).
I file si inviano in JSON, a gruppi di al massimo 10 MB; i testi così come
sono, gli altri in base64. Solo i tipi di file web sono accettati da Porkbun.
Solo libreria standard di Python: nella pipeline non serve installare nulla.
"""

import base64
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

API = 'https://api.porkbun.com/api/json/v3'

# File della cartella che restano privati (appunti, file di sistema).
EXCLUDED_NAMES = {'README.md', '.DS_Store', 'CNAME', '.nojekyll'}

# Tipi accettati da Porkbun; i primi si inviano come testo.
TEXT_TYPES = {
    'html', 'htm', 'css', 'js', 'mjs', 'cjs', 'json', 'jsonl', 'map', 'txt',
    'md', 'csv', 'xml', 'xsl', 'rss', 'atom', 'svg', 'webmanifest', 'vtt',
}
BINARY_TYPES = {
    'wasm', 'png', 'jpg', 'jpeg', 'gif', 'webp', 'avif', 'ico', 'bmp', 'woff',
    'woff2', 'ttf', 'otf', 'eot', 'pdf',
}

# Margine sotto i 10 MB per richiesta, per l'involucro JSON.
MAX_BATCH_BYTES = 8 * 1024 * 1024


def collect(folder: Path) -> list[dict]:
    """I file da pubblicare, con il percorso relativo alla cartella."""
    files = []
    for f in sorted(folder.rglob('*')):
        if not f.is_file() or f.name in EXCLUDED_NAMES:
            continue
        path = f.relative_to(folder).as_posix()
        ext = f.suffix.lower().lstrip('.')
        if ext in TEXT_TYPES:
            files.append({'path': path, 'text': f.read_text(encoding='utf-8')})
        elif ext in BINARY_TYPES:
            data = base64.b64encode(f.read_bytes()).decode('ascii')
            files.append({'path': path, 'content': data})
        else:
            sys.exit(f'Tipo di file non accettato da Porkbun: {path}')
    return files


def batches(files: list[dict]) -> list[list[dict]]:
    out, current, size = [], [], 0
    for f in files:
        n = len(json.dumps(f).encode('utf-8'))
        if n > MAX_BATCH_BYTES:
            sys.exit(f'File troppo grande per una richiesta: {f["path"]}')
        if current and size + n > MAX_BATCH_BYTES:
            out.append(current)
            current, size = [], 0
        current.append(f)
        size += n
    if current:
        out.append(current)
    return out


def call(endpoint: str, body: dict, keys: tuple[str, str]) -> dict:
    """Chiamata all'API; le chiavi viaggiano nelle intestazioni."""
    request = urllib.request.Request(
        f'{API}/{endpoint}',
        data=json.dumps(body).encode('utf-8'),
        headers={
            'Content-Type': 'application/json',
            'X-API-Key': keys[0],
            'X-Secret-API-Key': keys[1],
        },
        method='POST',
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            answer = json.load(response)
    except urllib.error.HTTPError as e:
        detail = e.read().decode('utf-8', 'replace')[:500]
        sys.exit(f'{endpoint}: errore HTTP {e.code}: {detail}')
    if answer.get('status') != 'SUCCESS':
        sys.exit(f'{endpoint}: {json.dumps(answer)[:500]}')
    return answer


def is_protected(path: str) -> bool:
    """File e cartelle nascosti del server (certificati, configurazione)."""
    return any(part.startswith('.') for part in path.split('/'))


def looks_like_file(name: str) -> bool:
    ext = name.rsplit('.', 1)[-1].lower() if '.' in name else ''
    return ext in TEXT_TYPES or ext in BINARY_TYPES


def remote_tree(domain: str, keys: tuple[str, str], path: str = '') -> tuple[set, set]:
    """File e cartelle presenti sul server, con il percorso completo.

    L'API restituisce solo i nomi: un nome con un'estensione web è un file,
    gli altri si esplorano come cartelle.
    """
    files, dirs = set(), set()
    body = {'path': path} if path else {}
    for name in call(f'hosting/files/{domain}', body, keys).get('files', []):
        name = name.rstrip('/')
        full = f'{path}/{name}' if path else name
        if is_protected(full):
            continue
        if looks_like_file(name):
            files.add(full)
        else:
            dirs.add(full)
            sub_files, sub_dirs = remote_tree(domain, keys, full)
            files |= sub_files
            dirs |= sub_dirs
    return files, dirs


def orphans(local: set, remote_files: set, remote_dirs: set) -> tuple[list, list]:
    """Cosa togliere dal server: cartelle che non contengono più nessun file
    del sito (si cancellano intere) e file che non ci sono più."""
    local_dirs = {'/'.join(p.split('/')[:i])
                  for p in local for i in range(1, p.count('/') + 1)}
    stale_dirs = sorted(d for d in remote_dirs if d not in local_dirs)
    # Basta cancellare la cartella più esterna: il resto va con lei.
    stale_dirs = [d for d in stale_dirs
                  if not any(d.startswith(o + '/') for o in stale_dirs)]
    inside = lambda f: any(f.startswith(d + '/') for d in stale_dirs)
    stale_files = sorted(f for f in remote_files - local if not inside(f))
    return stale_dirs, stale_files


def main() -> None:
    args = [a for a in sys.argv[1:] if a != '--dry-run']
    dry_run = '--dry-run' in sys.argv
    folder = Path(args[0] if args else 'site')
    domain = args[1] if len(args) > 1 else 'facilecards.eu'
    if not folder.is_dir():
        sys.exit(f'Cartella non trovata: {folder}')

    files = collect(folder)
    groups = batches(files)
    if not files:
        sys.exit('Nessun file da pubblicare: per sicurezza non si fa nulla.')
    print(f'{len(files)} file da {folder}/ verso {domain}, '
          f'{len(groups)} richiesta/e')
    local = {f['path'] for f in files}

    keys = (os.environ.get('PB_API_KEY', ''), os.environ.get('PB_SECRET_KEY', ''))
    if dry_run:
        for path in sorted(local):
            print('  da inviare', path)
        if all(keys):
            stale_dirs, stale_files = orphans(local, *remote_tree(domain, keys))
            for d in stale_dirs:
                print('  da cancellare (cartella)', d)
            for f in stale_files:
                print('  da cancellare', f)
        else:
            print('(senza chiavi non si vede cosa c\'è sul server)')
        return
    if not all(keys):
        sys.exit('Mancano PB_API_KEY e PB_SECRET_KEY.')

    hosting = call(f'hosting/get/{domain}', {}, keys).get('hosting')
    if not hosting:
        sys.exit(f'Nessun hosting su {domain}.')
    print(f'Hosting: {hosting.get("product")}, stato {hosting.get("status")}')

    deployed, skipped = [], []
    for group in groups:
        answer = call(f'hosting/deploy/{domain}', {'files': group}, keys)
        deployed += answer.get('deployed', [])
        skipped += answer.get('skipped', [])
    for path in deployed:
        print('  inviato', path)
    for s in skipped:
        print('  SCARTATO', s.get('path'), '-', s.get('reason'))
    if skipped:
        sys.exit(f'{len(skipped)} file scartati da Porkbun: non si cancella nulla.')

    # Solo dopo un invio riuscito: il sito non resta mai senza pagine.
    stale_dirs, stale_files = orphans(local, *remote_tree(domain, keys))
    for d in stale_dirs:
        call(f'hosting/deleteFile/{domain}', {'path': d, 'recursive': True}, keys)
        print('  cancellata la cartella', d)
    for f in stale_files:
        call(f'hosting/deleteFile/{domain}', {'path': f}, keys)
        print('  cancellato', f)
    print(f'Fatto: {len(deployed)} file pubblicati, '
          f'{len(stale_dirs) + len(stale_files)} tolti, su https://{domain}')


if __name__ == '__main__':
    main()
