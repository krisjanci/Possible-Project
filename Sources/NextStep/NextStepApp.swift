import SwiftUI

@main
struct NextStepApp: App {
    @State private var store = WorkspaceStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
                .frame(minWidth: 1060, minHeight: 700)
                .preferredColorScheme(.light)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
        .defaultSize(width: 1280, height: 820)

        Settings {
            SettingsView(store: store)
                .frame(width: 440, height: 250)
                .preferredColorScheme(.light)
        }
    }
}
