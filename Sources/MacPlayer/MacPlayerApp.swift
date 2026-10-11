import SwiftUI

@main
struct MacPlayerApp: App {
    @StateObject private var model = PlayerModel()

    init() {
        // Делаем приложение обычным (с иконкой в Dock и окном), даже если запущено из терминала
        NSApplication.shared.setActivationPolicy(.regular)
    }

    var body: some Scene {
        WindowGroup("MacPlayer") {
            ContentView(model: model)
                .frame(minWidth: 480, minHeight: 360)
        }
        .windowResizability(.contentMinSize)
    }
}
