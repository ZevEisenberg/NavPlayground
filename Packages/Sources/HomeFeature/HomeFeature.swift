import ComposableArchitecture
import SwiftUI
import SettingsFeature

public struct Home: ReducerProtocol {

    public struct State: Equatable {
        public var settings: Settings.State
        public var colors: [Color]

        public init(
            settings: Settings.State,
            colors: [Color]
        ) {
            self.settings = settings
            self.colors = colors
        }
    }

    public enum Action: Equatable {
        case goToSettingsTapped
        case goToColorsTapped
    }

    public init() {}

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        .none
    }

}

public struct HomeView: View {
    let store: StoreOf<Home>

    public init(store: StoreOf<Home>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    Text("Foo: \(viewStore.settings.foo ? "✅" : "❌")")
                    Text("Bar: \(viewStore.settings.bar ? "✅" : "❌")")
                    Text("Baz: \(viewStore.settings.baz ? "✅" : "❌")")
                } header: {
                    Text("Settings")
                } footer: {
                    HStack {
                        Button {
                            viewStore.send(.goToSettingsTapped)
                        } label: {
                            Text("Edit Settings \(Image(systemName: "chevron.forward"))")
                        }
                    }
                }

                Section {
                    HStack {
                        ForEach(viewStore.colors, id: \.self) { color in
                            color
                        }
                    }
                } header: {
                    Text("Colors")
                } footer: {
                    Button {
                        viewStore.send(.goToColorsTapped)
                    } label: {
                        Text("Edit Colors \(Image(systemName: "chevron.forward"))")
                    }
                }
            }
            .navigationTitle("Home")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(
                store: .init(
                    initialState: .init(
                        settings: .init(foo: true, bar: false, baz: true),
                        colors: [.red, .green, .blue, .orange]
                    ),
                    reducer: Home()
                )
            )
        }
    }
}
