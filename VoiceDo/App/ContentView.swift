import SwiftUI

/// Root view. Hosts the app-level tab bar with the Lists and Settings tabs.
/// The floating mic button (Phase 3) will be layered on top of this view.
struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Lists", systemImage: "list.bullet")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [TaskList.self, Task.self], inMemory: true)
}
