# Keyboard focus investigation

The application-level `Listener` in `lib/app.dart` dismissed focus on pointer
down outside the current editable render box. A tap on another field therefore
closed the current input connection before the destination's tap handler could
request focus. Password visibility controls also sit outside that editable
box, so tapping the eye control dismissed the keyboard while toggling visibility.

`test/keyboard_focus_continuity_test.dart` reproduces both cases through the real
application and login screen. Both tests failed before the change: the currently
focused field lost focus. The replacement application-level `GestureDetector`
dismisses focus after a background tap wins the gesture, allowing text fields
and their suffix controls to handle their own taps.

`test/amount_toast_keyboard_test.dart` retains the existing background dismissal
and subsequent field focus coverage. The focused regression also verifies that
typing remains connected after changing password visibility.

The source audit found no custom keyboard slide animation, delayed keyboard
opening, or focus timer on the initial tap path. The Android activity uses
`adjustResize` and hardware acceleration; keyboard insets resize the scaffolds
directly. Auth forms use intrinsic layout, but its presence alone does not
establish a measurable first-opening delay. Native keyboard animation speed and
physical-phone responsiveness require device profiling and remain unverified.
This change addresses the reproduced input connection interruption, not a
measured native first-opening animation slowdown.
