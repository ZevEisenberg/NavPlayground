import ComposableArchitecture
import Combine
import SwiftUI
import AppFeature
import SplashPage

public struct Root: ReducerProtocol {
    public struct State: Equatable {
        public enum Screen: Equatable {
            case splashPage
            case app
        }
        public var screen: Screen
        public var app: AppFeature.State
        
        public init(
            screen: Screen = .splashPage,
            app: AppFeature.State = .init(
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
        case app(AppFeature.Action)
    }

    @Dependency(\.continuousClock) var clock

    public init() {}

    public var body: some ReducerProtocolOf<Self> {
        Scope(state: \.app, action: /Root.Action.app) {
            AppFeature()
        }

        Reduce { state, action in
            switch action {
            case .appear:
                return .task {
                    try await clock.sleep(for: .seconds(2))
                    return .moveFromSplashPageToApp
                }

            case .moveFromSplashPageToApp:
                state.screen = .app
                return .none
            case .app:
                return .none
            }
        }
        // TODO: how to add .debug?
    }
}

public struct RootView: View {
    let store: StoreOf<Root>

    public init(store: StoreOf<Root>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: \.screen) { viewStore in
            Group {
                switch viewStore.state {
                case .splashPage:
                    SplashPageView()
                case .app:
                    AppView(store: store.scope(state: \.app, action: Root.Action.app))
                }
            }
            .onAppear {
                viewStore.send(.appear)
            }
        }
    }
}
