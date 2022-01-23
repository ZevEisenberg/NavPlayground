import SwiftUI
import RootFeature

struct ContentView: View {

    let store = RootView.Store(
        initialState: .init(),
        reducer: rootReducer,
        environment: .init(
            mainQueue: .main
        )
    )

    var body: some View {
        RootView(
            store: store
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
