# Bear Training v1.0 Design Spec

## Context

"How to Become a Bear" is a DeLorme hypertrophy strength training program. It currently lives as an Excel spreadsheet with hand-calculated progressive overload weights across an 8-week cycle. The goal is to turn this into a native iOS app with great design and UX — a guided workout companion that auto-calculates weights, tracks progress, and makes training frictionless. This is the third app in a personal portfolio alongside Simple Habit Tracker and Overdubber.

## Program Structure

The DeLorme method uses 3 sets per exercise at increasing intensity (50%, 75%, 100% of 10RM), with 5 reps per set.

### Exercises (default)
1. **Push-up** — bodyweight progression: regular (50%) → archer (75%) → one-arm (100%). No weight value; intensity maps to variant.
2. **1-Arm Pulldown** — cable, per arm. Weighted with kg increments.
3. **Zercher Squat** — barbell. Weighted with kg increments.

Users can swap any exercise (free). Full program customization is premium.

### Schedule
- 3 days per week: Monday (Heavy), Wednesday (Light), Friday (Medium)
- **Heavy day:** all 3 intensity levels (50%, 75%, 100%) at current week's 10RM. Highest volume.
- **Light day:** only 1 intensity level (50%) but at NEXT week's heavy day target weight. Lowest volume — preparation for next week.
- **Medium day:** 2 intensity levels (50%, 75%) at next week's heavy day target weights. Moderate volume.

This means total sets per session (for 5 series):
- Heavy: 5 series × 3 sets = 15 sets per exercise
- Medium: 5 series × 2 sets = 10 sets per exercise
- Light: 5 series × 1 set = 5 sets per exercise

### Cycles
- **Intro cycle (optional, 2 weeks):** Weeks -1 and 0. Lower series count, meant for finding your 10RM and getting accustomed to the exercises. Week -1: 3/4/5 series across H/L/M. Week 0: 2/7/5 series.
- **Main cycle (6 weeks):** Weeks 1–6. Progressive overload — weights increase each week based on the configured increment per exercise. Series count varies: 5/5/5 for most weeks, with some variation (week 3: 3.2/5/5, week 4: 4/5/5, week 6: 4/4/4).
- **Final test (optional, week 7):** Heavy day only. Test your new 10RM.

### Weight Progression
- Each exercise has an initial 10RM and a weight increment
- Week 1 Heavy: 50% = 0.5 × initial 10RM, 75% = 0.75 × initial 10RM, 100% = initial 10RM
- **Conditional progression:** weight only increases if the previous week's series count was >= 5 (all series completed). If not, the weight stays the same. This is the autoregulation mechanism.
- Formula: `next_100% = IF(prev_series >= 5, prev_100% + increment, prev_100%)`
- Light day 50% weight = next week's heavy 50% weight
- Medium day 50%/75% weights = next week's heavy 50%/75% weights
- Final 10RM = initial 10RM + (n × increment), where n = number of weeks with successful series completion

### Weight Progression Example (Pulldown, initial 10RM = 25kg, increment = 2.5kg)
| Week | Heavy 50% | Heavy 75% | Heavy 100% | Light 50% | Medium 50% | Medium 75% |
|------|-----------|-----------|------------|-----------|------------|------------|
| 1    | 12.5      | 18.75     | 25         | 15        | 15         | 22.5       |
| 2    | 15        | 22.5      | 30         | 16.25     | 16.25      | 24.375     |
| 3    | 16.25     | 24.375    | 32.5       | 17.5      | 17.5       | 26.25      |
| 4    | 17.5      | 26.25     | 35         | 17.5      | 17.5       | 26.25      |
| 5    | 17.5      | 26.25     | 35         | 18.75     | 18.75      | 28.125     |
| 6    | 18.75     | 28.125    | 37.5       | —         | —          | —          |

### Series Count
Series count = how many times to repeat the set block for that day. The set block size depends on day type (Heavy=3 sets, Medium=2, Light=1). Series count is per-exercise and can differ between push-ups and the weighted exercises:

