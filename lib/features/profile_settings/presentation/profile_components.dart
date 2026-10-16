part of 'profile_settings_flow.dart';

class _BvnHintPill extends StatelessWidget {
  const _BvnHintPill();
  @override
  Widget build(BuildContext context) => Container(
    width: 154,
    height: 29,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: DavoColors.of(context).primarySoft,
      borderRadius: BorderRadius.circular(1000),
    ),
    child: Text(
      'Enter BVN above (11 digits)',
      style: TextStyle(
        fontFamily: 'Sora',
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: DavoColors.of(context).link,
      ),
    ),
  );
}

class _KycInfoCard extends StatelessWidget {
  const _KycInfoCard({required this.height, required this.body, this.title});
  final double height;
  final String body;
  final String? title;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    constraints: BoxConstraints(minHeight: height),
    padding: EdgeInsets.fromLTRB(21, title == null ? 24 : 20, 22, 20),
    decoration: BoxDecoration(
      color: DavoColors.of(context).warningSurface,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          '$_exactAssets/kyc_info_exact.png',
          width: 16,
          height: 16,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Text(title!, style: _t14b(context)),
                const SizedBox(height: 4),
              ],
              Text(
                body,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 10,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  color: DavoColors.of(context).body,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ContactPhoneField extends StatelessWidget {
  const _ContactPhoneField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Phone Number',
        style: TextStyle(
          fontFamily: 'Sora',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: DavoColors.of(context).body,
          height: 1.35,
        ),
      ),
      const SizedBox(height: 4),
      Row(
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 86),
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: DavoColors.of(context).surface,
              border: Border.all(color: DavoColors.of(context).border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  '$_exactAssets/nigeria_flag_exact.png',
                  width: 21,
                  height: 14,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(width: 3),
                Text(
                  '+234',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 12,
                    color: DavoColors.of(context).body,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                keyboardAppearance: Theme.of(context).brightness,
                controller: controller,
                keyboardType: TextInputType.phone,
                inputFormatters: const [NigerianPhoneFormatter()],
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  color: DavoColors.of(context).body,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
                  hintStyle: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    color: DavoColors.of(context).bodyMuted,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: DavoColors.of(context).border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: DavoColors.of(context).border,
                    ),
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

class _ContactAddressField extends StatelessWidget {
  const _ContactAddressField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Residential  address',
        style: TextStyle(
          fontFamily: 'Sora',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: DavoColors.of(context).body,
          height: 1.35,
        ),
      ),
      const SizedBox(height: 4),
      SizedBox(
        height: 71,
        child: TextField(
          keyboardAppearance: Theme.of(context).brightness,
          controller: controller,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          style: _t12(context).copyWith(color: DavoColors.of(context).body),
          decoration: InputDecoration(
            filled: true,
            fillColor: DavoColors.of(context).offWhite,
            hintText: 'House number, street, area',
            hintStyle: TextStyle(
              fontFamily: 'Sora',
              fontSize: 12,
              color: DavoColors.of(context).bodyMuted,
            ),
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: DavoColors.of(context).border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: DavoColors.of(context).border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ),
    ],
  );
}

class _CountryField extends StatelessWidget {
  const _CountryField();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Country',
        style: TextStyle(
          fontFamily: 'Sora',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: DavoColors.of(context).body,
          height: 1.35,
        ),
      ),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: DavoColors.of(context).offWhite,
          border: Border.all(color: DavoColors.of(context).border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Image.asset(
              '$_exactAssets/nigeria_flag_exact.png',
              width: 21,
              height: 14,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(width: 9),
            Text(
              'Nigeria',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 12,
                color: DavoColors.of(context).muted,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _StatusFullScreen extends StatelessWidget {
  const _StatusFullScreen({
    required this.title,
    required this.body,
    required this.button,
    required this.onTap,
  });
  final String title, body, button;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => DavoResultScreen(
    title: title,
    message: body,
    actions: _PrimaryButton(button, onTap: onTap),
  );
}

class _KycRequirementLine extends StatelessWidget {
  const _KycRequirementLine({required this.asset, required this.text});
  final String asset, text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: SizedBox(
      height: 24,
      child: Row(
        children: [
          Image.asset(
            asset,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: _t12(context))),
        ],
      ),
    ),
  );
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.active,
    required this.onTap,
  });

  final String tier, title, subtitle;
  final bool done, active;
  final VoidCallback onTap;

  int get tierNumber => int.tryParse(tier.split(' ').last) ?? 1;
  String get iconAsset => '$_exactAssets/tier_${tierNumber}_exact.png';

  @override
  Widget build(BuildContext context) {
    final fill = active
        ? DavoColors.of(context).primarySoft
        : DavoColors.of(context).offWhite;
    final border = active
        ? DavoColors.of(context).link
        : DavoColors.of(context).border;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 82,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              height: 40,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: done
                          ? DavoColors.of(context).border
                          : DavoColors.of(context).primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      iconAsset,
                      width: tierNumber == 1 ? 20 : 24,
                      height: tierNumber == 1 ? 20 : 24,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  if (!done && !active)
                    Positioned(
                      right: -4,
                      bottom: 0,
                      child: Image.asset(
                        '$_exactAssets/tier_lock_exact.png',
                        width: 16,
                        height: 16,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tier,
                    style: _t14(context).copyWith(
                      color: done
                          ? DavoColors.of(context).bodyMuted
                          : DavoColors.of(context).body,
                    ),
                  ),
                  Text(title, style: _t14b(context)),
                  Text(subtitle, style: _t12(context)),
                ],
              ),
            ),
            if (done)
              Container(
                width: 86,
                height: 25,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: DavoColors.of(context).successSurface,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      '$_exactAssets/tier_completed_check_exact.png',
                      width: 12,
                      height: 12,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Completed',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: DavoColors.of(context).success,
                      ),
                    ),
                  ],
                ),
              )
            else
              Image.asset(
                '$_exactAssets/icon_arrow_right.png',
                color: DavoColors.of(context).body,
                width: 24,
                height: 24,
                filterQuality: FilterQuality.high,
              ),
          ],
        ),
      ),
    );
  }
}

