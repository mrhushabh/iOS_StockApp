import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isSplashActive = true

    var body: some View {
        Group {
            if isSplashActive {
                SplashScreenView(isActive: $isSplashActive)
            } else {
                MainContentView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let schema = Schema([
//            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        let previewModelContainer: ModelContainer
        do {
            previewModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create preview ModelContainer: \(error)")
        }

        return ContentView()
            .modelContainer(previewModelContainer)
    }
}
