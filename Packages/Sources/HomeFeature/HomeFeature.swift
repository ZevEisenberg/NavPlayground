import ComposableArchitecture
import SwiftUI
import AutoTCA
import ColorsFeature
import SettingsFeature

extension HomeView: AutoTCA {

    public struct State: Equatable {
        public var settings: SettingsView.State
        public var colors: ColorsView.State

        public init(settings: SettingsView.State, colors: ColorsView.State) {
            self.settings = settings
            self.colors = colors
        }
    }

    public enum Action: Equatable {
        case goToSettingsTapped
        case goToColorsTapped
        case goToSettings(SettingsView.State)
        case goToColors(ColorsView.State)
    }

}

public let homeReducer = HomeView.Reducer { state, action, _ in
    switch action {
    case .goToSettingsTapped:
        return .init(value: .goToSettings(state.settings))

    case .goToColorsTapped:
        return .init(value: .goToColors(state.colors))

    case .goToSettings, .goToColors:
        return .none
    }
}

public struct HomeView: View {
    let store: Self.Store

    public init(store: Self.Store) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            Form {
                Section {
                    Text("Foo: \(viewStore.settings.foo ? "✅" : "❌")")
                    Text("Bar: \(viewStore.settings.bar ? "✅" : "❌")")
                    Text("Baz: \(viewStore.settings.baz ? "✅" : "❌")")
                } header: {
                    Text("Settings")
                } footer: {
                    Button {
                        viewStore.send(.goToSettingsTapped)
                    } label: {
                        Text("Edit \(Image(systemName: "chevron.forward"))")
                    }
                }

                Section {
                    HStack {
                        ForEach(viewStore.colors.allColors, id: \.self) { color in
                            color
                        }
                    }
                } header: {
                    Text("Colors")
                } footer: {
                    Button {
                        viewStore.send(.goToColorsTapped)
                    } label: {
                        Text("Edit \(Image(systemName: "chevron.forward"))")
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
            HomeView(store: .init(
                initialState: .init(
                    settings: .init(foo: true, bar: false, baz: true),
                    colors: .initial
                ),
                reducer: homeReducer,
                environment: ())
            )
        }
    }
}