class _CurrentTierCard extends StatelessWidget {
  const _CurrentTierCard({required this.tier});
  final int tier;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: DavoColors.of(context).offWhite,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Current Tier', style: _t14(context)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              tier == 2
                  ? '$_exactAssets/tier2_medal_exact.png'
                  : '$_exactAssets/tier1_medal_exact.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tier $tier', style: _t14b(context)),
                  const SizedBox(height: 4),
                  Text('NIN verification complete', style: _t12(context)),
                  if (tier == 2)
                    Text('BVN verification complete', style: _t12(context)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const _Pill('Active'),
          ],
        ),
      ],
    ),
  );
}

class _V12ChoiceTile extends StatelessWidget {
  const _V12ChoiceTile(
    this.title,
    this.selected,
    this.onTap, {
    this.subtitle,
    this.asset,
    this.iconDisplaySize = 32,
  });

  final String title;
  final String? subtitle, asset;
  final bool selected;
  final VoidCallback onTap;
  final double iconDisplaySize;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: double.infinity,
      height: 69,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: DavoColors.of(context).offWhite,
        border: Border.all(
          color: selected
              ? DavoColors.of(context).link
              : DavoColors.of(context).border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (asset != null) ...[
            Container(
              width: iconDisplaySize,
              height: iconDisplaySize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: DavoColors.of(context).primarySoft,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.asset(
                asset!,
                width: iconDisplaySize == 30 ? 16 : 20,
                height: iconDisplaySize == 30 ? 16 : 20,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _t14b(context)),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: _t12(context)),
                ],
              ],
            ),
          ),
          Image.asset(
            selected
                ? '$_exactAssets/icon_check.png'
                : '$_exactAssets/icon_circle.png',
            color: selected
                ? DavoColors.of(context).link
                : DavoColors.of(context).muted,
            width: selected ? 22 : 24,
            height: selected ? 22 : 24,
            filterQuality: FilterQuality.high,
          ),
        ],
      ),
    ),
  );
}

class _FaceStepLine extends StatelessWidget {
  const _FaceStepLine(this.text, {this.done = false});
  final String text;
  final bool done;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 22,
    child: Row(
      children: [
        Image.asset(
          done
              ? '$_exactAssets/face_step_done_exact.png'
              : '$_exactAssets/face_step_pending_exact.png',
          width: 16,
          height: 16,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: _t12(context))),
      ],
    ),
  );
}

class _Tier3UploadLargeCard extends StatelessWidget {
  const _Tier3UploadLargeCard({
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onTap,
  });

  final String title, subtitle;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 358,
      height: 139,
      decoration: BoxDecoration(
        color: DavoColors.of(context).primarySoft,
        border: Border.all(color: DavoColors.of(context).border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            done
                ? '$_exactAssets/tier_completed_check_exact.png'
                : '$_exactAssets/tier3_upload_exact.png',
            width: 24,
            height: 24,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(height: 16),
          Text(title, style: _t14b(context)),
          Text(subtitle, style: _t12(context)),
        ],
      ),
    ),
  );
}

class _Tier3UploadSmallCard extends StatelessWidget {
  const _Tier3UploadSmallCard({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String asset, title, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      height: 139,
      decoration: BoxDecoration(
        color: DavoColors.of(context).primarySoft,
        border: Border.all(color: DavoColors.of(context).border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            asset,
            width: 16,
            height: 16,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(height: 16),
          Text(title, style: _t14b(context), textAlign: TextAlign.center),
          Text(subtitle, style: _t12(context), textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _Tier3DocumentUploadCard extends StatelessWidget {
  const _Tier3DocumentUploadCard({required this.uploaded, required this.onTap});
  final bool uploaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 358,
      height: 226,
      decoration: BoxDecoration(
        color: DavoColors.of(context).primarySoft,
        border: Border.all(color: DavoColors.of(context).border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const SizedBox(height: 72),
          Image.asset(
            '$_exactAssets/tier3_upload_exact.png',
            width: 32,
            height: 32,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(height: 16),
          Text('Upload ID Front', style: _t14b(context)),
          Text('JPG, PNG or PDF (Max 5MB)', style: _t12(context)),
        ],
      ),
    ),
  );
}

class _UploadedDocumentFile extends StatelessWidget {
  const _UploadedDocumentFile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    width: 358,
    height: 72,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: BoxDecoration(
      color: DavoColors.of(context).surface,
      border: Border.all(color: DavoColors.of(context).border),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      children: [
        Image.asset(
          '$_exactAssets/profile_document_exact.png',
          width: 24,
          height: 24,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('electricity_bill.pdf', style: _t14b(context)),
              Text('1.2 MB', style: _t12(context)),
            ],
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Image.asset(
            '$_exactAssets/tier3_remove_exact.png',
            width: 24,
            height: 24,
            filterQuality: FilterQuality.high,
          ),
        ),
      ],
    ),
  );
}

class _Tier3DocumentNotice extends StatelessWidget {
  const _Tier3DocumentNotice({required this.uploaded});
  final bool uploaded;

  @override
  Widget build(BuildContext context) => Container(
    width: 358,
    height: 100,
    padding: const EdgeInsets.fromLTRB(9, 16, 8, 16),
    decoration: BoxDecoration(
      color: DavoColors.of(context).warningSurface,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          '$_exactAssets/kyc_info_exact.png',
          width: 18,
          height: 18,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Make sure the document is clear and readable \nAll corners must be visible \nDocument must be recent (within 3 months)\nYour name and address must match your profile',
            style: _t12(context),
          ),
        ),
      ],
    ),
  );
}

Widget _settingsAssetRow(
  BuildContext context,
  String asset,
  String title,
  String subtitle,
  VoidCallback tap,
) => ConstrainedBox(
  constraints: const BoxConstraints(minHeight: 56),
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: InkWell(
      onTap: tap,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: DavoColors.of(context).primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _SettingsOutlineIcon(title),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _t14(context)),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: _t12(context)),
                ],
              ],
            ),
          ),
          Image.asset(
            '$_exactAssets/profile_chevron_exact.png',
            color: DavoColors.of(context).muted,
            width: 16,
            height: 16,
            filterQuality: FilterQuality.high,
          ),
        ],
      ),
    ),
  ),
);

