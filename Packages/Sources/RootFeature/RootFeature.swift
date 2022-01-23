import ComposableArchitecture
import Combine
import SwiftUI
import AutoTCA
import TabBarFeature
import SplashPage

extension RootView: AutoTCA {
    public struct State: Equatable {
        public enum Screen: Equatable {
            case splashPage
            case app
        }
        var screen: Screen
        var tabBar: TabBarView.State
        public init(
            screen: Screen = .splashPage,
            tabBar: TabBarView.State = .init()
        ) {
            self.screen = screen
            self.tabBar = tabBar
        }
    }

    public enum Action {
        case appear
        case moveFromSplashPageToApp
        case tabBar(TabBarView.Action)
    }

    public struct Environment {
        var mainQueue: AnySchedulerOf<DispatchQueue>
        public init(mainQueue: AnySchedulerOf<DispatchQueue>) {
            self.mainQueue = mainQueue
        }
    }
}

public let rootReducer: RootView.Reducer = .combine(
    tabBarReducer.pullback(
        state: \.tabBar,
        action: /RootView.Action.tabBar,
        environment: { _ in }
    ),
    .init { state, action, environment in
        switch action {
        case .appear:
            return Just(.moveFromSplashPageToApp)
                .delay(for: .seconds(2), scheduler: environment.mainQueue.animation())
                .eraseToEffect()

        case .moveFromSplashPageToApp:
            state.screen = .app
            return .none
        case .tabBar:
            return .none
        }
    }
)
    .debug()

public struct RootView: View {
    let store: Self.Store

    public init(store: Self.Store) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            Group {
                switch viewStore.screen {
                case .splashPage:
                    SplashPageView()
                case .app:
                    TabBarView(store: store.scope(state: \.tabBar, action: Action.tabBar))
                }
            }
            .onAppear {
                viewStore.send(.appear)
            }
        }
    }
}
