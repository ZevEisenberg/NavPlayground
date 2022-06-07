import ComposableArchitecture
import SwiftUI
import AutoTCA
import CoordinatorFeature
import SettingsFeature
import ColorsFeature
import HomeFeature

extension TabBarView: AutoTCA {
    public struct State: Equatable {
        public enum Tab: Equatable {
            case home
            case settings
            case colors
        }

        public var tab: Tab
        public var coordinator: CoordinatorView.State

        public init(
            tab: TabBarView.State.Tab = .home,
            coordinator: CoordinatorView.State
        ) {
            self.tab = tab
            self.coordinator = coordinator
        }
    }

    public enum Action: Equatable {
        case selectedTab(State.Tab)
        case coordinator(CoordinatorView.Action)
        case home(HomeView.Action)
        case settings(SettingsView.Action)
        case colorsCoordinator(ColorsCoordinatorView.Action)
    }
}

public let tabBarReducer = TabBarView.Reducer.combine(
    .init { state, action, _ in
        switch action {
        case .selectedTab(let tab):
            state.tab = tab
            return .none
        case .coordinator, .settings, .colorsCoordinator, .home:
            return .none
        }
    },
    coordinatorReducer.pullback(
        state: \.coordinator,
        action: /TabBarView.Action.coordinator,
        environment: { _ in }
    ),
    homeReducer.pullback(
        state: \.coordinator.home,
        action: /TabBarView.Action.home,
        environment: { _ in }
    ),
    settingsReducer.pullback(
        state: \.coordinator.settings,
        action: /TabBarView.Action.settings,
        environment: { _ in }
    ),
    colorsCoordinatorReducer.pullback(
        state: \.coordinator.colorsCoordinator,
        action: /TabBarView.Action.colorsCoordinator,
        environment: { _ in }
    )
)

public struct TabBarView: View {
    let store: Self.Store

    public init(store: Self.Store) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            TabView(
                selection: viewStore.binding(get: \.tab, send: Action.selectedTab)
            ) {
                NavigationView {
                    CoordinatorView(store: store.scope(state: \.coordinator, action: Action.coordinator))
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(State.Tab.home)
                
                SettingsView(store: store.scope(state: \.coordinator.settings, action: Action.settings))
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(State.Tab.settings)
                
                ColorsCoordinatorView(store: store.scope(state: \.coordinator.colorsCoordinator, action: Action.colorsCoordinator))
                    .tabItem {
                        Label("Colors", systemImage: "paintpalette.fill")
                    }
                    .tag(State.Tab.colors)
            }
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(
            store: .init(
                initialState: .init(
                    tab: .colors,
                    coordinator: .init(
                        routes: [
                            .root(.home(.init(
                                settings: .initial,
                                colors: .init()))
                                 )
                        ],
                        settings: .initial,
                        colorsCoordinator: .initial
                    )
                ),
                reducer: tabBarReducer,
                environment: ()
            )
        )
    }
}