class _CurrentRankCard extends StatelessWidget {
  const _CurrentRankCard();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: 81,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Container(
      decoration: BoxDecoration(
        color: DavoColors.of(context).surface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(8, 19, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: DavoColors.of(context).primarySoft,
              shape: BoxShape.circle,
            ),
            child: Text(
              '#12',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: DavoColors.of(context).link,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 98,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 19,
                  child: Row(
                    children: [
                      Text('Alex M.', style: _t14b(context)),
                      const SizedBox(width: 4),
                      Text('(You)', style: _t14(context)),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: LinearProgressIndicator(
                    value: .62,
                    minHeight: 6,
                    backgroundColor: DavoColors.of(context).primarySoft,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 9),
              child: Text(
                '3  To Next Rank',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DavoColors.of(context).link,
                ),
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '18',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 16,
                    height: 1.05,
                    fontWeight: FontWeight.w700,
                    color: DavoColors.of(context).link,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Referrals', style: _t12(context)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ---- Shared UI ----
class _Shell extends StatelessWidget {
  const _Shell({
    required this.title,
    required this.child,
    this.scroll = false,
    this.showHeaderDivider = false,
    this.titleStyle,
    this.bodyTopPadding = 12,
    this.onBack,
    this.showBack = true,
  });

  final String title;
  final Widget child;
  final bool scroll;
  final bool showHeaderDivider;
  final TextStyle? titleStyle;
  final double bodyTopPadding;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: EdgeInsets.fromLTRB(16, bodyTopPadding, 16, 16),
      child: child,
    );
    return Scaffold(
      backgroundColor: DavoColors.of(context).surface,
      appBar: AppBar(
        backgroundColor: DavoColors.of(context).surface,
        surfaceTintColor: DavoColors.of(context).surface,
        centerTitle: true,
        bottom: showHeaderDivider
            ? PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Divider(
                  key: const ValueKey('profile-header-divider'),
                  height: 1,
                  thickness: 1,
                  color: DavoColors.of(context).divider,
                ),
              )
            : null,
        automaticallyImplyLeading: false,
        leading: !showBack
            ? null
            : IconButton(
                tooltip: 'Back',
                icon: Image.asset(
                  '$_exactAssets/icon_arrow_left.png',
                  color: DavoColors.of(context).ink,
                  width: 24,
                  height: 24,
                  filterQuality: FilterQuality.high,
                ),
                onPressed: onBack ?? () => Navigator.pop(context),
              ),
        title: title.isEmpty
            ? null
            : Text(title, style: titleStyle ?? _navSora20(context)),
      ),
      body: SafeArea(
        top: false,
        child: scroll
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: body,
              )
            : body,
      ),
    );
  }
}

class _SettingsOutlineIcon extends StatelessWidget {
  const _SettingsOutlineIcon(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    final source = const {
      'Personal Information': 'personal',
      'KYC Verification': 'kyc',
      'Linked Accounts': 'linked',
      'Notifications': 'notifications',
      'Privacy': 'privacy',
      'Notification Settings': 'notification-settings',
      'Customer Support': 'support',
      'Privacy Policy': 'policy',
      'FAQs': 'faq',
      'Terms and Condition': 'terms',
      'About Us': 'about',
      'Fingerprint': 'fingerprint',
      'Enable Biometrics': 'fingerprint',
    }[label];
    if (source != null) {
      return SizedBox(
        width: 32,
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/settings/$source.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              DavoColors.of(context).link,
              BlendMode.srcIn,
            ),
          ),
        ),
      );
    }
    final paths = switch (label) {
      'Personal Information' =>
        '<circle cx="12" cy="7" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/>',
      'KYC Verification' =>
        '<path d="m12 3 8 3v6c0 5-8 9-8 9s-8-4-8-9V6z"/><path d="m8 12 3 3 5-6"/>',
      'Linked Accounts' =>
        '<rect x="7" y="3" width="14" height="11" rx="2"/><path d="M7 7h14m-10 4h3M4 8H3a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h13a2 2 0 0 0 2-2v-2M1 14h3m0 4h4"/>',
      'Enable Biometrics' =>
        '<path d="M5 12a7 7 0 0 1 14 0m-11 5v-5a4 4 0 0 1 8 0v6m-4-7v9m-7-4v-1m14 0v4M7 5a9 9 0 0 1 10 0"/>',
      'Change Password' =>
        '<rect x="4" y="10" width="16" height="11" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0m-4 7v3m5-12 2 2 2-2M19 7V3"/>',
      'Transaction Pin' =>
        '<rect x="5" y="2" width="14" height="20" rx="3"/><path d="M9 6h6m-6 4h.01M12 10h.01M15 10h.01M9 14h.01M12 14h.01M15 14h.01M9 18h.01M12 18h.01M15 18h.01"/>',
      'Security questions' =>
        '<path d="M4 4h16v12H9l-5 4zM9 8a3 3 0 1 1 4 3c-1 0-1 1-1 2m0 2h.01"/>',
      'Crypto Security' =>
        '<path d="m12 2 8 3v6c0 5-8 10-8 10S4 16 4 11V5z"/><path d="m8 11 3 3 5-6"/>',
      'Notifications' || 'Notification Settings' =>
        '<path d="M5 17h14l-2-3V9a5 5 0 0 0-10 0v5zM10 21h4"/>',
      'Privacy' ||
      'Privacy Policy' ||
      'Security Alerts' => '<path d="m12 3 8 3v6c0 5-8 9-8 9s-8-4-8-9V6z"/>',
      'Appearance' =>
        '<path d="M12 3a9 9 0 0 1 0 18z" fill="currentColor" stroke="none"/><circle cx="12" cy="12" r="9"/><path d="M12 3v18"/>',
      'Customer Support' =>
        '<path d="M4 13V11a8 8 0 0 1 16 0v7a3 3 0 0 1-3 3h-4"/><rect x="3" y="11" width="4" height="7" rx="2"/><rect x="17" y="11" width="4" height="7" rx="2"/>',
      'FAQs' =>
        '<circle cx="12" cy="12" r="9"/><path d="M9 9a3 3 0 1 1 5 2c-2 1-2 2-2 3m0 3h.01"/>',
      'Terms and Condition' =>
        '<path d="M14 3H5v18h14V8zM14 3v5h5M8 12h8m-8 4h8"/>',
      'About Us' =>
        '<circle cx="12" cy="12" r="9"/><path d="M12 11v6m0-10h.01"/>',
      'Transaction Alerts' =>
        '<path d="M4 7h16m-4-4 4 4-4 4M20 17H4m4-4-4 4 4 4"/>',
      'Marketing & News' =>
        '<path d="M3 10h5l12-6v16L8 14H3zM8 14l2 7H6l-2-7"/>',
      'Logout' => '<path d="M9 4H4v16h5m4-8h8m-4-4 4 4-4 4"/>',
      'Delete Account' =>
        '<path d="M3 6h18M9 6V3h6v3M5 6l1 15h12l1-15M10 10v7m4-7v7"/>',
      _ => '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="3"/>',
    };
    return SizedBox(
      width: 32,
      child: Center(
        child: SvgPicture.string(
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">$paths</g></svg>',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            DavoColors.of(context).link,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  _MenuItem(this.asset, this.label, this.onTap);
  final String asset;
  final String label;
  final VoidCallback onTap;
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({this.title, required this.items});
  final String? title;
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    final general = title == 'GENERAL';
    final top = (title == 'Preferences' || general) ? 20.0 : 16.0;
    final bottom = switch (title) {
      'Accounts' => 24.0,
      'Security' => 8.0,
      'Preferences' => 20.0,
      'GENERAL' => 11.0,
      _ => 16.0,
    };
    final exactHeight = switch (title) {
      'Accounts' => 230.0,
      'Security' => null,
      'Preferences' => 286.0,
      'GENERAL' => 330.0,
      _ => null,
    };
    final titleStyle = general
        ? _sectionLabel14(context)
        : _t16b(context).copyWith(color: DavoColors.of(context).body);

    return Container(
      width: double.infinity,
      height: MediaQuery.textScalerOf(context).scale(14) > 21
          ? null
          : exactHeight,
      padding: EdgeInsets.fromLTRB(12, top, 12, bottom),
      decoration: BoxDecoration(
        color: DavoColors.of(context).offWhite,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: titleStyle),
            const SizedBox(height: 24),
          ],
          for (var i = 0; i < items.length; i++) ...[
            SizedBox(
              height:
                  title == 'Security' ||
                      MediaQuery.textScalerOf(context).scale(14) > 21
                  ? null
                  : 32,
              child: InkWell(
                onTap: items[i].onTap,
                child: Row(
                  children: [
                    _SettingsOutlineIcon(items[i].label),
                    const SizedBox(width: 16),
                    Expanded(child: Text(items[i].label, style: _t14(context))),
                    Image.asset(
                      '$_exactAssets/profile_chevron_exact.png',
                      color: DavoColors.of(context).muted,
                      width: 16,
                      height: 16,
                      filterQuality: FilterQuality.high,
                    ),
                  ],
                ),
              ),
            ),
            if (i != items.length - 1) const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _ProfileActionRow extends StatelessWidget {
  const _ProfileActionRow({
    required this.asset,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });
  final String asset, label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: MediaQuery.textScalerOf(context).scale(14) > 21 ? null : 32,
    child: InkWell(
      onTap: onTap,
      child: Row(
        children: [
          _SettingsOutlineIcon(label),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w400,
                color: destructive
                    ? DavoColors.of(context).danger
                    : DavoColors.of(context).body,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _DavoSwitch extends StatelessWidget {
  const _DavoSwitch({
    required this.value,
    required this.onChanged,
    this.compact = false,
  });
  final bool value, compact;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(52),
    onTap: () => onChanged(!value),
    child: SizedBox(
      width: 48,
      height: 48,
      child: Center(
        child: AnimatedContainer(
          duration: DavoMotionPolicy.reduce(context)
              ? Duration.zero
              : const Duration(milliseconds: 220),
          width: compact ? 40 : 48,
          height: compact ? 22 : 26,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? AppColors.primary : DavoColors.of(context).fieldFill,
            border: Border.all(
              color: value ? AppColors.primary : DavoColors.of(context).border,
            ),
            borderRadius: BorderRadius.circular(52),
          ),
          child: AnimatedAlign(
            duration: DavoMotionPolicy.reduce(context)
                ? Duration.zero
                : const Duration(milliseconds: 220),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: compact ? 16 : 20,
              height: compact ? 16 : 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .12),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _InfoField extends StatelessWidget {
  const _InfoField({required this.label, required this.value, this.trailing});
  final String label, value;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label == 'Date of Birth' || label == 'Full name'
        ? '$label, read only'
        : null,
    child: Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 78),
      margin: const EdgeInsets.only(bottom: 19),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DavoColors.of(context).offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: _personalInfoLabel(context)),
                const SizedBox(height: 8),
                Text(value, style: _t14(context)),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    ),
  );
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Icon(
            Icons.circle,
            size: 6,
            color: DavoColors.of(context).link,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: _t12(context))),
      ],
    ),
  );
}

List<Widget> _cornerFrames() => [
  const Positioned(left: 30, top: 30, child: _Corner()),
  const Positioned(
    right: 30,
    top: 30,
    child: RotatedBox(quarterTurns: 1, child: _Corner()),
  ),
  const Positioned(
    right: 30,
    bottom: 30,
    child: RotatedBox(quarterTurns: 2, child: _Corner()),
  ),
  const Positioned(
    left: 30,
    bottom: 30,
    child: RotatedBox(quarterTurns: 3, child: _Corner()),
  ),
];

class _Corner extends StatelessWidget {
  const _Corner();
  @override
  Widget build(BuildContext context) => Container(
    width: 32,
    height: 32,
    decoration: const BoxDecoration(
      border: Border(
        top: BorderSide(color: Colors.white, width: 2),
        left: BorderSide(color: Colors.white, width: 2),
      ),
    ),
  );
}

class _AccountLimitTile extends StatelessWidget {
  const _AccountLimitTile({
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String flag, title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: DavoColors.of(context).offWhite,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _t14b(context)),
                Text(subtitle, style: _t12(context)),
              ],
            ),
          ),
          Image.asset(
            '$_exactAssets/profile_chevron_exact.png',
            color: DavoColors.of(context).muted,
            width: 16,
            height: 16,
            filterQuality: FilterQuality.high,
          ),
        ],
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill(this.t);
  final String t;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: DavoColors.of(context).primarySoft,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      t,
      style: TextStyle(
        fontFamily: 'Sora',
        fontSize: 10,
        color: DavoColors.of(context).link,
      ),
    ),
  );
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.left,
    required this.right,
    required this.rightSelected,
    required this.onChanged,
  });
  final String left, right;
  final bool rightSelected;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    height: 55,
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: DavoColors.of(context).fieldFill,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Expanded(
          child: _SegButton(left, !rightSelected, () => onChanged(false)),
        ),
        Expanded(
          child: _SegButton(right, rightSelected, () => onChanged(true)),
        ),
      ],
    ),
  );
}

