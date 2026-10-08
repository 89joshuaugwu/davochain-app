import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

const _iconRoot = 'assets/icons/auth';

class DavoAuthScaffold extends StatelessWidget {
  const DavoAuthScaffold({
    super.key,
    required this.child,
    this.onBack,
    this.bottom,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.keyboardDismiss = true,
  });

  final Widget child;
  final VoidCallback? onBack;
  final Widget? bottom;
  final EdgeInsets contentPadding;
  final bool keyboardDismiss;

  @override
  Widget build(BuildContext context) {
    const overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    );

    final page = Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _BackButton(
                  onPressed: onBack ?? () => Navigator.maybePop(context),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: contentPadding,
                child: child,
              ),
            ),
            if (bottom != null)
              SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: bottom!,
              ),
          ],
        ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: keyboardDismiss
          ? GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: page,
            )
          : page,
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      splashRadius: 20,
      icon: Image.asset(
        '$_iconRoot/arrow_left.png',
        width: 24,
        height: 24,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class DavoScreenIntro extends StatelessWidget {
  const DavoScreenIntro({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleColor = AppColors.inkStrong,
  });

  final String title;
  final String subtitle;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.bodyMuted,
              ),
        ),
      ],
    );
  }
}

class DavoPrimaryButton extends StatefulWidget {
  const DavoPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.loading = false,
    this.height = 48,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool loading;
  final double height;

  @override
  State<DavoPrimaryButton> createState() => _DavoPrimaryButtonState();
}

class _DavoPrimaryButtonState extends State<DavoPrimaryButton> {
  bool _pressed = false;

  bool get _enabled =>
      widget.enabled && !widget.loading && widget.onPressed != null;

  void _activate() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final enabled = _enabled;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.loading ? '${widget.label}, loading' : widget.label,
      liveRegion: widget.loading,
      excludeSemantics: true,
      onTap: enabled ? _activate : null,
      child: AnimatedScale(
        scale: !reduce && enabled && _pressed ? .98 : 1,
        duration: reduce ? Duration.zero : const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: double.infinity,
          height: widget.height,
          child: AnimatedContainer(
            duration:
                reduce ? Duration.zero : const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: enabled || widget.loading
                  ? AppColors.primary
                  : AppColors.primaryDisabled,
              borderRadius: BorderRadius.circular(4),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: .12),
                        blurRadius: 18,
                        offset: const Offset(0, 7),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashFactory: reduce ? NoSplash.splashFactory : null,
                onTap: enabled ? _activate : null,
                excludeFromSemantics: true,
                onHighlightChanged: (pressed) {
                  if (_pressed != pressed) setState(() => _pressed = pressed);
                },
                borderRadius: BorderRadius.circular(4),
                child: Center(
                  child: widget.loading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: reduce
                              ? const Icon(Icons.hourglass_top,
                                  color: Colors.white, size: 20)
                              : const CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DavoSecondaryButton extends StatelessWidget {
  const DavoSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 48,
  });

  final String label;
  final VoidCallback onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DavoTextField extends StatefulWidget {
  const DavoTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.iconAsset,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.showVisibilityToggle = false,
    this.errorText,
    this.successText,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
    this.maxLength,
    this.inputFormatters,
    this.borderRadius = 4,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? iconAsset;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool showVisibilityToggle;
  final String? errorText;
  final String? successText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final double borderRadius;

  @override
  State<DavoTextField> createState() => _DavoTextFieldState();
}

class _DavoTextFieldState extends State<DavoTextField> {
  late bool _obscure;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    _focusNode.addListener(_focusChanged);
  }

  void _focusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DavoTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText &&
        !widget.showVisibilityToggle) {
      _obscure = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final success = widget.successText != null && widget.errorText == null;
    final borderColor = widget.errorText != null
        ? AppColors.danger
        : success
            ? AppColors.success
            : _focusNode.hasFocus
                ? AppColors.primary
                : const Color(0xFFD2D6DF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: AppColors.body,
            fontSize: 14,
            height: 1.35,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            focusNode: _focusNode,
            onTapOutside: (_) => _focusNode.unfocus(),
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            obscureText: _obscure,
            obscuringCharacter: '•',
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            autofillHints: widget.autofillHints,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              height: 1.35,
              color: AppColors.bodyMuted,
            ),
            decoration: InputDecoration(
              filled: false,
              counterText: '',
              hintText: widget.hint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              prefixIcon: widget.iconAsset == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(left: 14, right: 8),
                      child: Image.asset(
                        widget.iconAsset!,
                        width: 20,
                        height: 20,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 42, minHeight: 20),
              suffixIcon: widget.showVisibilityToggle
                  ? IconButton(
                      tooltip: _obscure ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() => _obscure = !_obscure),
                      splashRadius: 18,
                      icon: Image.asset(
                        '$_iconRoot/eye.png',
                        width: 20,
                        height: 20,
                        filterQuality: FilterQuality.high,
                      ),
                    )
                  : widget.errorText != null
                      ? Padding(
                          padding: const EdgeInsets.all(13),
                          child: Image.asset(
                            '$_iconRoot/danger.png',
                            width: 18,
                            height: 18,
                            filterQuality: FilterQuality.high,
                          ),
                        )
                      : null,
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.topLeft,
          child: (widget.errorText != null || widget.successText != null)
              ? Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    widget.errorText ?? widget.successText!,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: widget.errorText != null
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class Entrance extends StatelessWidget {
  const Entrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, .025),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) return child;

    return TweenAnimationBuilder<double>(
      key: ValueKey('${child.runtimeType}-${delay.inMilliseconds}'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 430 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final delayed = delay.inMilliseconds == 0
            ? value
            : ((value * (430 + delay.inMilliseconds) - delay.inMilliseconds) /
                    430)
                .clamp(0.0, 1.0)
                .toDouble();
        return Opacity(
          opacity: delayed,
          child: FractionalTranslation(
            translation:
                Offset(offset.dx * (1 - delayed), offset.dy * (1 - delayed)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class LinkText extends StatelessWidget {
  const LinkText({
    super.key,
    required this.prefix,
    required this.action,
    required this.onTap,
  });

  final String prefix;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(prefix, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              action,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
