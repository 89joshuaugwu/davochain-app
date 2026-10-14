part of 'gift_card_flow.dart';

class _DeliverySegment extends StatelessWidget {
  const _DeliverySegment(
      {required this.label,
      required this.asset,
      required this.active,
      required this.onTap});
  final String label;
  final String asset;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
          duration: DavoMotionPolicy.reduce(context)
              ? Duration.zero
              : const Duration(milliseconds: 180),
          height: 48,
          decoration: BoxDecoration(
              color: active
                  ? DavoColors.of(context).primarySoft
                  : DavoColors.of(context).offWhite,
              border: Border.all(
                  color: active
                      ? AppColors.primary
                      : DavoColors.of(context).border),
              borderRadius: BorderRadius.circular(6)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(asset,
                color: active
                    ? DavoColors.of(context).link
                    : DavoColors.of(context).body,
                width: 22,
                height: 22),
            const SizedBox(width: 7),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    color: active
                        ? AppColors.primary
                        : DavoColors.of(context).body,
                    fontWeight: FontWeight.w600))
          ])));
}

class _IconTextField extends StatelessWidget {
  const _IconTextField(
      {required this.asset,
      required this.controller,
      required this.hint,
      required this.keyboard});
  final String asset;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboard;
  @override
  Widget build(BuildContext context) => Focus(
      child: Builder(
          builder: (context) => Container(
              height: 50,
              decoration: _fieldDecoration(context).copyWith(
                  border: Border.all(
                      color: Focus.of(context).hasFocus
                          ? AppColors.primary
                          : DavoColors.of(context).border)),
              child: Row(children: [
                const SizedBox(width: 12),
                Image.asset(asset,
                    color: DavoColors.of(context).bodyMuted,
                    width: 20,
                    height: 20),
                const SizedBox(width: 8),
                Expanded(
                    child: TextField(
                        keyboardAppearance: Theme.of(context).brightness,
                        controller: controller,
                        keyboardType: keyboard,
                        decoration: DavoInlineInputDecoration(hintText: hint),
                        style: _body14(context))),
                const SizedBox(width: 12)
              ]))));
}

class _DeliveryChoice extends StatelessWidget {
  const _DeliveryChoice(
      {required this.title,
      required this.subtitle,
      required this.active,
      required this.onTap});
  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: DavoMotionPolicy.reduce(context)
              ? Duration.zero
              : const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: DavoColors.of(context).surface,
            border: Border.all(
                color:
                    active ? AppColors.primary : DavoColors.of(context).border,
                width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: DavoColors.of(context).primarySoft,
                  borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center,
              child: Image.asset('$_g/lightning.png',
                  width: 16, height: 16, fit: BoxFit.contain),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title, style: _section(context)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: _caption(context))
                ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: DavoColors.of(context).primarySoft,
                  borderRadius: BorderRadius.circular(10)),
              child: Text('Free',
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 10,
                      color: DavoColors.of(context).link,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      );
}

class _GiftDeliverySummary extends StatelessWidget {
  const _GiftDeliverySummary({required this.delivery});
  final GiftDelivery delivery;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(delivery.forMe ? 'For Me' : 'Send Gift', style: _section(context)),
        const SizedBox(height: 6),
        Text(delivery.methodLabel, style: _body14(context)),
        if (delivery.email.isNotEmpty)
          Text(delivery.email, style: _body14(context)),
        if (delivery.phone.isNotEmpty)
          Text(delivery.phone, style: _body14(context)),
      ]));
}
