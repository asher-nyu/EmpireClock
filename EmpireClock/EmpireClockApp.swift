import SwiftUI

@main
struct EmpireClockApp: App {
    func windowGroup() -> some Scene {
        #if os(macOS)
        return WindowGroup {
            ContentView()
                .background(WindowAccessor()) // injects window logic
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        #elseif os(iOS)
        return WindowGroup {
            ContentView()
                .background(WindowAccessor()) // injects window logic
        }
        #endif
    }

    var body: some Scene {
        windowGroup()
    }
}
