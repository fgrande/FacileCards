# Sito di FacileCards (cartella `site/`)

Pagine statiche di presentazione e informativa sulla privacy. Il sito **non è ancora pubblicato**: l'indirizzo previsto è https://facilecards.eu (dominio già acquistato). Dove pubblicarlo si decide prima dell'invio a Google Play (decisione 109 di `docs/01-analisi-iniziale.md`).

| File | Contenuto |
|---|---|
| `index.html`, `en.html`, `fr.html` | Presentazione dell'app (italiano, inglese, francese) |
| `privacy/index.html`, `privacy/en.html`, `privacy/fr.html` | Informativa sulla privacy |
| `app-ads.txt` | Verifica della proprietà dell'app per AdMob; deve restare nella radice del sito |
| `assets/style.css` | Stile comune |
| `CNAME`, `.nojekyll` | Servono solo a GitHub Pages; da togliere se si sceglie un altro servizio |

Nessuna compilazione: i file vanno serviti così come sono. Per provarli in locale basta aprire `index.html` nel browser.

## Da completare prima della pubblicazione

- [x] Informativa: titolare, contatto e data inseriti nelle tre lingue (aggiornare la data a ogni modifica)
- [ ] Informativa: far rileggere il testo, è una bozza
- [ ] `app-ads.txt`: inserire la riga fornita da AdMob
- [ ] Pagine iniziali: sostituire "Disponibile prossimamente" con il link a Google Play
- [ ] Scegliere il servizio di hosting e collegare il dominio
