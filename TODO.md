# TODO: Resolve Flutter Diagnostics

## Issues to Fix:
1. **main.dart (line 97)**: use_build_context_synchronously - Add mounted check after async gap in _goToMenu method.
2. **version_block_screen.dart (lines 78, 111, 151)**: deprecated_member_use - Replace `withOpacity` with `withValues()`.
3. **api_service.dart (multiple lines)**: avoid_print - Replace `print` statements with `debugPrint`.
4. **version_service.dart (multiple lines)**: avoid_print - Replace `print` statements with `debugPrint`.

## Steps:
- [ ] Fix main.dart: Add mounted check in _goToMenu after await.
- [ ] Fix version_block_screen.dart: Replace three instances of withOpacity.
- [ ] Fix api_service.dart: Replace all print with debugPrint.
- [ ] Fix version_service.dart: Replace all print with debugPrint.
- [ ] Verify all diagnostics are resolved.
