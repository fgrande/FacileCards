// Annunci AdMob (decisioni 13, 95, 105; analisi 8). Solo banner adattivi,
// al piede dell'elenco e della scheda della tessera, in uno spazio già
// riservato: il contenuto non si sposta quando l'annuncio arriva.
//
// Niente di tutto questo rallenta la tessera: il consenso si aggiorna e gli
// annunci si avviano dopo la prima schermata, e senza rete l'app funziona
// come prima (lo spazio resta vuoto).

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:material_ui/material_ui.dart';

import 'theme.dart';

/// Blocchi di annunci. Nelle versioni di sviluppo si usano sempre quelli di
/// prova di Google: i nostri non si toccano mai, nemmeno per prova (8.3).
abstract final class AdUnits {
  static const _testBanner = 'ca-app-pub-3940256099942544/9214589741';

  static String get list =>
      kReleaseMode ? 'ca-app-pub-4977111287348568/7537368684' : _testBanner;
  static String get card =>
      kReleaseMode ? 'ca-app-pub-4977111287348568/3598123679' : _testBanner;
}

/// Altezza dello spazio riservato al banner, come nei disegni (2, 5).
const adStripHeight = 74.0;

/// Altezza massima del banner dentro lo spazio riservato.
const _maxBannerHeight = 60;

class Ads {
  Ads._();
  static final instance = Ads._();

  /// Si possono caricare annunci: consenso raccolto (o non richiesto nel
  /// paese) e libreria di Google avviata.
  final ready = ValueNotifier<bool>(false);

  /// Falso con la versione Pro (quando ci sarà l'acquisto, decisione 98):
  /// niente spazio riservato e niente annunci.
  final enabled = ValueNotifier<bool>(true);

  bool _starting = false;

  /// Aggiorna lo stato del consenso, mostra la finestra di Google se serve
  /// (decisione 105: Spazio economico europeo, Regno Unito, Svizzera) e
  /// avvia gli annunci. Da chiamare dopo la prima schermata.
  Future<void> start() async {
    if (_starting || !enabled.value) return;
    _starting = true;
    final consent = ConsentInformation.instance;
    // Con un consenso già dato in passato si parte subito, senza aspettare
    // la rete.
    if (await consent.canRequestAds()) await _initialize();
    consent.requestConsentInfoUpdate(
      ConsentRequestParameters(
        // In sviluppo la finestra compare come in Europa, ovunque si provi.
        consentDebugSettings: kReleaseMode
            ? null
            : ConsentDebugSettings(
                debugGeography: DebugGeography.debugGeographyEea,
              ),
      ),
      () => ConsentForm.loadAndShowConsentFormIfRequired((_) async {
        if (await consent.canRequestAds()) await _initialize();
      }),
      // Senza rete o con un errore di Google: si riprova al prossimo avvio.
      (_) {},
    );
  }

  Future<void> _initialize() async {
    if (ready.value) return;
    await MobileAds.instance.initialize();
    ready.value = true;
  }

  /// "Gestisci consenso annunci" (decisione 95): riapre le scelte di Google.
  /// Restituisce false se nel paese dell'utente il consenso non è richiesto.
  Future<bool> showPrivacyOptions() async {
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    if (status != PrivacyOptionsRequirementStatus.required) return false;
    await ConsentForm.showPrivacyOptionsForm((_) {});
    if (await ConsentInformation.instance.canRequestAds()) await _initialize();
    return true;
  }
}

/// Spazio del banner al piede della schermata (decisione 13). Riservato
/// anche prima che l'annuncio arrivi; se non arriva resta vuoto.
class AdStrip extends StatefulWidget {
  const AdStrip({super.key, required this.unitId});

  final String unitId;

  @override
  State<AdStrip> createState() => _AdStripState();
}

class _AdStripState extends State<AdStrip> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Ads.instance.ready.addListener(_maybeLoad);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoad());
  }

  @override
  void dispose() {
    Ads.instance.ready.removeListener(_maybeLoad);
    _ad?.dispose();
    super.dispose();
  }

  Future<void> _maybeLoad() async {
    if (!mounted || _loading || _ad != null || !Ads.instance.ready.value) {
      return;
    }
    _loading = true;
    final width = MediaQuery.sizeOf(context).width.truncate();
    final size = AdSize.getInlineAdaptiveBannerAdSize(width, _maxBannerHeight);
    final ad = BannerAd(
      adUnitId: widget.unitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          // Nel registro, per capire perché un annuncio non arriva.
          debugPrint('Annuncio non caricato: $error');
          ad.dispose();
          if (mounted) {
            setState(() {
              _ad = null;
              _loaded = false;
            });
          }
        },
      ),
    );
    _ad = ad;
    await ad.load();
    _loading = false;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final ad = _ad;
    return Container(
      height: adStripHeight,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      alignment: Alignment.center,
      child: _loaded && ad != null
          ? SizedBox(
              width: ad.size.width.toDouble(),
              height: _maxBannerHeight.toDouble(),
              child: AdWidget(ad: ad),
            )
          : null,
    );
  }
}

/// Lo spazio del banner in fondo alla schermata, con il margine di sistema;
/// sparisce con la versione Pro.
class AdFooter extends StatelessWidget {
  const AdFooter({super.key, required this.unitId});

  final String unitId;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: Ads.instance.enabled,
    builder: (context, on, _) => on
        ? ColoredBox(
            color: AppColors.of(context).surface,
            child: SafeArea(top: false, child: AdStrip(unitId: unitId)),
          )
        : const SizedBox.shrink(),
  );
}
