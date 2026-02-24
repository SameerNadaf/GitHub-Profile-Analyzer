# 📊 GitHub Profile Analyzer

A native macOS application built with SwiftUI that deeply analyzes GitHub profiles, providing actionable insights into user activity patterns, repository quality, language diversity, and community engagement.

---

## 🚀 Features

- **Holistic Profile Analysis**: Generates a comprehensive "Health Score" (0-100) analyzing multiple facets of a GitHub profile.
- **Detailed Activity Tracking**: Monitors commit frequency, consistency, and patterns to determine activity trends (e.g., Highly Active, Dormant).
- **Repository Insights**: Evaluates repositories for maintenance quality, fork ratio, and star distribution.
- **Community Engagement**: Categorizes users from "Newcomer" to "Influencer" based on follower ratios and community reach.
- **Language Diversity**: Visualizes the primary programming languages utilized across all repositories.
- **Smart Navigation**: Smooth searching, recent search history, and contextual routing using a declarative Coordinator pattern.
- **Compare Profiles (Phase 3)**: A dedicated workflow to compare two GitHub profiles side-by-side (Coming soon).

---

## 📈 The Health Score Algorithm

The core of the application is the `ProfileHealthAnalyzer`, which computes a composite score based on the following weighted categories:

1. **Activity (30%)**: Analyzes recent pushes, commit consistency, and time since the last action.
2. **Repository Quality (25%)**: Evaluates the ratio of original vs. forked repositories, active maintenance, and overall stars.
3. **Community (20%)**: Factors in follower count, following ratio, and calculates an engagement level.
4. **Profile Completeness (15%)**: Checks whether the user has filled out their name, bio, location, blog, company, and Twitter.
5. **Language Diversity (10%)**: Analyzes the distribution of programming languages across public repositories.

---

## 🏗️ Architecture

The app adheres to **Clean Architecture**, enforcing strict separation of concerns via the **MVVM + Coordinator** pattern.

### 1. App Navigation & Routing Layer

- Uses an `AppRouter` (`@ObservableObject`) to act as a central coordinator for `NavigationStack` state.
- Employs a `DependencyContainer` implementing a Service Locator pattern to inject networking and use case dependencies dynamically.

### 2. Presentation Layer

- **SwiftUI Views**: Dumb, reactive UI components (`SearchScreen`, `ProfileScreen`, `RepositoryListScreen`).
- **ViewModels**: Standard `ObservableObject` classes publishing states (`idle`, `loading`, `loaded`, `error`).

### 3. Domain Layer

- **UseCases**: Orchestrate business logic (e.g., `FetchProfileUseCase` runs concurrent API requests).
- **Analyzers**: Pure Swift structs (e.g., `ProfileHealthAnalyzer`) that analyze the data and generate `AnalysisResult` and `HealthScore`.
- **Domain Models**: Type-safe structures completely decoupled from network decoding.

### 4. Data Layer

- **NetworkClient**: Custom `URLSession`-based client supporting elegant Async/Await requests, robust JSON decoding, rate limit tracking, and exponential backoff retry mechanisms.
- **GitHubAPIClient**: Defines explicit endpoints and interfaces for GitHub's public API.
- **DTOs & Mappers**: Data Transfer Objects specific to the API responses, mapped cleanly to Domain models.

---

## 🛠️ Tech Stack

- **Language**: Swift 5+
- **Framework**: SwiftUI
- **Concurrency**: Swift Async/Await & Tasks
- **Networking**: Native URLSession
- **Platform**: macOS 13.0+

---

## ⚙️ Setup & Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/your-repo/GitHubProfileAnalyzer.git
   cd GitHubProfileAnalyzer
   ```

2. **Open the Project**:
   Double-click `GitHubProfileAnalyzer.xcodeproj` to open it in Xcode.

3. **Provide API Authentication**:
   The application uses GitHub OAuth for fetching data with significantly higher rate limits.
   - Navigate to the `GitHubProfileAnalyzer/Config/` directory if it exists, or create a `Secrets.xcconfig` file.
   - Insert your personal GitHub Client ID and Secret:
     ```properties
     GITHUB_CLIENT_ID = your_client_id_here
     GITHUB_CLIENT_SECRET = your_client_secret_here
     ```

4. **Build and Run**:
   Select the `GitHubProfileAnalyzer` scheme and run on your Mac (Cmd+R).

---

## 📱 Requirements

- **OS**: macOS 13.0 (Ventura) or later
- **IDE**: Xcode 14.0 or later

---

## 📜 License

This project is licensed under the MIT License.