| Week | Push-up Series | Pulldown/Squat Series | Applies to all days (H/L/M) |
|------|---------------|----------------------|----------------------------|
| -1   | 3 / 4 / 5     | 3 / 4 / 5           | H / L / M respectively     |
| 0    | 2 / 7 / 5     | 2 / 7 / 5           | H / L / M respectively     |
| 1–2  | 5             | 5                    | Same across all days        |
| 3    | 3.2           | 5                    | Same across all days        |
| 4    | 4             | 5                    | Same across all days        |
| 5    | 5             | 5                    | Same across all days        |
| 6    | 4             | (not specified, assume 5) | Same across all days  |
| 7    | test          | test                 | Heavy only                  |

**Fractional series (e.g., 3.2):** the target is still full series (5 reps each), but the spreadsheet anticipates that at this weight/volume, the user may fail to complete all reps in later series. The 0.2 represents the expected partial completion (e.g., only getting 1-2 reps on the last series). In the app, the user always attempts full reps — the fractional value is a prediction, not a prescribed rep count. Log actual reps achieved.

### Optional Accessories
Three accessory slots per day type, rotating:
- Heavy: lateral raises, triceps extension, neck
- Light: lateral raises, overhead press, abs
- Medium: lateral raises, cable crossover, rear deltoids

Alternative: superset bench + shrugs, Zercher + deltoids, row + abs.

## App Navigation

### Tab Bar (4 tabs)

1. **Today** — primary screen. Shows today's workout pre-loaded with exercises, sets, and target weights. If no workout scheduled today, shows the next training day. Entry point to the guided workout session.

2. **Program** — full program overview. Grid/timeline of all weeks (intro + main + test). Each week shows 3 day slots with completion status. Current week highlighted. Tap a week to expand and see workout details (exercises, weights, series).

3. **Progress** — three chart sections with segmented control to filter by exercise:
   - Strength: line chart of 10RM progression per exercise over weeks
   - Volume: bar chart of total volume (weight x reps x sets) per session over time
   - Bodyweight: line chart of bodyweight entries over time

4. **Settings** — exercise configuration, unit preference (kg/lbs), rest timer duration (default 90s), bodyweight log entry, premium purchase/restore, iCloud sync toggle, HealthKit permissions, themes, about/support.

### Workout Session Flow

1. User taps "Start Workout" on Today tab
2. Session timer begins. Screen shows exercise cards in sequence.
3. Each exercise card displays:
   - Exercise name and variant/weight for each set
   - Set rows depend on day type: Heavy shows 3 rows (50%/75%/100%), Medium shows 2 (50%/75%), Light shows 1 (50%)
   - Sets repeat for each series (e.g., Heavy with 5 series = 15 total sets per exercise)
4. Tap a set row → marked complete with checkmark + haptic feedback
5. Rest timer auto-starts → Live Activity appears on lock screen with countdown
6. When rest timer ends → haptic notification, next set highlighted
7. User can adjust actual weight/reps if they deviated from target (tap to edit)
8. Swipe or scroll to next exercise
9. After all sets complete → "Finish Workout" button
10. Summary screen: duration, total volume, sets completed, PRs hit
11. Session saved to SwiftData + written to HealthKit

### Onboarding Flow

1. Welcome screen — app name, bear icon, tagline
2. "Set up your program" — enter 10RM for each of the 3 exercises. Brief explanation of what 10RM means ("the most weight you can lift for 10 reps with good form"). Push-up asks user to select their current level (regular/archer/one-arm).
3. Configure: weight unit (kg/lbs), start day preference, include intro cycle (yes/no)
4. Optional: enter current bodyweight
5. Program generated → "Ready to train" → lands on Today tab

## Data Model

### SwiftData Entities

**Program** (`@Model`)
- `id: UUID`
- `startDate: Date`
- `currentWeek: Int` (–1 to 7)
- `introCycleEnabled: Bool`
- `restTimerDuration: Int` (seconds, default 90)
- `exercises: [Exercise]` (relationship)
- `sessions: [WorkoutSession]` (relationship)