class _SegButton extends StatelessWidget {
  const _SegButton(this.text, this.sel, this.tap);
  final String text;
  final bool sel;
  final VoidCallback tap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: tap,
    child: AnimatedContainer(
      duration: DavoMotionPolicy.reduce(context)
          ? Duration.zero
          : const Duration(milliseconds: 200),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: sel ? DavoColors.of(context).elevated : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Sora',
          fontSize: 12,
          fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
          color: sel
              ? DavoColors.of(context).link
              : DavoColors.of(context).body,
        ),
      ),
    ),
  );
}

Widget _limitBanner(BuildContext context, String t) => Container(
  height: 51,
  padding: const EdgeInsets.symmetric(horizontal: 16),
  alignment: Alignment.centerLeft,
  decoration: BoxDecoration(
    color: DavoColors.of(context).offWhite,
    borderRadius: BorderRadius.circular(6),
  ),
  child: Text(t, style: _t14(context)),
);

class _ProgressLimit extends StatelessWidget {
  const _ProgressLimit(this.title, this.max);
  final String title, max;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: DavoColors.of(context).offWhite,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _t14(context)),
        const SizedBox(height: 14),
        LinearProgressIndicator(
          value: 0,
          minHeight: 7,
          borderRadius: BorderRadius.circular(8),
          backgroundColor: DavoColors.of(context).border,
          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text('0.00 Spent', style: _t12(context)),
            const Spacer(),
            Text('$max Spent', style: _t12(context)),
          ],
        ),
      ],
    ),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard(this.asset, this.title, this.sub, this.tap);
  final String asset, title, sub;
  final VoidCallback tap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: tap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DavoColors.of(context).offWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: DavoColors.of(context).primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              asset,
              width: 22,
              height: 22,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _t14b(context)),
                Text(sub, style: _t12(context)),
              ],
            ),
          ),
          Image.asset(
            '$_exactAssets/profile_chevron_exact.png',
            color: DavoColors.of(context).muted,
            width: 16,
            height: 16,
            filterQuality: FilterQuality.high,
          ),
        ],
      ),
    ),
  );
}

