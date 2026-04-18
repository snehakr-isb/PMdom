# PM Daily Questions

An iOS app with home-screen widget that delivers daily Product Manager learning questions — powered by Claude AI.

## What it does

- **Daily 10-question sessions** across 4 categories: Interview Prep (40%), PM Frameworks (30%), Current Events (20%), AI & Tech (10%)
- **6 question formats**: Multiple choice, True/False, Fill-in-blank, Scenario, Matching, Ordering
- **Gamification**: Streaks with freeze mechanic, XP + 7-level progression, weekly leaderboard tiers
- **Spaced repetition**: SM-2 algorithm resurfaces questions you need to review
- **iOS Widget**: 3 sizes (small/medium/large) showing streak, progress, and leaderboard
- **Claude API**: Daily question generation via Supabase Edge Function

## Setup (Mac required for Xcode)

### 1. Generate the Xcode project

```bash
brew install xcodegen
cd /path/to/PMdom
xcodegen generate
open PMDailyQuestions.xcodeproj
```

### 2. Configure App Group

In Xcode → Signing & Capabilities, add App Group `group.com.pmquestions.shared` to **both** the main app target and the widget extension target.

### 3. Supabase setup (optional for v1)

```bash
npx supabase init
npx supabase db push  # runs supabase/schema.sql
npx supabase functions deploy generate-questions
npx supabase secrets set ANTHROPIC_API_KEY=your_key_here
```

Schedule the Edge Function daily via Supabase Dashboard → Edge Functions → Cron.

### 4. Run on device

Select your iPhone as the build target, hit Run. The app ships with 20 seed questions so it works fully offline.

## Architecture

```
Views (SwiftUI)
    ↕
ViewModels (@Observable)
    ↕
Repositories (QuestionRepository, ProgressRepository, LeaderboardRepository)
    ↕
Data Sources: SwiftData (local) | Supabase REST (remote) | App Group (widget)
```

## Build Sprints

| Sprint | Status | Description |
|--------|--------|-------------|
| 1 | ✅ | SwiftData models + App Group + seed JSON |
| 2 | ✅ | Full session loop (all 6 question types) |
| 3 | ✅ | Home screen + XP/Streak/Achievements |
| 4 | ✅ | Daily mix (interleaved) + SM-2 spaced repetition |
| 5 | ✅ | Widget (small/medium/large) |
| 6 | ✅ | Leaderboard + Skill Paths + Profile + Onboarding |
| 7 | ⬜ | Supabase live sync + Claude API question generation |

## Tech Stack

- **iOS 17+** (required for SwiftData + interactive widgets)
- **Swift 5.9 / SwiftUI**
- **SwiftData** for local persistence
- **WidgetKit** for home-screen widgets
- **Supabase** for question DB + Edge Functions
- **Claude API (claude-sonnet-4-6)** for question generation
