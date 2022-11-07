import ComposableArchitecture
import SwiftUI
import SettingsFeature
import HomeFeature
import ColorsFeature

public struct AppFeature: ReducerProtocol {
    public struct State: Equatable {
        public enum Tab: Equatable {
            case home
            case settings
            case colors
        }

        public var tab: Tab
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
        var isSettingsPresented: Bool

        @BindableState
        var isHelloWorldPresented: Bool

        @BindableState
        var isColorsPresented: Bool

        public init(
            tab: AppFeature.State.Tab = .home,
            settings: Settings.State,
            colors: ColorsFeature.State,
            isSettingsPresented: Bool = false,
            isHelloWorldPresented: Bool = false,
            isColorsPresented: Bool = false
        ) {
            self.tab = tab
            self.settings = settings
            self.colors = colors
            self.isSettingsPresented = isSettingsPresented
            self.isHelloWorldPresented = isHelloWorldPresented
            self.isColorsPresented = isColorsPresented
        }
    }

    public enum Action: Equatable, BindableAction {
        case selectedTab(State.Tab)
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
                state.isSettingsPresented = true
                return .none
            case .home(.goToColorsTapped):
                state.isColorsPresented = true
                return .none
            case .settings(.sayHelloTapped):
                state.isHelloWorldPresented = true
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
    }
}

//    .combined(with: .init { state, action, environment in
//    // analytics reducer
//    switch action {
//    case let .selectedTab(selectedTabAction):
//        print("selectedTab action: \(selectedTabAction)")
//    case let .home(homeAction):
//        print("home action: \(homeAction)")
//    case let .settings(settingsAction):
//        print("settings action: \(settingsAction)")
//    case let .colors(colorsAction):
//        print("colors action: \(colorsAction)")
//    case let .binding(bindingAction):
//        print("binding action: \(bindingAction)")
//    }
//    return .none
//})

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
                NavigationView {
                    HomeView(store: store.scope(state: \.home, action: Action.home))
                        .overlay {
                            NavigationLink(isActive: viewStore.binding(\.$isSettingsPresented), destination: {
                                settingsView(viewStore: viewStore)
                            }, label: EmptyView.init)
                            .hidden()
                        }

                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(State.Tab.home)

                NavigationView {
                    settingsView(viewStore: viewStore)
                }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(State.Tab.settings)
                
                ColorsFeatureView(store: store.scope(state: \.colors, action: Action.colors))
                    .tabItem {
                        Label("Colors", systemImage: "paintpalette.fill")
                    }
                    .tag(State.Tab.colors)
            }
            .sheet(isPresented: viewStore.binding(\.$isColorsPresented)) {
                ColorsFeatureView(store: store.scope(state: \.colors, action: Action.colors))
            }
        }
    }

    @ViewBuilder
    private func settingsView(viewStore: ViewStoreOf<AppFeature>) -> some View {
        SettingsView(store: store.scope(state: \.settings, action: Action.settings))
            .overlay {
                NavigationLink(isActive: viewStore.binding(\.$isHelloWorldPresented), destination: {
                    HelloWorldView()
                }, label: EmptyView.init)
                .hidden()
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