Widget _docOption(BuildContext context, String a, String b) => Container(
  width: double.infinity,
  margin: const EdgeInsets.only(bottom: 12),
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    border: Border.all(color: DavoColors.of(context).border),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(a, style: _t14b(context)),
      const SizedBox(height: 4),
      Text(b, style: _t12(context)),
    ],
  ),
);

class _Input extends StatelessWidget {
  const _Input({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboard,
    this.figmaFilled = false,
    this.labelSize = 14,
    this.hintSize = 14,
    this.hintFontFamily = 'Sora',
    this.maxLength,
    this.inputFormatters,
  });

  final String label, hint;
  final TextEditingController controller;
  final bool figmaFilled;
  final TextInputType? keyboard;
  final double labelSize, hintSize;
  final String hintFontFamily;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: labelSize,
              height: 1.35,
              fontWeight: FontWeight.w400,
              color: DavoColors.of(context).body,
            ),
          ),
          const SizedBox(height: 4),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Semantics(
            label: label,
            child: TextField(
              keyboardAppearance: Theme.of(context).brightness,
              controller: controller,
              keyboardType: keyboard,
              maxLength: maxLength,
              inputFormatters: inputFormatters,
              style: TextStyle(
                fontFamily: hintFontFamily,
                fontSize: hintSize,
                color: DavoColors.of(context).body,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: figmaFilled,
                fillColor: figmaFilled
                    ? DavoColors.of(context).offWhite
                    : DavoColors.of(context).fieldFill,
                hintText: hint,
                counterText: maxLength == null ? null : '',
                hintStyle: TextStyle(
                  fontFamily: hintFontFamily,
                  fontSize: hintSize,
                  color: DavoColors.of(context).bodyMuted,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: DavoColors.of(context).border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: DavoColors.of(context).border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton(
    this.label, {
    required this.onTap,
    this.enabled = true,
    this.disabledBackgroundColor,
  });
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final Color? disabledBackgroundColor;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: enabled
          ? () {
              onTap();
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor:
            disabledBackgroundColor ?? DavoColors.of(context).primaryDisabled,
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Sora',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton(this.label, {required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 48,
    child: TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: DavoColors.of(context).primarySoft,
        foregroundColor: DavoColors.of(context).link,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Sora',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: DavoColors.of(context).offWhite,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How it works', style: _t16b(context)),
        const SizedBox(height: 14),
        const _Step(
          '1',
          'Send Invite',
          'Share your unique link or code with your friends via social media or direct message.',
        ),
        const _Step(
          '2',
          'Friend Joins',
          'Your friend signs up and completes a successful transaction of NGN50,000',
        ),
        const _Step(
          '3',
          'Get Paid',
          'You and your friend get credited with 2,000 Davo Points.',
        ),
      ],
    ),
  );
}