**Exercise** (`@Model`)
- `id: UUID`
- `name: String`
- `type: ExerciseType` (enum: bodyweight, weighted)
- `initial10RM: Double`
- `final10RM: Double`
- `weightIncrement: Double`
- `unit: WeightUnit` (enum: kg, lbs)
- `sortOrder: Int`
- `program: Program` (relationship)

**WorkoutSession** (`@Model`)
- `id: UUID`
- `date: Date`
- `weekNumber: Int`
- `dayType: DayType` (enum: heavy, light, medium)
- `duration: TimeInterval`
- `isCompleted: Bool`
- `completedSets: [CompletedSet]` (relationship)
- `program: Program` (relationship)

**CompletedSet** (`@Model`)
- `id: UUID`
- `exerciseName: String`
- `seriesNumber: Int`
- `setNumber: Int` (1, 2, 3 for 50%, 75%, 100%)
- `targetWeight: Double`
- `actualWeight: Double`
- `targetReps: Int`
- `actualReps: Int`
- `intensity: Double` (0.5, 0.75, 1.0)
- `isCompleted: Bool`
- `completedAt: Date?`
- `session: WorkoutSession` (relationship)

**BodyweightEntry** (`@Model`)
- `id: UUID`
- `date: Date`
- `weight: Double`
- `unit: WeightUnit`

### DeLorme Engine

Pure calculation layer — no persistence, no side effects.

```
struct DeLormeEngine {
    static func generateWorkout(
        exercises: [Exercise],
        week: Int,
        dayType: DayType,
        previousSeriesCounts: [Int]  // per exercise, for conditional progression
    ) -> [PlannedExercise]
    
    // Returns the 100% (10RM) weight for a given week, accounting for conditional progression
    static func calculate10RM(
        initial10RM: Double,
        increment: Double,
        weeklySeriesHistory: [Int]  // series completed each prior week
    ) -> Double
    
    // Returns intensity levels for a day type: Heavy=[0.5,0.75,1.0], Medium=[0.5,0.75], Light=[0.5]
    static func intensityLevels(for dayType: DayType) -> [Double]
    
    // Light/Medium use NEXT week's heavy weights; Heavy uses current week's
    static func calculateSetWeight(
        tenRM: Double,
        nextWeekTenRM: Double,
        dayType: DayType,
        intensity: Double
    ) -> Double
    
    static func seriesCount(
        week: Int,
        dayType: DayType,
        exerciseType: ExerciseType  // push-up series differ from weighted
    ) -> Double  // Double to support fractional (3.2)
    
    static func pushUpVariant(intensity: Double) -> String
}
```

## Visual Design

