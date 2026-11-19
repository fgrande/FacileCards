# Sito di FacileCards (cartella `site/`)

Pagine statiche di presentazione e informativa sulla privacy. Si pubblica su https://facilecards.eu, hosting statico di Porkbun (decisione 117 di `docs/01-analisi-iniziale.md`): la pipeline `.github/workflows/site.yml` lancia `tools/deploy_site.py` a ogni modifica di questa cartella su `main`. Per vedere cosa partirebbe, senza inviare nulla: `python3 tools/deploy_site.py --dry-run`. Il sito online è una copia esatta della cartella: ciò che si toglie o si rinomina qui sparisce anche dal server. Questo file e i file di sistema (`.DS_Store`) non vengono pubblicati.

| File | Contenuto |
|---|---|
| `index.html`, `en.html`, `fr.html` | Presentazione dell'app (italiano, inglese, francese) |
| `privacy/index.html`, `privacy/en.html`, `privacy/fr.html` | Informativa sulla privacy |
| `app-ads.txt` | Verifica della proprietà dell'app per AdMob; deve restare nella radice del sito |
| `assets/style.css` | Stile comune |

Nessuna compilazione: i file vanno serviti così come sono. Per provarli in locale basta aprire `index.html` nel browser.

## Da completare prima della pubblicazione

- [x] Informativa: titolare, contatto e data inseriti nelle tre lingue (aggiornare la data a ogni modifica)
- [ ] Informativa: far rileggere il testo, è una bozza
- [ ] `app-ads.txt`: inserire la riga fornita da AdMob
- [ ] Pagine iniziali: sostituire "Disponibile prossimamente" con il link a Google Play
- [x] Hosting scelto (Porkbun) e pipeline di pubblicazione
