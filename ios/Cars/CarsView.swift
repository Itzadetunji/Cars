import SwiftUI
import Playgrounds

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            CarsView()
        }
    }
}

struct CarsView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    CarsView()
}

#Playground {
    _ = 1 + 2
}
