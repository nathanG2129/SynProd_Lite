import 'package:flutter/material.dart';

import '../../core/services/pin_auth_service.dart';
import '../../core/theme/app_theme.dart';
import 'synprod_ui.dart';

/// Lock-screen style numeric PIN pad supporting 6-digit PIN entry.
class SynProdPinPad extends StatefulWidget {
  final String title;
  final String subtitle;
  final String submitLabel;
  final IconData submitIcon;
  final bool isBusy;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String> onSubmit;

  const SynProdPinPad({
    super.key,
    required this.title,
    required this.subtitle,
    required this.submitLabel,
    required this.onSubmit,
    this.submitIcon = Icons.arrow_forward,
    this.isBusy = false,
    this.enabled = true,
    this.errorText,
  });

  @override
  State<SynProdPinPad> createState() => _SynProdPinPadState();
}

class _SynProdPinPadState extends State<SynProdPinPad> {
  String _pin = '';
  String? _validationError;

  @override
  void didUpdateWidget(covariant SynProdPinPad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title ||
        (widget.errorText != null && widget.errorText != oldWidget.errorText)) {
      _pin = '';
      _validationError = null;
    }
  }

  bool get _isInteractive => widget.enabled && !widget.isBusy;

  void _appendDigit(String digit) {
    if (!_isInteractive || _pin.length >= PinAuthService.maxPinLength) return;
    setState(() {
      _pin += digit;
      _validationError = null;
    });
  }

  void _backspace() {
    if (!_isInteractive || _pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _validationError = null;
    });
  }

  void _clear() {
    if (!_isInteractive || _pin.isEmpty) return;
    setState(() {
      _pin = '';
      _validationError = null;
    });
  }

  void _handleSubmit() {
    if (!_isInteractive) return;
    if (!PinAuthService.isValidPinFormat(_pin)) {
      setState(() => _validationError = 'PIN must be 6 digits.');
      return;
    }
    widget.onSubmit(_pin);
  }

  @override
  Widget build(BuildContext context) {
    final activeError = _validationError ?? widget.errorText;
    final headingColor = AppTheme.headingColorFor(context);
    final mutedColor = AppTheme.mutedTextFor(context);
    final isDark = AppTheme.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          widget.subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            color: mutedColor,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(PinAuthService.maxPinLength, (index) {
            final filled = index < _pin.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? headingColor : Colors.transparent,
                border: Border.all(
                  color: filled
                      ? headingColor
                      : (isDark ? AppTheme.slate400 : AppTheme.oliveMuted),
                  width: 2,
                ),
              ),
            );
          }),
        ),
        if (activeError != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.errorBgFor(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.inputErrorBorder),
            ),
            child: Text(
              activeError,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.errorTextFor(context),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        _buildKeypadRow([
          _buildDigitKey('1'),
          _buildDigitKey('2'),
          _buildDigitKey('3'),
        ]),
        const SizedBox(height: 6),
        _buildKeypadRow([
          _buildDigitKey('4'),
          _buildDigitKey('5'),
          _buildDigitKey('6'),
        ]),
        const SizedBox(height: 6),
        _buildKeypadRow([
          _buildDigitKey('7'),
          _buildDigitKey('8'),
          _buildDigitKey('9'),
        ]),
        const SizedBox(height: 6),
        _buildKeypadRow([
          _buildActionKey(
            label: 'Clear',
            onTap: _pin.isEmpty || !_isInteractive ? null : _clear,
          ),
          _buildDigitKey('0'),
          _buildIconKey(
            icon: Icons.backspace_outlined,
            tooltip: 'Delete',
            onTap: _pin.isEmpty || !_isInteractive ? null : _backspace,
          ),
        ]),
        const SizedBox(height: 14),
        SynProdGradientButton(
          onPressed: !_isInteractive || _pin.length < PinAuthService.minPinLength
              ? null
              : _handleSubmit,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.submitIcon, size: 18),
              const SizedBox(width: 8),
              Text(widget.submitLabel),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeypadRow(List<Widget> keys) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        keys[0],
        const SizedBox(width: 6),
        keys[1],
        const SizedBox(width: 6),
        keys[2],
      ],
    );
  }

  Widget _buildDigitKey(String digit) {
    return _KeypadButton(
      onTap: _isInteractive ? () => _appendDigit(digit) : null,
      child: Text(
        digit,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppTheme.headingColorFor(context),
        ),
      ),
    );
  }

  Widget _buildIconKey({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
  }) {
    final disabledColor =
        AppTheme.isDark(context) ? AppTheme.slate600 : AppTheme.slate400;
    return Tooltip(
      message: tooltip,
      child: _KeypadButton(
        onTap: onTap,
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? disabledColor : AppTheme.headingColorFor(context),
        ),
      ),
    );
  }

  Widget _buildActionKey({
    required String label,
    required VoidCallback? onTap,
  }) {
    final isDark = AppTheme.isDark(context);
    final disabledColor = isDark ? AppTheme.slate600 : AppTheme.slate400;
    final enabledColor = isDark ? AppTheme.slate200 : AppTheme.slate700;
    return _KeypadButton(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: onTap == null ? disabledColor : enabledColor,
        ),
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const _KeypadButton({
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final keyBg = isDark ? AppTheme.darkSurfaceElevated : AppTheme.slate100;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.slate300;

    return SizedBox(
      width: 58,
      height: 44,
      child: Material(
        color: keyBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Center(child: child),
        ),
      ),
    );
  }
}
