import ComposableArchitecture
import SwiftUI
import SettingsFeature
import HomeFeature
import ColorsFeature

public struct AppFeature: ReducerProtocol {

    public enum Tab: Equatable {
        case home
        case settings
        case colors
    }

    public enum HomeDestination {
        case settings
        case helloWorld
    }

    public enum SettingsDestination {
        case sayHello
    }

    public struct State: Equatable {
        public var tab: Tab

        @BindableState
        var homeNavPath: NavigationPath

        @BindableState
        var settingsNavPath: NavigationPath

        public var home: Home.State {
            get {
                .init(
                    settings: settings,
                    colors: colors.list.allColors
                )
            }
            set {
                settings = newValue.settings
                colors.list.allColors = newValue.colors
            }
        }
        public var settings: Settings.State
        public var colors: ColorsFeature.State

        @BindableState
        var isColorsPresented: Bool

        public init(
            tab: AppFeature.Tab = .home,
            homeNavPath: NavigationPath = NavigationPath(),
            settingsNavPath: NavigationPath = NavigationPath(),
            settings: Settings.State,
            colors: ColorsFeature.State,
            isColorsPresented: Bool = false
        ) {
            self.tab = tab
            self.homeNavPath = homeNavPath
            self.settingsNavPath = settingsNavPath
            self.settings = settings
            self.colors = colors
            self.isColorsPresented = isColorsPresented
        }
    }

    public enum Action: Equatable, BindableAction {
        case selectedTab(Tab)
        case home(Home.Action)
        case settings(Settings.Action)
        case colors(ColorsFeature.Action)

        case binding(_ action: BindingAction<State>)
    }

    public init() {}

    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .selectedTab(let tab):
                state.tab = tab
                return .none
            case .home(.goToSettingsTapped):
                state.homeNavPath.append(HomeDestination.settings)
                return .none
            case .home(.goToColorsTapped):
                state.isColorsPresented = true
                return .none
            case .settings(.sayHelloTapped):
                switch state.tab {
                case .home:
                    state.homeNavPath.append(HomeDestination.helloWorld)
                case .settings:
                    state.settingsNavPath.append(SettingsDestination.sayHello)
                case .colors:
                    break
                }
                return .none
            case .settings(.gotoColorsTapped):
                state.isColorsPresented = true
                return .none
            case .settings:
                return .none
            case .colors:
                return .none
            case .binding:
                return .none
            }
        }

        Scope(state: \.home, action: /AppFeature.Action.home) {
            Home()
        }

        Scope(state: \.settings, action: /AppFeature.Action.settings) {
            Settings()
        }

        Scope(state: \.colors, action: /AppFeature.Action.colors) {
            ColorsFeature()
        }

        BindingReducer()

        // analytics reducer
        Reduce { state, action in
            switch action {
            case let .selectedTab(selectedTabAction):
                print("selectedTab action: \(selectedTabAction)")
            case let .home(homeAction):
                print("home action: \(homeAction)")
            case let .settings(settingsAction):
                print("settings action: \(settingsAction)")
            case let .colors(colorsAction):
                print("colors action: \(colorsAction)")
            case let .binding(bindingAction):
                print("binding action: \(bindingAction)")
            }
            return .none
        }
    }
}

public struct AppView: View {
    let store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    typealias State = AppFeature.State
    typealias Action = AppFeature.Action

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            TabView(
                selection: viewStore.binding(get: \.tab, send: Action.selectedTab)
            ) {
                NavigationStack(path: viewStore.binding(\.$homeNavPath)) {
                    HomeView(store: store.scope(state: \.home, action: Action.home))
                        .navigationDestination(for: AppFeature.HomeDestination.self) { destination in
                            switch destination {
                            case .settings:
                                SettingsView(store: store.scope(state: \.settings, action: Action.settings))
                            case .helloWorld:
                                HelloWorldView()
                            }
                        }
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(AppFeature.Tab.home)

                NavigationStack(path: viewStore.binding(\.$settingsNavPath)) {
                    SettingsView(store: store.scope(state: \.settings, action: Action.settings))
                        .navigationDestination(for: AppFeature.SettingsDestination.self) { destination in
                            switch destination {
                            case .sayHello:
                                HelloWorldView()
                            }
                        }

                }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(AppFeature.Tab.settings)
                
                ColorsFeatureView(store: store.scope(state: \.colors, action: Action.colors))
                    .tabItem {
                        Label("Colors", systemImage: "paintpalette.fill")
                    }
                    .tag(AppFeature.Tab.colors)
            }
            .sheet(isPresented: viewStore.binding(\.$isColorsPresented)) {
                ColorsFeatureView(store: store.scope(state: \.colors, action: Action.colors))
            }
        }
    }

}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: .init(
                initialState: .init(
                    tab: .home,
                    settings: .initial,
                    colors: .initial
                ),
                reducer: AppFeature()
            )
        )
    }
}

struct HelloWorldView: View {
    var body: some View {
        Text("Hello, World!")
    }
}
