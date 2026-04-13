# To-Dog-List

## Getting Started

To start, you will need to set up your own Personal API Token from Todoist. We use a local 'Secrets.swift' file to store these credentials so that they aren't pushed to GitHub.

### 1. Get Todoist API Token
1. Log in to Todoist.com
2. Click on your profile picture and go to **Settings**
3. Go to **Integrations** -> **Developer** tab.
4. Copy your **API token** to your clipboard

### 2. Configure Xcode
1. Clone the repo and open the '.xcodeproj' file in Xcode.
2. Create a new Swift file named **exactly** 'Secrets.swift'.
4. Add the following code, replacing the placeholder with your actual token:

    ```swift
    import Foundation
    
    let todoistAPIToken = "PASTE_API_TOKEN_HERE"

## Architecture
- `TodoistAPIManager.swift`: The core networking class that handles all HTTP requests to the Todist v1 API.
- `TodoistTask.swift`: Contains our `Codable` and `Sendable` Swift structs that map the JSON data from Todoist into objects our app can use safely across threads

### Current Capabilities:
- **Read Tasks (GET)**: Fetches the active list of tasks and decodes them from  the `results` wrapper.