class _Step extends StatelessWidget {
  const _Step(this.n, this.t, this.s);
  final String n, t, s;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: DavoColors.of(context).surface,
          child: Text(
            n,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 10,
              color: DavoColors.of(context).link,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t, style: _t14b(context)),
              Text(s, style: _t12(context)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid(this.items);
  final List<(String, String)> items;
  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 1.8,
    children: items
        .map(
          (e) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DavoColors.of(context).offWhite,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.$1, style: _t12(context)),
                const Spacer(),
                e.$2.startsWith('\u0110')
                    ? DavoPointsAmount(
                        text: e.$2.substring(1),
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: DavoColors.of(context).link,
                        ),
                      )
                    : Text(
                        e.$2,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: DavoColors.of(context).link,
                        ),
                      ),
              ],
            ),
          ),
        )
        .toList(),
  );
}

class _PersonRow extends StatelessWidget {
  const _PersonRow(this.name, this.date, this.status);
  final String name, date, status;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 11),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: DavoColors.of(context).divider)),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: DavoColors.of(context).primarySoft,
          child: Text(
            name.split(' ').map((e) => e[0]).take(2).join(),
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 10,
              color: DavoColors.of(context).link,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: _t14b(context)),
              Text(date, style: _t12(context)),
            ],
          ),
        ),
        _Pill(status),
      ],
    ),
  );
}

class _QuickAssetAction extends StatelessWidget {
  const _QuickAssetAction(this.asset, this.t, this.tap);
  final String asset, t;
  final VoidCallback tap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: tap,
    child: Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: DavoColors.of(context).primarySoft,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              asset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          t,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 9,
            color: DavoColors.of(context).body,
          ),
        ),
      ],
    ),
  );
}

class _Podium extends StatelessWidget {
  const _Podium(this.rank, this.name, this.refs, this.h);
  final String rank, name, refs;
  final double h;

  String get portrait => rank == '1'
      ? '$_exactAssets/leaderboard_podium_center_exact.png'
      : rank == '2'
      ? '$_exactAssets/leaderboard_podium_left_exact.png'
      : '$_exactAssets/leaderboard_podium_right_exact.png';

  @override
  Widget build(BuildContext context) {
    final first = rank == '1';
    final outer = first ? 110.0 : 80.0;
    final inner = first ? 96.0 : 72.0;
    final width = first ? 114.0 : 96.0;
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Container(
            width: outer,
            height: outer,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: DavoColors.of(context).surface,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                portrait,
                width: inner,
                height: inner,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          SizedBox(height: first ? 18 : 17),
          Text(
            name,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: first ? 20 : 16,
              height: 1.35,
              fontWeight: first ? FontWeight.w700 : FontWeight.w600,
              color: DavoColors.of(context).ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            refs,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: first ? 16 : 14,
              height: 1.35,
              fontWeight: first ? FontWeight.w700 : FontWeight.w400,
              color: first
                  ? DavoColors.of(context).link
                  : DavoColors.of(context).body,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: width,
            height: h,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: first
                  ? AppColors.primary
                  : DavoColors.of(context).offWhite,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
            child: Text(
              rank,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: first ? Colors.white : DavoColors.of(context).link,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow(this.rank, this.name, this.school, this.refs);
  final int rank;
  final String name, school, refs;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: 88,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    decoration: BoxDecoration(
      color: DavoColors.of(context).offWhite,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 49,
          child: Text(
            rank.toString().padLeft(2, '0'),
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: DavoColors.of(context).muted,
            ),
          ),
        ),
        const ClipOval(
          child: Image(
            image: AssetImage(_rankPortrait),
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: DavoColors.of(context).ink,
                ),
              ),
              Text(
                school,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t12(context),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 56,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                refs,
                style: _t16b(
                  context,
                ).copyWith(color: DavoColors.of(context).body),
              ),
              Text('Referrals', style: _t12(context)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _HelpCategory extends StatelessWidget {
  const _HelpCategory(this.t, this.s, this.c);
  final String t, s, c;
  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    childrenPadding: const EdgeInsets.only(bottom: 12),
    title: Text(t, style: _t14b(context)),
    subtitle: Text(
      s,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: _t12(context),
    ),
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          '$_exactAssets/profile_chevron_exact.png',
          color: DavoColors.of(context).muted,
          width: 16,
          height: 16,
          filterQuality: FilterQuality.high,
        ),
        Text(
          c,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 9,
            color: DavoColors.of(context).link,
          ),
        ),
      ],
    ),
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(s, style: _t12(context)),
      ),
    ],
  );
}

