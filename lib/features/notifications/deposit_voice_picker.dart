import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'deposit_voice.dart';
import 'notification_runtime.dart';

class DepositVoicePicker extends StatefulWidget {
  const DepositVoicePicker({super.key, required this.runtime});
  final NotificationRuntime runtime;
  @override
  State<DepositVoicePicker> createState() => _DepositVoicePickerState();
}

class _DepositVoicePickerState extends State<DepositVoicePicker> {
  late final voices = widget.runtime.phone.depositVoices();
  @override
  void dispose() {
    widget.runtime.phone.stopSpeaking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phone = widget.runtime;
    final colors = DavoColors.of(context);
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .78,
        child: AnimatedBuilder(
          animation: phone,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 8, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Deposit announcement',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close voice picker',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  children: [
                    const Text(
                      '"Payment received in Davochain"',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Voice style',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final style in DepositVoiceStyle.values)
                          ChoiceChip(
                            label: Text(style.label),
                            tooltip: style.description,
                            selected:
                                phone.preferences.depositVoiceStyle == style,
                            onSelected: (_) => phone.chooseDepositVoice(
                              phone.preferences.depositVoiceId,
                              style,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      phone.preferences.depositVoiceStyle.description,
                      style: TextStyle(fontSize: 12, color: colors.body),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'English voices on your phone',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<DepositVoiceOption>>(
                      future: voices,
                      builder: (context, snapshot) {
                        final options = snapshot.data ?? <DepositVoiceOption>[];
                        Widget option(
                          String? id,
                          String label,
                          String detail,
                        ) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            label,
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Text(
                            detail,
                            style: const TextStyle(fontSize: 11),
                          ),
                          selected: phone.preferences.depositVoiceId == id,
                          trailing: phone.preferences.depositVoiceId == id
                              ? Icon(Icons.check_circle, color: colors.link)
                              : const Icon(Icons.circle_outlined, size: 22),
                          onTap: () => phone.chooseDepositVoice(
                            id,
                            phone.preferences.depositVoiceStyle,
                          ),
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            option(
                              null,
                              'Phone default',
                              'Use your current English voice',
                            ),
                            if (snapshot.connectionState !=
                                ConnectionState.done)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            for (final voice in options)
                              option(
                                voice.id,
                                voice.label,
                                voice.offline
                                    ? 'Works offline'
                                    : 'Internet required',
                              ),
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                options.isEmpty)
                              Text(
                                'No additional English voices found. You can still try the styles with your phone default.',
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: colors.body,
                                ),
                              ),
                            if (phone.preferences.depositVoiceId != null &&
                                snapshot.connectionState ==
                                    ConnectionState.done &&
                                !options.any(
                                  (voice) =>
                                      voice.id ==
                                      phone.preferences.depositVoiceId,
                                ))
                              Text(
                                'Your saved voice is unavailable. Phone default will be used until you choose another.',
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: colors.body,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: FilledButton.icon(
                  icon: const Icon(Icons.volume_up_outlined),
                  label: Text(
                    phone.voiceBusy
                        ? 'Preparing voice...'
                        : 'Preview announcement',
                  ),
                  onPressed:
                      !phone.initialized ||
                          phone.voiceBusy ||
                          !phone.channelAllowed(0)
                      ? null
                      : () async {
                          final played = await phone.testDepositVoice();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                played
                                    ? 'Voice preview requested.'
                                    : 'Could not play. Check phone sound, deposit notifications and your English voice.',
                              ),
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
