import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import 'data/catalog.dart' show hasFixedName, typeName;
import 'data/database.dart' as db;
import 'theme.dart';

/// Simbolo dell'app (tessera con il pollice), per la barra dell'elenco.
class AppMark extends StatelessWidget {
  const AppMark({super.key, this.height = 26});

  final double height;

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/logo-mark.svg', height: height);
}

/// Logo della tipologia: iniziali bianche su quadrato arrotondato colorato.
/// Il colore non cambia con il tema.
class TypeLogo extends StatelessWidget {
  const TypeLogo({
    super.key,
    required this.type,
    this.size = 48,
    this.warning = false,
    this.name,
  });

  final db.CardType type;
  final double size;

  /// Nome della tessera: per le tipologie a nome libero (biblioteca,
  /// palestra, generica) le iniziali vengono da qui ("Biblioteca civica" → BC).
  final String? name;

  /// Pallino ambra con "!" (tipologia non più valida, videata 2).
  final bool warning;

  static const fallbackColor = 0xFF78909C;

  String get _initials =>
      initialsOf(!hasFixedName(type) && name != null ? name! : typeName(type));

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(type.color ?? fallbackColor),
        borderRadius: BorderRadius.circular(size * 0.27),
      ),
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: size * (_initials.length > 1 ? 0.36 : 0.40),
        ),
      ),
    );
    if (!warning) return logo;
    final c = AppColors.of(context);
    return SizedBox(
      width: size + 6,
      height: size + 6,
      child: Stack(
        children: [
          Positioned(left: 0, bottom: 0, child: logo),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.star,
                shape: BoxShape.circle,
                border: Border.all(color: c.surface, width: 2),
              ),
              child: const Text(
                '!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Iniziali di un nome: due parole → due lettere ("Acqua & Sapone" → "AS").
String initialsOf(String name) {
  final words = name
      .split(RegExp(r'[\s&]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return '?';
  if (words.length >= 2) return (words[0][0] + words[1][0]).toUpperCase();
  return words.first[0].toUpperCase();
}

/// Intestazione di un gruppo nell'elenco ("PREFERITE", "TUTTE LE TESSERE"),
/// con un testo facoltativo a destra ("12 di 50").
class GroupHeader extends StatelessWidget {
  const GroupHeader(this.text, {super.key, this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final style = TextStyle(
      color: c.muted,
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(
        children: [
          Expanded(child: Text(text.toUpperCase(), style: style)),
          if (trailing != null) Text(trailing!, style: style),
        ],
      ),
    );
  }
}

/// Righe su fondo bianco (o superficie scura) a tutta larghezza, separate da
/// una linea sottile che parte dopo il logo.
class TileGroup extends StatelessWidget {
  const TileGroup({super.key, required this.children, this.indent = 78});

  final List<Widget> children;
  final double indent;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Material(
      color: c.surface,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, indent: indent),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Riquadro bianco arrotondato con bordo sottile (dettagli della tessera,
/// gruppi delle impostazioni).
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: child,
    );
  }
}

/// Freccia a destra delle righe che aprono qualcosa.
class Chevron extends StatelessWidget {
  const Chevron({super.key});

  @override
  Widget build(BuildContext context) =>
      Icon(Icons.chevron_right, color: AppColors.of(context).muted, size: 26);
}

/// Icona in un quadrato arrotondato a sinistra delle righe (sezioni,
/// archivio). [accent]: fondo azzurro e icona blu, altrimenti grigi.
class IconTile extends StatelessWidget {
  const IconTile(this.icon, {super.key, this.accent = false});

  final IconData icon;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: accent ? c.infoBg : c.segment,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: accent ? c.primary : c.muted),
    );
  }
}
