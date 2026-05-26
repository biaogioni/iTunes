**Project Information**

- Solution adopted

An iOS app to search songs through the Apple iTunes Search API based on user text input, built with an offline-first experience. It covers a splash screen, a paginated search/home screen with a recently-played section, a player (song details), an album screen, and a more-options bottom sheet.

- Libraries used

100% native. No third-party dependencies — built entirely with SwiftUI and Apple frameworks (SwiftData for persistence, Swift Concurrency for async work, and XCTest for testing). Networking is handled by a custom abstraction layer over URLSession.

- Architecture

MVVM, with a protocol-based network layer and a repository layer so the API implementation can be replaced without affecting the rest of the app.

- Instructions to run the project

Just clone and build. Open the project in Xcode 16+, select an iOS 26+ simulator, and run. No API keys or extra setup required, since the iTunes Search API is public.
