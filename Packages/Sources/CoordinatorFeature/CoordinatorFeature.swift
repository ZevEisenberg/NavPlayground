import AutoTCA
import ComposableArchitecture
import TCACoordinators
import FlowStacks
import ScreenFeature
import SwiftUI
import HomeFeature
import SettingsFeature
import ColorsFeature

extension CoordinatorView: AutoTCA {
    public struct State: Equatable, IndexedRouterState {
        public var routes: [Route<ScreenState>]

        public init(
            routes: [Route<ScreenState>]
        ) {
            self.routes = routes
        }
    }

    public enum Action: IndexedRouterAction, Equatable {
        case routeAction(Int, action: ScreenAction)
        case updateRoutes([Route<ScreenState>])
    }

}

public let coordinatorReducer: CoordinatorView.Reducer = screenReducer
    .forEachIndexedRoute(environment: { _ in })
    .withRouteReducer(
        .init { state, action, environment in
            switch action {
            case .routeAction(_, .home(.goToSettings(let settings))):
                state.routes.push(.settings(settings))

            case .routeAction(_, action: .home(.goToColors(let colors))):
                state.routes.push(.colors(colors))

            default:
                break
            }
            return .none
        }
    )

public struct CoordinatorView: View {
    let store: Self.Store

    public init(store: Self.Store) {
        self.store = store
    }

    public var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) {
                CaseLet(
                    state: /ScreenState.home,
                    action: ScreenAction.home,
                    then: HomeView.init(store:)
                )
                CaseLet(
                    state: /ScreenState.settings,
                    action: ScreenAction.settings,
                    then: SettingsView.init(store:)
                )
                CaseLet(
                    state: /ScreenState.colors,
                    action: ScreenAction.colors,
                    then: ColorsView.init(store:)
                )
            }
        }
    }
}
