import ComposableArchitecture
import SwiftUI
import AutoTCA
import SettingsFeature
//import ColorsFeature
import HomeFeature
import ColorsFeature

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
                    settings: settings,
                    colors: colors
                )
            }
            set {
                settings = newValue.settings
                colors = newValue.colors
            }
        }
        public var settings: SettingsView.State
        public var colors: ColorsView.State

        @BindableState
        var isSettingsPresented: Bool

        @BindableState
        var isHelloWorldPresented: Bool

        @BindableState
        var isColorsPresented: Bool

        public init(
            tab: AppView.State.Tab = .home,
            settings: SettingsView.State,
            colors: ColorsView.State,
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
        case home(HomeView.Action)
        case settings(SettingsView.Action)
        case colors(ColorsView.Action)

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
        case let .colors(.tappedItem(color)):
            print(color)
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
    ),
    colorsReducer.pullback(
        state: \.colors,
        action: /AppView.Action.colors,
        environment: { _ in }
    )
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
                
//                ColorsCoordinatorView(store: store.scope(state: \.colors, action: Action.colors))
//                    .tabItem {
//                        Label("Colors", systemImage: "paintpalette.fill")
//                    }
//                    .tag(State.Tab.colors)
            }
            .sheet(isPresented: viewStore.binding(\.$isColorsPresented)) {
                ColorsView(store: store.scope(state: \.colors, action: Action.colors))
            }
        }
    }

    @ViewBuilder
    private func settingsView(viewStore: Self.ViewStore) -> some View {
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
                reducer: appReducer,
                environment: ()
            )
        )
    }
}

struct HelloWorldView: View {
    var body: some View {
        Text("Hello, World!")
    }
}
