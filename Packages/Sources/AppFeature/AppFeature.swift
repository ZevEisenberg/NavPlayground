import ComposableArchitecture
import SwiftUI
import AutoTCA
import SettingsFeature
//import ColorsFeature
import HomeFeature

extension AppView: AutoTCA {
    public struct State: Equatable {
        public enum Tab: Equatable {
            case home
            case settings
//            case colors
        }

        public var tab: Tab
        public var home: HomeView.State {
            get {
                .init(
                    settings: settings
                    /* todo: colors */
                )
            }
            set {
                settings = newValue.settings
                // todo: colors
            }
        }
        public var settings: SettingsView.State
//        public var colors: ColorsCoordinatorView.State

        @BindableState
        var isSettingsPresented: Bool

        public init(
            tab: AppView.State.Tab = .home,
            settings: SettingsView.State,
            // todo: colors
            isSettingsPresented: Bool = false
        ) {
            self.tab = tab
            self.settings = settings
            self.isSettingsPresented = false
        }
    }

    public enum Action: Equatable, BindableAction {
        case selectedTab(State.Tab)
        case home(HomeView.Action)
        case settings(SettingsView.Action)
//        case colors(ColorsCoordinatorView.Action)

        case binding(_ action: BindingAction<State>)
    }
}

public let appReducer = AppView.Reducer.combine(
    .init { state, action, _ in
        switch action {
        case .selectedTab(let tab):
            state.tab = tab
            return .none
        case .home(.goToSettingsTapped):
            state.isSettingsPresented = true
            return .none
        case .settings /*.colors,*/:
            return .none
        case .binding:
            return .none
        }
    },
    homeReducer.pullback(
        state: \.home,
        action: /AppView.Action.home,
        environment: { _ in }
    ),
    settingsReducer.pullback(
        state: \.settings,
        action: /AppView.Action.settings,
        environment: { _ in }
    )
//    colorsCoordinatorReducer.pullback(
//        state: \.colors,
//        action: /TabBarView.Action.colors,
//        environment: { _ in }
//    )
)
    .binding()

public struct AppView: View {
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
                    HomeView(store: store.scope(state: \.home, action: Action.home))
                        .overlay {
                            NavigationLink(isActive: viewStore.binding(\.$isSettingsPresented), destination: {
                                settingsView
                            }, label: EmptyView.init)
                            .opacity(0)
                        }
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(State.Tab.home)
                
                settingsView
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(State.Tab.settings)
                
//                ColorsCoordinatorView(store: store.scope(state: \.colors, action: Action.colors))
//                    .tabItem {
//                        Label("Colors", systemImage: "paintpalette.fill")
//                    }
//                    .tag(State.Tab.colors)
            }
        }
    }

    @ViewBuilder
    private var settingsView: some View {
        SettingsView(store: store.scope(state: \.settings, action: Action.settings))
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: .init(
                initialState: .init(tab: .home, settings: .initial),
                reducer: appReducer,
                environment: ()
            )
        )
    }
}
