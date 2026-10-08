import '../../../shared/widgets/davo_animated_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/auth_widgets.dart';
import 'create_password_screen.dart';

const _iconRoot = 'assets/icons/auth';

class _CountryOption {
  const _CountryOption(this.name, this.dialCode, this.flag, this.maxDigits);

  final String name;
  final String dialCode;
  final String flag;
  final int maxDigits;
}

const _countries = <_CountryOption>[
  _CountryOption('Nigeria', '+234', '🇳🇬', 10),
  _CountryOption('Ghana', '+233', '🇬🇭', 9),
  _CountryOption('Kenya', '+254', '🇰🇪', 9),
  _CountryOption('South Africa', '+27', '🇿🇦', 9),
  _CountryOption('United Kingdom', '+44', '🇬🇧', 10),
  _CountryOption('United States', '+1', '🇺🇸', 10),
];

class CountrySelectionScreen extends StatefulWidget {
  const CountrySelectionScreen({super.key});

  @override
  State<CountrySelectionScreen> createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen> {
  _CountryOption? _country;
  bool _agreed = false;

  bool get _canContinue => _country != null && _agreed;

  @override
  Widget build(BuildContext context) {
    return DavoAuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Entrance(
            child: DavoScreenIntro(
              title: 'Create Account',
              subtitle:
                  'Choose where you’re located to personalize your Davochain experience.',
            ),
          ),
          const SizedBox(height: 24),
          Entrance(
            delay: const Duration(milliseconds: 70),
            child: _CountryField(
              country: _country,
              onTap: _pickCountry,
            ),
          ),
          const Spacer(),
          Entrance(
            delay: const Duration(milliseconds: 130),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AgreementCheckbox(
                  checked: _agreed,
                  onChanged: (value) => setState(() => _agreed = value),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: _AgreementCopy())),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Entrance(
            delay: const Duration(milliseconds: 180),
            child: DavoPrimaryButton(
              label: 'Continue',
              enabled: _canContinue,
              onPressed: _canContinue
                  ? () => pushAppPage<void>(
                        context,
                        (_) => _AccountDetailsScreen(country: _country!),
                      )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Future<void> _pickCountry() async {
    final selected = await showModalBottomSheet<_CountryOption>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _CountryPickerSheet(),
    );
    if (selected != null && mounted) setState(() => _country = selected);
  }
}

class _CountryField extends StatelessWidget {
  const _CountryField({required this.country, required this.onTap});

  final _CountryOption? country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Ink(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (country != null) ...[
                Text(country!.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  country?.name ?? 'Select your country',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.35,
                    color: country == null ? AppColors.muted : AppColors.body,
                  ),
                ),
              ),
              Image.asset(
                '$_iconRoot/arrow_down.png',
                width: 20,
                height: 20,
                filterQuality: FilterQuality.high,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgreementCheckbox extends StatelessWidget {
  const _AgreementCheckbox({required this.checked, required this.onChanged});
  final bool checked;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => DavoAnimatedCheckbox(
        value: checked,
        onChanged: onChanged,
        size: 24,
        semanticLabel: 'Agree to terms and privacy policy',
      );
}

class _AgreementCopy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.body,
          height: 1.25,
        );
    final link = style?.copyWith(color: AppColors.primary);

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          const TextSpan(text: 'By continuing you agree to our '),
          TextSpan(text: 'Terms and conditions', style: link),
          const TextSpan(text: ' as well as our '),
          TextSpan(text: 'Privacy policy', style: link),
          const TextSpan(
            text:
                ' including verification of your identity through our third party provider',
          ),
        ],
      ),
    );
  }
}

class _CountryPickerSheet extends StatelessWidget {
  const _CountryPickerSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select your country',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ..._countries.map(
            (country) => ListTile(
              contentPadding: EdgeInsets.zero,
              minLeadingWidth: 34,
              onTap: () => Navigator.pop(context, country),
              leading: Text(country.flag, style: const TextStyle(fontSize: 26)),
              title: Text(country.name),
              trailing: Text(country.dialCode,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountDetailsScreen extends StatefulWidget {
  const _AccountDetailsScreen({required this.country});

  final _CountryOption country;

  @override
  State<_AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<_AccountDetailsScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _referral = TextEditingController();

  String? _emailError;

  bool get _canContinue =>
      _name.text.trim().length >= 2 &&
      _isValidEmail(_email.text.trim()) &&
      _phone.text.replaceAll(RegExp(r'\D'), '').length >=
          widget.country.maxDigits;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _referral.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  void _refresh() {
    final email = _email.text.trim();
    setState(() {
      _emailError =
          email.isNotEmpty && !_isValidEmail(email) ? 'Wrong Email' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DavoAuthScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Entrance(
                      child: DavoScreenIntro(
                        title: 'Create Account',
                        subtitle:
                            'Sign up quickly to start trading gift cards, managing your USD, and sending money with Davochain.',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Entrance(
                      delay: const Duration(milliseconds: 50),
                      child: DavoTextField(
                        label: 'Full Name',
                        controller: _name,
                        hint: 'Enter full name',
                        iconAsset: '$_iconRoot/user.png',
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        onChanged: (_) => _refresh(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Entrance(
                      delay: const Duration(milliseconds: 90),
                      child: DavoTextField(
                        label: 'Email Address',
                        controller: _email,
                        hint: 'example@email.com',
                        iconAsset: '$_iconRoot/email.png',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        errorText: _emailError,
                        onChanged: (_) => _refresh(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Entrance(
                      delay: const Duration(milliseconds: 130),
                      child: _PhoneField(
                          country: widget.country,
                          controller: _phone,
                          onChanged: _refresh),
                    ),
                    const SizedBox(height: 16),
                    Entrance(
                      delay: const Duration(milliseconds: 170),
                      child: DavoTextField(
                        label: 'Referral (optional)',
                        controller: _referral,
                        hint: 'Enter code',
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => _refresh(),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 28),
                    DavoPrimaryButton(
                      label: 'Continue',
                      enabled: _canContinue,
                      onPressed: _canContinue
                          ? () => pushAppPage<void>(
                                context,
                                (_) => const CreatePasswordScreen(),
                              )
                          : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField(
      {required this.country,
      required this.controller,
      required this.onChanged});

  final _CountryOption country;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number',
          style: TextStyle(fontSize: 16, height: 1.35, color: AppColors.body),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              height: 48,
              constraints: const BoxConstraints(minWidth: 82),
              padding: const EdgeInsets.symmetric(horizontal: 9),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(country.flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 5),
                  Text(country.dialCode,
                      style:
                          const TextStyle(fontSize: 12, color: AppColors.body)),
                ],
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumberNational],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(country.maxDigits),
                  ],
                  onChanged: (_) => onChanged(),
                  style:
                      const TextStyle(fontSize: 14, color: AppColors.bodyMuted),
                  decoration: InputDecoration(
                    hintText: country.name == 'Nigeria'
                        ? '9062568004'
                        : 'Phone number',
                    hintStyle:
                        const TextStyle(fontSize: 14, color: AppColors.muted),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0x14121212)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
