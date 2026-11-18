import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../theme.dart';

/// Videata 17 (decisione 75): la riga trascinata verso sinistra scopre il
/// pulsante rosso "Elimina". Una sola riga aperta alla volta; toccando la
/// riga aperta si richiude.
class SwipeToDelete extends StatefulWidget {
  const SwipeToDelete({
    super.key,
    required this.id,
    required this.onDelete,
    required this.child,
  });

  /// Identifica la riga: aprirne un'altra chiude questa.
  final String id;
  final VoidCallback onDelete;
  final Widget child;

  /// La riga aperta in questo momento.
  static final openRow = ValueNotifier<String?>(null);

  @override
  State<SwipeToDelete> createState() => _SwipeToDeleteState();
}

class _SwipeToDeleteState extends State<SwipeToDelete>
    with SingleTickerProviderStateMixin {
  static const _width = 96.0;

  late final _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );

  @override
  void initState() {
    super.initState();
    SwipeToDelete.openRow.addListener(_onOtherOpened);
  }

  @override
  void dispose() {
    SwipeToDelete.openRow.removeListener(_onOtherOpened);
    if (SwipeToDelete.openRow.value == widget.id) {
      SwipeToDelete.openRow.value = null;
    }
    _ctrl.dispose();
    super.dispose();
  }

  void _onOtherOpened() {
    if (SwipeToDelete.openRow.value != widget.id && _ctrl.value > 0) {
      _ctrl.animateTo(0);
    }
  }

  void _open() {
    _ctrl.animateTo(1);
    SwipeToDelete.openRow.value = widget.id;
  }

  void _close() {
    _ctrl.animateTo(0);
    if (SwipeToDelete.openRow.value == widget.id) {
      SwipeToDelete.openRow.value = null;
    }
  }

  void _dragEnd(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (v < -300) return _open();
    if (v > 300) return _close();
    _ctrl.value > 0.5 ? _open() : _close();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: c.danger,
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: _width,
                height: double.infinity,
                child: InkWell(
                  onTap: () {
                    _close();
                    widget.onDelete();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.delete_outline, color: Colors.white),
                      const SizedBox(height: 4),
                      Text(
                        context.t.delete,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) => Transform.translate(
            offset: Offset(-_width * _ctrl.value, 0),
            child: child,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (d) =>
                _ctrl.value -= (d.primaryDelta ?? 0) / _width,
            onHorizontalDragEnd: _dragEnd,
            child: ListenableBuilder(
              listenable: _ctrl,
              builder: (context, child) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                // Aperta: un tocco sulla riga la richiude, senza aprire la
                // tessera.
                onTap: _ctrl.value > 0 ? _close : null,
                child: IgnorePointer(ignoring: _ctrl.value > 0, child: child),
              ),
              // Fondo pieno: il rosso si vede solo dove la riga si è spostata.
              child: Material(color: c.surface, child: widget.child),
            ),
          ),
        ),
      ],
    );
  }
}
