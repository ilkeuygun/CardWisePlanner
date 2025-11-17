# Testing & QA Checklist

## Automated Tests
1. Run networking unit tests (requires network access):
   ```bash
   xcodebuild -scheme CardWisePlanner -destination 'platform=iOS Simulator,name=iPhone 15' test
   ```
   or simply press **⌘U** in Xcode.
2. Verify all tests in `CardWisePlannerTests/NetworkingTests.swift` pass. These hit the live APIs and ensure decoding stays valid.

## Manual Smoke Tests
1. **Launch & Tabs**
   - Build and run on an iOS 17 simulator.
   - Verify all three tabs (Cards, Insights, Calendar) appear with icons and labels.

2. **Card Management**
   - On Cards tab tap the `+` placeholder.
   - Fill out the form and tap Save; new card should appear in carousel.
   - Tap a card to open detail view, edit notes, and save.

3. **Insights**
   - Pull down to refresh; offers list should populate and rankings reorder when multiple cards exist.
   - Confirm FX snapshot shows entries for the base currency.

4. **Calendar**
   - Scroll month view and navigate using chevrons.
   - Tap a day with events to open the sheet, edit note, and save; list should update immediately.
   - Use `+` toolbar to add a custom note to any date.

5. **Holidays & Networking**
   - On Calendar tab ensure "Upcoming holidays" shows data after first load.
   - Disconnect network (or toggle Airplane Mode) and confirm an error banner appears in Insights/Calendar when refreshing.

6. **Persistence**
   - Add a card and a calendar note, stop the app, relaunch, and verify the data is still present (SwiftData persistence).

## Accessibility & UI
- Use Xcode’s Accessibility Inspector to confirm tab items, buttons, and text have labels.
- Toggle light/dark mode in the simulator to ensure styling remains legible.

Document any failures or regressions and attach screenshots/logs when filing issues.
