import ComposableArchitecture
import Combine
import SwiftUI
import AutoTCA
import AppFeature
import SplashPage

extension RootView: AutoTCA {
    public struct State: Equatable {
        public enum Screen: Equatable {
            case splashPage
            case app
        }
        public var screen: Screen
        public var app: AppView.State
        
        public init(
            screen: Screen = .splashPage,
            app: AppView.State = .init(
                tab: .home,
                settings: .initial,
                colors: .initial
            )
        ) {
            self.screen = screen
            self.app = app
        }
    }

    public enum Action: Equatable {
        case appear
        case moveFromSplashPageToApp
        case app(AppView.Action)
    }

    public struct Environment {
        var mainQueue: AnySchedulerOf<DispatchQueue>
        public init(mainQueue: AnySchedulerOf<DispatchQueue>) {
            self.mainQueue = mainQueue
        }
    }
}

public let rootReducer: RootView.Reducer = .combine(
    appReducer.pullback(
        state: \.app,
        action: /RootView.Action.app,
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
        case .app:
            return .none
        }
    }
)

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
                    AppView(store: store.scope(state: \.app, action: Action.app))
                }
            }
            .onAppear {
                viewStore.send(.appear)
            }
        }
    }
}
