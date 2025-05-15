
import SwiftUI

@main
struct Pokemon_infromationApp: App {
    @StateObject var pokeData = PokeData()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(pokeData)
        }
    }
}
