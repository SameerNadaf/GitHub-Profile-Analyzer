# GitHub Profile Analyzer

A native macOS application built with SwiftUI that analyzes GitHub profiles, providing insights into user activity, repository quality, and community engagement.

## Features

- **Profile Analysis**: Generates a comprehensive health score based on activity, repository quality, community engagement, profile completeness, and language diversity.
- **Repository Insights**: View detailed lists of repositories with key metrics like stars, forks, and maintenance scores.
- **Search**: Search for any GitHub user to view their profile analysis.
- **Comparison**: Compare two profiles side-by-side to see how they stack up against each other (Coming Soon).

## Architecture

The application follows a clean architecture approach with MVVM + Coordinator patterns:

- **Presentation Layer**: SwiftUI Views and ViewModels driven by the `AppRouter` coordinator for navigation.
- **Domain Layer**: Contains business logic, UseCases (e.g., `FetchProfileUseCase`), and the core `ProfileHealthAnalyzer` logic.
- **Data Layer**: Handles data retrieval through `GitHubAPIClient` and `NetworkClient`, utilizing DTOs for type-safe parsing.
- **Dependency Injection**: A central `DependencyContainer` manages dependencies, complying with the Service Locator pattern for SwiftUI.

## Tech Stack

- **Language**: Swift 5+
- **UI Framework**: SwiftUI
- **Concurrency**: Swift Async/Await
- **Networking**: URLSession
- **Platform**: macOS

## Setup

1. **Clone the repository**:

   ```bash
   git clone https://github.com/your-repo/GitHubProfileAnalyzer.git
   ```

2. **Open in Xcode**:
   Double-click `GitHubProfileAnalyzer.xcodeproj` to open the project.

3. **Configuration**:
   The application uses GitHub OAuth for higher rate limits and authentication.
   - Create or update `GitHubProfileAnalyzer/Config/Secrets.xcconfig`.
   - Add your GitHub Client ID and Secret:
     ```properties
     GITHUB_CLIENT_ID = your_client_id_here
     GITHUB_CLIENT_SECRET = your_client_secret_here
     ```

4. **Run**:
   Select the target `GitHubProfileAnalyzer` and run on your Mac (Cmd+R).

## Requirements

- macOS 13.0 or later
- Xcode 14.0 or later

## License

This project is licensed under the MIT License.
