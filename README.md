# To-Dog-List

To-Dog-List is a SwiftUI productivity game: complete Todoist tasks, level up your account, and unlock collectible dogs with rarity tiers.

## Current Features

- Account registration and login with local persistence (`UserDefaults`)
- Tab-based app flow: `Tasks`, `Dogs`, and `Profile`
- Full Todoist task flow:
  - Fetch tasks
  - Create tasks
  - Edit task content
  - Toggle complete/reopen
  - Delete tasks
- Pull-to-refresh and manual refresh for task syncing
- Reward loop: leveling up can unlock a random dog reward
- Dog collection screen with image loading and rarity badges (Common, Rare, Epic)
- Profile progression stats:
  - Current level and progress to next level
  - Completed task totals
  - Total dogs collected
- Settings screen with logout and confirmation dialog

## Tech Stack

- SwiftUI app entry: `To_Dog_ListApp.swift`
- Networking via `URLSession`
- Todoist REST API v1 (`TodoistAPIManager.swift`)
- Dog image API via [dog.ceo](https://dog.ceo/) (`RewardDog.swift`)
- Local user persistence and progression engine (`UserDatabase.swift`, `User.swift`)

## Project Structure

- `To-Dog-List/To-Dog-List.xcodeproj` - Xcode project
- `To-Dog-List/To-Dog-List/*.swift` - App source files
- `README.md` - Project documentation (this file)

## Getting Started

### 1) Clone and open in Xcode

1. Clone this repository.
2. Open `To-Dog-List/To-Dog-List.xcodeproj` in Xcode.
3. Select an iOS Simulator and run.

### 2) Configure your Todoist API token

The app currently reads the token from `TodoistAPIManager.swift` in the `apiToken` constant.

1. Log in to Todoist.
2. Go to **Settings -> Integrations -> Developer**.
3. Copy your API token.
4. Replace the `apiToken` value in `TodoistAPIManager.swift` with your token.

## Notes

- User accounts and progression are stored locally on-device using `UserDefaults`.
- Dog rewards are granted on level-up from completed unique tasks.
- If task API calls fail, the UI surfaces an error alert and keeps existing local UI state.