const _helpCats = <(String, String, String)>[
  (
    'Getting Started',
    'Everything you need to create your Davochain account, verify your identity, and start using the app.',
    '10 Articles',
  ),
  (
    'Wallets & Balances',
    'Learn how your NGN Wallet, USD Wallet, and other balances work, including funding and withdrawals.',
    '12 Articles',
  ),
  (
    'Crypto Trading',
    'Everything about buying, selling, depositing, withdrawing, and managing cryptocurrency on Davochain.',
    '15 Articles',
  ),
  (
    'Gift Card Trading',
    'Learn how to sell gift cards, supported brands, trade processing times, and payment settlements.',
    '14 Articles',
  ),
  (
    'Virtual Cards',
    'Everything you need to know about creating, funding, freezing, and using your Davochain Virtual Card.',
    '13 Articles',
  ),
  (
    'USD Accounts',
    'Learn how to create your USD account, receive international payments, and manage your USD balance.',
    '11 Articles',
  ),
  (
    'Send Money',
    'Learn how to transfer money to Nigerian bank accounts, other Davochain users, and supported destinations.',
    '9 Articles',
  ),
  (
    'Receive Money',
    'Everything about receiving payments into your NGN wallet, USD account, and crypto wallets.',
    '8 Articles',
  ),
  (
    'Bill Payments',
    'Learn how to pay for airtime, data, electricity, cable TV, betting, and other utility bills.',
    '9 Articles',
  ),
  (
    'Rewards & Referrals',
    'Everything about inviting friends, earning referral rewards, campaign bonuses, and reward withdrawals.',
    '7 Articles',
  ),
  (
    'Fees & Transaction Limits',
    'Understand transaction fees, withdrawal fees, trading fees, spending limits, and account limits.',
    '8 Articles',
  ),
  (
    'Verification (KYC)',
    'Everything about identity verification, accepted documents, verification levels, and account limits.',
    '10 Articles',
  ),
  (
    'Security & Account Protection',
    'Learn how to secure your account, reset your password, manage your PIN, enable biometrics, and report suspicious activity.',
    '12 Articles',
  ),
  (
    'Transactions & Receipts',
    'Understand transaction statuses, download receipts, track transfers, and resolve failed transactions.',
    '9 Articles',
  ),
  (
    'Promotions & Campaigns',
    'Stay informed about cashback offers, referral campaigns, seasonal promotions, and eligibility requirements.',
    '6 Articles',
  ),
  (
    'Troubleshooting',
    'Solutions for common issues such as login problems, OTP delays, failed payments, app performance, and wallet errors.',
    '15 Articles',
  ),
  (
    'Contact Support',
    'Find out how to reach the Davochain support team through live chat, email, or by submitting a support ticket.',
    '5 Articles',
  ),
  (
    'Legal & Compliance',
    "Read Davochain's Terms of Service, Privacy Policy, AML policy, prohibited transactions, and regulatory compliance information.",
    '8 Articles',
  ),
];
const _people = <(String, String, String)>[
  ('Jane Doe', 'Oct 24, 2023 • 14:32', 'Rewarded'),
  ('Marcus Kane', 'Oct 24, 2023 • 14:32', 'Pending'),
  ('Sarah Lim', 'Oct 24, 2023 • 14:32', 'Pending'),
  ('Elena Rodriguez', 'Oct 24, 2023 • 14:32', 'Rewarded'),
  ('Julian Smith', 'Oct 24, 2023 • 14:32', 'Pending'),
  ('Lila Vance', 'Oct 24, 2023 • 14:32', 'Pending'),
  ('Marcus Thorne', 'Oct 24, 2023 • 14:32', 'Rewarded'),
];
const _rankings = <(String, String, String)>[
  ('Jordan Smith', 'University of Nigeria Nsukka', '32'),
  ('Elena Rodriguez', 'Obafemi Awolowo University', '30'),
  ('Confidence Malik', 'University of Abuja', '28'),
  ('Samuel Meshack', 'Enugu State University', '25'),
  ('ELite Divine', 'Oko Poly', '22'),
  ('Chidera Favour', 'Akanu Ibiam Federal Poly', '20'),
  ('Success Chidinma', 'Akanu Ibiam Federal Poly', '18'),
];

Future<void> _push(BuildContext c, Widget w) => pushAppPage<void>(c, (_) => w);
void _snack(BuildContext c, String s) => showDavoToast(c, s);
Future<void> _uploadSheet(BuildContext context, String title) =>
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(title, style: _t16b(context)),
              ),
              const SizedBox(height: 18),
              _PrimaryButton('Take a Photo', onTap: () => Navigator.pop(c)),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.pop(c),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: const Text('Choose From Gallery'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Choose a file'),
              ),
            ],
          ),
        ),
      ),
    );
