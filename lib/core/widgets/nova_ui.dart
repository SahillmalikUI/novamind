import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// One reusable kit for the whole app. These replace the copy-pasted
/// `_GradientButton`, `_GlassField`, `_ChipRow`, `_HeaderIconButton` that were
/// redeclared in five different screens.

// ---------------------------------------------------------------------------
// PRIMARY BUTTON — the only place the brand gradient appears on a screen.
// ---------------------------------------------------------------------------
class NovaPrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool loading;
  final VoidCallback? onTap;

  const NovaPrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.loading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: enabled ? 1 : 0.6,
          child: Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Nova.rMd),
              gradient: Nova.brandGradient,
              boxShadow: enabled ? Nova.accentGlow : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.2,
                    ),
                  )
                else if (icon != null)
                  Icon(icon, color: Colors.white, size: 20),
                if (loading || icon != null) const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECONDARY BUTTON — quiet solid surface. Everything that isn't the main action.
// ---------------------------------------------------------------------------
class NovaSecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? tint; // optional semantic tint (e.g. danger for Logout)
  final VoidCallback? onTap;

  const NovaSecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.tint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = tint ?? Nova.textPrimary;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: tint == null
                ? Nova.surface
                : tint!.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(Nova.rMd),
            border: Border.all(
              color: tint == null
                  ? Nova.borderStrong
                  : tint!.withValues(alpha: 0.32),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: c, size: 20),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: TextStyle(
                  color: c,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CARD — one consistent surface. Solid, hairline border. No stacked blur.
// ---------------------------------------------------------------------------
class NovaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  const NovaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Nova.s20),
    this.radius = Nova.rLg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Nova.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Nova.border),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: card,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TEXT FIELD — consistent input used across auth + AI screens.
// ---------------------------------------------------------------------------
class NovaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType keyboardType;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  const NovaTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.minLines = 1,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: obscure ? 1 : maxLines,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      style: Nova.body,
      cursorColor: Nova.violet,
      decoration: InputDecoration(
        prefixIcon: icon == null
            ? null
            : Icon(icon, color: Nova.textMuted, size: 21),
        suffixIcon: suffix,
        hintText: hint,
        hintStyle: const TextStyle(color: Nova.textMuted, fontSize: 15),
        filled: true,
        fillColor: Nova.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Nova.s16,
          vertical: Nova.s16,
        ),
        border: _border(Nova.border),
        enabledBorder: _border(Nova.border),
        focusedBorder: _border(Nova.violet, width: 1.4),
      ),
    );
  }

  OutlineInputBorder _border(Color c, {double width = 1}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(Nova.rMd),
        borderSide: BorderSide(color: c, width: width),
      );
}

// ---------------------------------------------------------------------------
// CHOICE CHIPS — selectable row (summary style, quiz difficulty, etc.)
// Selected uses a flat violet fill, not the full gradient — quieter.
// ---------------------------------------------------------------------------
class NovaChips extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const NovaChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Nova.s8,
      runSpacing: Nova.s8,
      children: options.map((o) {
        final isSel = o == selected;
        return GestureDetector(
          onTap: () => onSelected(o),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: isSel ? Nova.violet : Nova.surface,
              borderRadius: BorderRadius.circular(Nova.rSm),
              border: Border.all(
                color: isSel ? Nova.violet : Nova.border,
              ),
            ),
            child: Text(
              o,
              style: TextStyle(
                color: isSel ? Colors.white : Nova.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION HEADER
// ---------------------------------------------------------------------------
class NovaSectionTitle extends StatelessWidget {
  final String text;
  const NovaSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(text, style: Nova.h2);
}

// ---------------------------------------------------------------------------
// ICON BUTTON — app-bar action.
// ---------------------------------------------------------------------------
class NovaIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final Color? tint;

  const NovaIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Nova.surface,
      borderRadius: BorderRadius.circular(Nova.rSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Nova.rSm),
        child: Tooltip(
          message: tooltip ?? '',
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Nova.rSm),
              border: Border.all(color: Nova.border),
            ),
            child: Icon(icon, color: tint ?? Nova.textSecondary, size: 21),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// INLINE ERROR / NOTICE
// ---------------------------------------------------------------------------
class NovaNotice extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;

  const NovaNotice(
    this.message, {
    super.key,
    this.color = Nova.danger,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Nova.rSm),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
