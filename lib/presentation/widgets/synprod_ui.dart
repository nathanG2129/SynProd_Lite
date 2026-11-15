import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Soft green-tinted canvas background (`#F8FAFC` -> `#F0F7E8`).
class SynProdCanvas extends StatelessWidget {
  final Widget child;

  const SynProdCanvas({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.canvasGradient,
      ),
      child: child,
    );
  }
}

/// Brand gradient text (`#445C3C` -> `#91B029`) using ShaderMask.
class SynProdGradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const SynProdGradientText(
    this.text, {
    super.key,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ??
        const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        );

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => AppTheme.brandHeadingGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: effectiveStyle),
    );
  }
}

/// Dashboard-style AppBar with `3px solid #445C3C` bottom border and green-tinted shadow.
class SynProdAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final double toolbarHeight;

  const SynProdAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.toolbarHeight = 64,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        toolbarHeight + (bottom?.preferredSize.height ?? 0) + 3,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.forestGreen, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.headerShadow,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        toolbarHeight: toolbarHeight,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: leading,
        title: title,
        actions: actions,
        bottom: bottom,
      ),
    );
  }
}

/// Signature `.content-card` with `2px` green-tinted border, shadow, and `4px` top gradient bar.
class SynProdCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const SynProdCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 4,
          decoration: const BoxDecoration(
            gradient: AppTheme.brandHeadingGradient,
          ),
        ),
        Padding(
          padding: padding,
          child: child,
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x1A445C3C),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: onTap != null
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  child: content,
                ),
              )
            : content,
      ),
    );
  }
}

/// `.btn-primary`: Olive gradient CTA button (`#91B029` -> `#7A9A1F`).
class SynProdGradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const SynProdGradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: enabled ? AppTheme.primaryGradient : null,
        color: enabled ? null : AppTheme.slate300,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: enabled ? AppTheme.primaryOlive : AppTheme.slate300,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: padding,
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              child: IconTheme(
                data: const IconThemeData(color: Colors.white, size: 18),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `.btn-secondary`: Soft green tint button (`#F1F6E8` -> `#E8F5C8`) with `#445C3C` text.
class SynProdSecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const SynProdSecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppTheme.softTintGradient,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.primaryOlive.withValues(alpha: 0.3),
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.forestGreen,
          padding: padding,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: IconTheme(
          data: const IconThemeData(color: AppTheme.forestGreen, size: 16),
          child: child,
        ),
      ),
    );
  }
}

/// `.percentage-indicator`: Valid (`#D4F1A8` / `#91B029`) or Warning (`#FEF3C7` / `#F59E0B`).
class SynProdPercentageBadge extends StatelessWidget {
  final double totalPercentage;
  final bool isValid;
  final bool compact;

  const SynProdPercentageBadge({
    super.key,
    required this.totalPercentage,
    required this.isValid,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isValid ? AppTheme.percentageValidBg : AppTheme.warningBg;
    final borderColor =
        isValid ? AppTheme.primaryOlive : AppTheme.amberWarning;
    final textColor =
        isValid ? AppTheme.forestGreen : AppTheme.warningText;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 5 : 8,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            size: compact ? 15 : 18,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            compact
                ? 'Total: ${totalPercentage.toStringAsFixed(1)}%'
                : isValid
                    ? 'Total: ${totalPercentage.toStringAsFixed(1)}% (Balanced)'
                    : 'Total: ${totalPercentage.toStringAsFixed(1)}% (Must equal 100%)',
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular 36x36 user/device avatar with primary olive gradient.
class SynProdAvatar extends StatelessWidget {
  final String displayName;
  final double size;

  const SynProdAvatar({
    super.key,
    required this.displayName,
    this.size = 34,
  });

  String get _initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'SP';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
