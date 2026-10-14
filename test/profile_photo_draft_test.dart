import 'package:davochain/core/preview/local_preview_profile.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:davochain/shared/widgets/local_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void main() {
  final profile = LocalPreviewProfile.instance;
  setUp(profile.loginSample);
  tearDown(profile.loginSample);

  testWidgets('settings avatar is read only on tap', (tester) async {
    final original = ImagePickerPlatform.instance;
    final picker = _PhotoSelection();
    ImagePickerPlatform.instance = picker;
    addTearDown(() => ImagePickerPlatform.instance = original);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const ProfileSettingsScreen()));
    await tester.tap(find.byType(LocalProfileAvatar));
    await tester.pumpAndSettle();
    expect(picker.requests, 0);
    expect(profile.photo, isNull);
  });

  for (final registered in [false, true]) {
    for (final save in [false, true]) {
      testWidgets(
          '${registered ? 'registered' : 'sample'} personal photo is a draft until ${save ? 'Save Changes' : 'discarded'}',
          (tester) async {
        if (registered) {
          profile.register(
              name: 'Ada Obi',
              email: 'ada@example.com',
              phone: '+234 8012345678');
        }
        tester.view.physicalSize = const Size(430, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final data = await rootBundle.load('assets/figma_exact/steam.png');
        final bytes = data.buffer.asUint8List();
        final original = ImagePickerPlatform.instance;
        final picker = _PhotoSelection(bytes);
        ImagePickerPlatform.instance = picker;
        addTearDown(() => ImagePickerPlatform.instance = original);
        await tester.pumpWidget(MaterialApp(
            theme: AppTheme.light, home: const PersonalInformationV12Screen()));
        await tester.ensureVisible(find.text('Edit Information'));
        await tester.tap(find.text('Edit Information'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(LocalProfileAvatar));
        await tester.runAsync(() async {
          await tester.tap(find.byType(LocalProfileAvatar));
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });
        await tester.pumpAndSettle();
        expect(picker.requests, 1);
        expect(profile.photo, isNull);
        expect(
            tester
                .widgetList<Image>(find.byType(Image))
                .any((image) => image.image is MemoryImage),
            isTrue);
        if (save) {
          expect(
              tester
                  .widget<ElevatedButton>(
                      find.widgetWithText(ElevatedButton, 'Save Changes'))
                  .onPressed,
              isNotNull);
          if (registered) {
            await tester.enterText(find.byType(TextField), 'bad!');
            await tester.pump();
            expect(
                tester
                    .widget<ElevatedButton>(
                        find.widgetWithText(ElevatedButton, 'Save Changes'))
                    .onPressed,
                isNull);
            await tester.enterText(find.byType(TextField), '');
            FocusManager.instance.primaryFocus?.unfocus();
            await tester.pumpAndSettle();
            expect(
                tester
                    .widget<ElevatedButton>(
                        find.widgetWithText(ElevatedButton, 'Save Changes'))
                    .onPressed,
                isNotNull);
          }
          await tester.ensureVisible(find.text('Save Changes'));
          await tester.tap(find.text('Save Changes'));
          await tester.pumpAndSettle();
          expect(profile.photo, orderedEquals(bytes));
        } else {
          await tester.pumpWidget(const SizedBox());
          expect(profile.photo, isNull);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}

class _PhotoSelection extends ImagePickerPlatform {
  _PhotoSelection([this.bytes]);
  final Uint8List? bytes;
  int requests = 0;
  @override
  Future<XFile?> getImageFromSource(
      {required ImageSource source,
      ImagePickerOptions options = const ImagePickerOptions()}) async {
    requests++;
    return bytes == null
        ? null
        : XFile.fromData(bytes!, name: 'profile.png', mimeType: 'image/png');
  }
}
