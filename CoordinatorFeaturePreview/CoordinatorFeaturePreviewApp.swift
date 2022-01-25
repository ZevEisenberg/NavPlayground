import SwiftUI
import CoordinatorFeature

@main
struct CoordinatorFeaturePreviewApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                CoordinatorView(
                    store: .init(
                        initialState: .init(routes: [
                            .root(.home(.init(settings: .initial, colors: .initial)))
                        ]),
                        reducer: coordinatorReducer,
                        environment: ()
                    )
                )
            }
        }
    }
}
