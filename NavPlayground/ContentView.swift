import ComposableArchitecture
import SwiftUI
import RootFeature

struct ContentView: View {

    let store = StoreOf<Root>(
        initialState: .init(),
        reducer: Root()._printChanges()
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
