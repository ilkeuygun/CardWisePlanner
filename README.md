# CardWise Planner

Financial planning companion that optimizes revolving-credit usage windows, guides real-time card selection, and surfaces billing events in a calendar-friendly timeline.

## Problem & Audience
- **Problem:** Juggling multiple credit cards with staggered billing cycles leads to suboptimal spending choices and missed payments.
- **Audience:** Credit-savvy consumers, digital nomads managing multiple currencies, and budgeting enthusiasts who want clarity over card terms.

## Core Experience
1. **Cards Tab**
   - Carousel of empty "Add Card" slots and saved cards.
   - Card creation captures name, issuer, masked number, billing window length, statement-close day, and due date.
   - Detail sheet supports editing metadata plus notes on statement/due dates.
2. **Insights Tab**
   - Ranks cards by remaining days until the current cycle closes (furthest first).
   - Surfaces contextual insights: FX rates (card currency vs. base), network card-offer tips, and upcoming holidays that may affect spending.
3. **Calendar Tab**
   - Month grid highlighting statement and due dates, enriched with holiday overlays.
   - Tapping a date presents editable notes (statement, due, or custom events) with persistence.
   - Supports filtering per card and global view.

## Curriculum Alignment & Techniques
| Requirement | Implementation |
| --- | --- |
| SwiftUI Navigation | `TabView` + stack-based detail navigation |
| Data Persistence | SwiftData models (`CreditCardAccount`, `BillingEvent`) |
| Concurrency | `Task`-driven refresh flows for recommendations & APIs |
| Networking & URLSession | `ExchangeRateService`, `CardOffersService`, `HolidayCalendarService` |
| Error Handling | User-facing banners, retry buttons, offline caching |
| Splash & Custom Icon | Launch screen storyboard, asset catalog icons |

## Feature Roadmap & Checkpoints
- **Checkpoint 1 (Week 4):** Finalize concept (this README), baseline repo, early mockups.
- **Checkpoint 2 (Week 5):** Project scaffolding, navigation skeleton, splash/icon assets.
- **Checkpoint 3 (Week 6):** Mock data flow, state management syncing tabs.
- **Checkpoint 4 (Week 7):** Persistence wiring, API integrations, concurrency polish.
- **Final Submission (Week 8):** Complete feature set, QA, video walkthrough, GitHub PR.

## Technology Stack
- Swift 5.10, SwiftUI, SwiftData, Combine (as needed)
- URLSession with async/await
- SF Symbols, Asset Catalog, Launch Screen storyboard
- Xcode 16, Git + GitHub for version control

## Networking Targets
| API | Purpose |
| --- | --- |
| [ExchangeRate.host](https://exchangerate.host) | Card currency conversions & rate trends |
| [RapidAPI Card Offers sample](https://rapidapi.com) | Fetch rotating credit-card offer tips |
| [Nager.Date Public Holidays](https://date.nager.at) | Country holiday overlays on calendar |

## Design Inspiration
- Human Interface Guidelines (Finance & Productivity patterns)
- Material-inspired cards with subtle depth, large typography for due dates
- Calendar interactions modeled after Apple Calendar for familiarity

## Next Steps
1. Generate low-fi wireframes (Figma link TBD) and attach screenshots in future README updates.
2. Scaffold SwiftUI project with launch assets, icon set, and sample data.
3. Iterate on networking mocks + persistence before integrating full UI polish.