### Direction
- **Dark-first** — gym-friendly, easy on eyes between sets
- **Bold typography** — weights and set numbers must be readable at arm's length
- **Accent color** — warm amber/gold (#F5A623 range), evokes strength
- **Bear branding** — app icon features bear silhouette, subtle bear touches in onboarding
- **Minimal chrome** — cards with generous spacing, no unnecessary borders or decoration
- **Haptic feedback** — on set completion, workout finish, PR achievement (same pattern as Simple Habits)

### Themes
- **Default dark** (free) — dark background, amber accents
- **2–3 additional themes** (premium) — managed by ThemeManager (same pattern as other apps)

## Monetization

### Free Tier
- Full Bear program (intro + 6 weeks + test)
- Swappable exercises (replace any core lift with an alternative)
- Guided workout sessions with single-tap logging
- Rest timer with Live Activities
- Progress charts (strength, volume, bodyweight)
- HealthKit integration
- Apple Watch companion
- Banner ads (not during active workout sessions)
- Interstitial ads between sessions (with first-session grace period)
- Last 2 completed programs retained

### Premium (one-time IAP ~$3.99)
- Full program customization (days/week, set/rep schemes, add exercises, change series counts)
- Ad removal
- iCloud sync across devices via CloudKit
- Additional themes
- Unlimited program history

### Implementation
- AdMob via GoogleMobileAds SPM (reuse AdManager pattern)
- StoreKit 2 via PurchaseManager (reuse pattern from Simple Habits / Overdubber)
- No ads shown during active workout sessions (universally hated)

## Platform Features

### HealthKit
- Write `.traditionalStrengthTraining` workout after each completed session
- Include: duration, estimated calories, exercise metadata
- Read bodyweight from Health (user can opt in during onboarding)
- Write bodyweight entries logged in-app back to Health
- Request permissions contextually (not at launch)

### Apple Watch Companion
- Mirrors the active workout session from iPhone
- Displays: current exercise, set number, target weight/reps
- Tap to complete set → triggers rest timer on watch face
- Haptic tap when rest timer completes
- Syncs via WatchConnectivity framework
- Minimal standalone functionality — requires iPhone for program management

### iCloud Sync (Premium)
- SwiftData + CloudKit container
- Syncs: Program, Exercise, WorkoutSession, CompletedSet, BodyweightEntry
- Same pattern as Simple Habit Tracker

### Live Activities (Rest Timer)
- ActivityKit for lock screen rest timer
- Shows: time remaining, current exercise name, next set info
- Auto-starts when a set is completed
- Dismisses when rest period ends or user taps to skip

## Technical Stack

- **UI:** SwiftUI, iOS 17.0+
- **Architecture:** MVVM + @Observable
- **Persistence:** SwiftData + CloudKit (premium)
- **IAP:** StoreKit 2
- **Ads:** Google AdMob (GoogleMobileAds SPM)
- **Charts:** Swift Charts framework
- **Timer:** ActivityKit (Live Activities)
- **Health:** HealthKit
- **Watch:** WatchKit + WatchConnectivity
- **Dependencies:** GoogleMobileAds only (zero other external deps)

### Project Structure
```
BearTraining/
├── App/                    — BearTrainingApp, ContentView
├── Models/                 — SwiftData models, enums (DayType, ExerciseType, WeightUnit)
├── Engine/                 — DeLormeEngine (pure program calculation)
├── ViewModels/             — WorkoutViewModel, ProgramViewModel, ProgressViewModel
├── Views/
│   ├── Today/              — TodayView, WorkoutSessionView, SetRowView, ExerciseCardView
│   ├── Program/            — ProgramOverviewView, WeekDetailView
│   ├── Progress/           — ProgressView, StrengthChartView, VolumeChartView, BodyweightChartView
│   ├── Settings/           — SettingsView, ExerciseConfigView, PaywallView
│   ├── Onboarding/         — OnboardingFlow, WelcomeView, SetupView
│   └── Components/         — SharedComponents (buttons, cards, timer display)
├── Utilities/              — ThemeManager, AdManager, PurchaseManager, HealthKitManager, TimerManager
├── LiveActivity/           — ActivityKit widget extension
├── Watch/                  — WatchKit extension (WatchApp, WatchWorkoutView)
└── Resources/              — Assets, colors, fonts
```

### ViewModels

**WorkoutViewModel** (`@Observable, @MainActor`)
- Manages active workout session state
- Generates today's workout via DeLormeEngine
- Handles set completion, rest timer, session saving
- Communicates with Watch via WatchConnectivity
- Writes to HealthKit on session completion

**ProgramViewModel** (`@Observable`)
- Manages program configuration and week progression
- Handles exercise swapping (free) and full customization (premium)
- Tracks program completion status per week/day

**ProgressViewModel** (`@Observable`)
- Queries completed sessions for chart data
- Computes strength progression, volume trends, bodyweight history
- Filters by exercise and time range

## Verification

### How to test end-to-end
1. Launch app → complete onboarding with test 10RM values
2. Start a workout → verify correct weights calculated for each set
3. Complete all sets → verify rest timer + Live Activity works
4. Finish workout → verify session saved, HealthKit entry written
5. Check Program tab → verify week/day marked complete
6. Check Progress tab → verify charts show the completed session data
7. Advance to next week → verify weight progression matches spreadsheet
8. Test Apple Watch → verify set completion syncs
9. Purchase premium → verify ads removed, iCloud sync enabled, themes unlocked
10. Compare all generated weights against the original spreadsheet for weeks -1 through 7