Future<void> _socialDialog(BuildContext context, String s) => showDialog(
  context: context,
  barrierColor: Colors.black.withValues(alpha: .35),
  builder: (d) => Dialog(
    backgroundColor: DavoColors.of(context).surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    insetPadding: const EdgeInsets.symmetric(horizontal: 77),
    child: SizedBox(
      width: 236,
      height: 123,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('“Davochain” Wants to open “$s”', style: _t14(context)),
            const SizedBox(height: 19),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: TextButton(
                      onPressed: () => Navigator.pop(d),
                      style: TextButton.styleFrom(
                        backgroundColor: DavoColors.of(context).divider,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          color: DavoColors.of(context).ink,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: TextButton(
                      onPressed: () => Navigator.pop(d),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        'Open',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
);
Future<void> _logoutDialog(BuildContext context) => showDialog(
  context: context,
  builder: (d) => AlertDialog(
    title: const Text('Logout'),
    content: const Text('Are you sure you want to logout?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(d),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () async {
          await LocalPreviewProfile.instance.signOut();
          if (!d.mounted) return;
          VerificationSession.instance.reset();
          FundingActivity.reset();
          ReceiptActivity.reset();
          SettingsPreviewSession.instance.reset();
          PreviewAuthState.resetSession();
          Navigator.of(d).pushAndRemoveUntil(
            AppPageRoute<void>(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        },
        child: Text(
          'Logout',
          style: TextStyle(color: DavoColors.of(context).danger),
        ),
      ),
    ],
  ),
);
Future<void> _deleteAccountDialog(BuildContext context) =>
    Navigator.of(context).push(
      AppPageRoute<void>(
        builder: (_) => DeleteAccountScreen(
          onSignOut: () {
            SecurityQuestionsService.instance.clear();
            PreviewAuthState.accountEmail = null;
            VerificationSession.instance.reset();
            FundingActivity.reset();
            ReceiptActivity.reset();
            SettingsPreviewSession.instance.reset();
            PreviewAuthState.resetSession();
            Navigator.of(context).pushAndRemoveUntil(
              AppPageRoute<void>(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          },
        ),
      ),
    );

TextStyle _navSora20(BuildContext context) => TextStyle(
  fontFamily: 'Sora',
  fontSize: 20,
  fontWeight: FontWeight.w400,
  color: DavoColors.of(context).body,
  height: 1.35,
);
TextStyle _navSora20Medium(BuildContext context) => TextStyle(
  fontFamily: 'Sora',
  fontSize: 20,
  fontWeight: FontWeight.w500,
  color: DavoColors.of(context).ink,
  height: 1.35,
);
TextStyle _navSora16(BuildContext context) => TextStyle(
  fontFamily: 'Sora',
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: DavoColors.of(context).ink,
  height: 1.35,
);
TextStyle _navSora16Medium(BuildContext context) => TextStyle(
  fontFamily: 'Sora',
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: DavoColors.of(context).ink,
  height: 1.35,
);
TextStyle _navSora16SemiBold(BuildContext context) => TextStyle(
  fontFamily: 'Sora',
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: DavoColors.of(context).ink,
  height: 1.35,
);
TextStyle _t16ProfileSub(BuildContext context) => TextStyle(
  fontFamily: 'Sora',
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: DavoColors.of(context).bodyMuted,
  height: 1.35,
);
TextStyle _personalInfoLabel(BuildContext context) => TextStyle(
  fontFamily: 'Sora',
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: DavoColors.of(context).body,
  height: 1.35,
);
TextStyle _sectionLabel14(BuildContext context) => TextStyle(
  fontFamily: 'Sora',
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: DavoColors.of(context).bodyMuted,
  height: 1.35,
);
TextStyle _t20(BuildContext context) => TextStyle(
  fontFamily: 'Sora',
  fontSize: 20,
  fontWeight: FontWeight.w400,
  color: DavoColors.of(context).ink,
  height: 1.35,
);
TextStyle _t20sb(BuildContext context) => TextStyle(
  fontFamily: 'Sora',
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: DavoColors.of(context).ink,
  height: 1.35,
);
TextStyle _t16(BuildContext context) => TextStyle(
  fontFamily: 'Sora',
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: DavoColors.of(context).ink,
  height: 1.35,
);
TextStyle _t16m(BuildContext context) => TextStyle(
  fontFamily: 'Sora',
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: DavoColors.of(context).ink,
  height: 1.35,
);
TextStyle _t16b(BuildContext context) => TextStyle(
  fontFamily: 'Sora',
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: DavoColors.of(context).ink,
  height: 1.35,
);
TextStyle _t14(BuildContext context) => TextStyle(
  fontFamily: 'Sora',
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: DavoColors.of(context).body,
  height: 1.35,
);
TextStyle _t14m(BuildContext context) => TextStyle(
  fontFamily: 'Sora',
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: DavoColors.of(context).body,
  height: 1.35,
);
TextStyle _t14b(BuildContext context) => TextStyle(
  fontFamily: 'Sora',
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: DavoColors.of(context).ink,
  height: 1.35,
);
TextStyle _t12(BuildContext context) => TextStyle(
  fontFamily: 'Sora',
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: DavoColors.of(context).bodyMuted,
  height: 1.35,
);

const _nigerianStates = [
  'Abia',
  'Adamawa',
  'Akwa Ibom',
  'Anambra',
  'Bauchi',
  'Bayelsa',
  'Benue',
  'Borno',
  'Cross River',
  'Delta',
  'Ebonyi',
  'Edo',
  'Ekiti',
  'Enugu',
  'FCT',
  'Gombe',
  'Imo',
  'Jigawa',
  'Kaduna',
  'Kano',
  'Katsina',
  'Kebbi',
  'Kogi',
  'Kwara',
  'Lagos',
  'Nasarawa',
  'Niger',
  'Ogun',
  'Ondo',
  'Osun',
  'Oyo',
  'Plateau',
  'Rivers',
  'Sokoto',
  'Taraba',
  'Yobe',
  'Zamfara',
];

Widget _toggleRow(
  BuildContext context,
  String t,
  String s,
  bool v,
  ValueChanged<bool> on,
) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 17),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t, style: _t14b(context)),
              const SizedBox(height: 8),
              Text(s, style: _t12(context)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Semantics(
            label: t,
            toggled: v,
            child: _DavoSwitch(value: v, onChanged: on),
          ),
        ),
      ],
    ),
  );
}

Widget _radioChoice(
  BuildContext context,
  String t,
  bool sel,
  VoidCallback tap,
) => InkWell(
  onTap: tap,
  child: Container(
    height: 58,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      border: Border.all(
        color: sel ? AppColors.primary : DavoColors.of(context).border,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Image.asset(
          sel
              ? '$_exactAssets/radio_selected_exact.png'
              : '$_exactAssets/radio_unselected_exact.png',
          color: sel
              ? DavoColors.of(context).link
              : DavoColors.of(context).muted,
          width: 16,
          height: 16,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 12),
        Text(t, style: _t14(context)),
      ],
    ),
  ),
);
Widget _referralBox(BuildContext context) => Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: DavoColors.of(context).offWhite,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('manish1', style: _t14b(context)),
                Text('Your referral code', style: _t12(context)),
              ],
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Copy referral code',
              onPressed: () async {
                await Clipboard.setData(const ClipboardData(text: 'manish1'));
                if (context.mounted) {
                  showDavoToast(context, 'Referral code copied');
                }
              },
              icon: Icon(
                Icons.copy_outlined,
                size: 18,
                color: DavoColors.of(context).link,
              ),
            ),
          ),
        ],
      ),
      const Divider(height: 24),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'https://davochain.com/...',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 12,
                    color: DavoColors.of(context).link,
                  ),
                ),
                Text('Your referral link', style: _t12(context)),
              ],
            ),
          ),
          OutlinedButton(onPressed: () {}, child: const Text('Share')),
        ],
      ),
    ],
  ),
);
Widget _sectionLink(
  BuildContext context,
  String a,
  String b,
  VoidCallback tap,
) => Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: DavoColors.of(context).offWhite,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a, style: _t12(context)),
            Text(b, style: _t14b(context)),
          ],
        ),
      ),
      IconButton(
        onPressed: tap,
        icon: Image.asset(
          '$_exactAssets/profile_chevron_exact.png',
          color: DavoColors.of(context).muted,
          width: 16,
          height: 16,
          filterQuality: FilterQuality.high,
        ),
      ),
    ],
  ),
);

class _LocalProfileGreeting extends StatelessWidget {
  const _LocalProfileGreeting({
    required this.prefix,
    this.suffix = '',
    required this.style,
  });
  final String prefix, suffix;
  final TextStyle style;
  @override
  Widget build(BuildContext context) => DavoListenableBuilder(
    listenable: LocalPreviewProfile.instance,
    builder: (context, _) => Text(
      '$prefix${LocalPreviewProfile.instance.firstName}$suffix',
      style: style,
    ),
  );
}
