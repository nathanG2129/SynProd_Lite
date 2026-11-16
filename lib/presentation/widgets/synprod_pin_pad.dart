import 'package:flutter/material.dart';

import '../../core/services/pin_auth_service.dart';
import '../../core/theme/app_theme.dart';
import 'synprod_ui.dart';

/// Lock-screen style numeric PIN pad supporting 4–6 digit PIN entry.
class SynProdPinPad extends StatefulWidget {
  final String title;
  final String subtitle;
  final String submitLabel;
  final IconData submitIcon;
  final bool isBusy;
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

  void _appendDigit(String digit) {
    if (widget.isBusy || _pin.length >= PinAuthService.maxPinLength) return;
    setState(() {
      _pin += digit;
      _validationError = null;
    });
  }

  void _backspace() {
    if (widget.isBusy || _pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _validationError = null;
    });
  }

  void _clear() {
    if (widget.isBusy || _pin.isEmpty) return;
    setState(() {
      _pin = '';
      _validationError = null;
    });
  }

  void _handleSubmit() {
    if (widget.isBusy) return;
    if (!PinAuthService.isValidPinFormat(_pin)) {
      setState(() => _validationError = 'PIN must be 4 to 6 digits.');
      return;
    }
    widget.onSubmit(_pin);
  }

  @override
  Widget build(BuildContext context) {
    final activeError = _validationError ?? widget.errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.forestGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.slate500,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(PinAuthService.maxPinLength, (index) {
            final filled = index < _pin.length;
            final isRequiredSlot = index < PinAuthService.minPinLength;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppTheme.forestGreen : Colors.transparent,
                border: Border.all(
                  color: filled
                      ? AppTheme.forestGreen
                      : (isRequiredSlot
                          ? AppTheme.oliveMuted
                          : AppTheme.slate300),
                  width: 2,
                ),
              ),
            );
          }),
        ),
        if (activeError != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.errorBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.inputErrorBorder),
            ),
            child: Text(
              activeError,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.errorText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        _buildKeypadRow(['1', '2', '3']),
        const SizedBox(height: 10),
        _buildKeypadRow(['4', '5', '6']),
        const SizedBox(height: 10),
        _buildKeypadRow(['7', '8', '9']),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionKey(
              label: 'Clear',
              onTap: _pin.isEmpty || widget.isBusy ? null : _clear,
            ),
            _buildDigitKey('0'),
            _buildIconKey(
              icon: Icons.backspace_outlined,
              tooltip: 'Backspace',
              onTap: _pin.isEmpty || widget.isBusy ? null : _backspace,
            ),
          ],
        ),
        const SizedBox(height: 20),
        SynProdGradientButton(
          onPressed: widget.isBusy || _pin.length < PinAuthService.minPinLength
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

  Widget _buildKeypadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map(_buildDigitKey).toList(),
    );
  }

  Widget _buildDigitKey(String digit) {
    return _KeypadButton(
      onTap: widget.isBusy ? null : () => _appendDigit(digit),
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppTheme.forestGreen,
        ),
      ),
    );
  }

  Widget _buildIconKey({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: _KeypadButton(
        onTap: onTap,
        isSecondary: true,
        child: Icon(
          icon,
          size: 20,
          color: onTap == null ? AppTheme.slate300 : AppTheme.forestGreen,
        ),
      ),
    );
  }

  Widget _buildActionKey({
    required String label,
    required VoidCallback? onTap,
  }) {
    return _KeypadButton(
      onTap: onTap,
      isSecondary: true,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: onTap == null ? AppTheme.slate300 : AppTheme.oliveMuted,
        ),
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final bool isSecondary;

  const _KeypadButton({
    required this.onTap,
    required this.child,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 54,
      child: Material(
        color: isSecondary ? Colors.transparent : const Color(0xFFF6F9F0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSecondary
              ? BorderSide.none
              : BorderSide(
                  color: AppTheme.primaryOlive.withValues(alpha: 0.25),
                ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(child: child),
        ),
      ),
    );
  }
}
