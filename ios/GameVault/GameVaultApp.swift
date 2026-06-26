import SwiftUI

@main
struct GameVaultApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .persistentSystemOverlays(.hidden)
                .ignoresSafeArea(.all)
        }
    }
}
