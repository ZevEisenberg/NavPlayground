import AutoTCA
import ComposableArchitecture
import TCACoordinators
import FlowStacks
import ScreenFeature
import SwiftUI
import HomeFeature
import SettingsFeature
import ColorsFeature
import CasePaths

extension CoordinatorView: AutoTCA {
    public struct State: Equatable, IndexedRouterState {
        public var routes: [Route<ScreenState>]

        public var settings: SettingsView.State
        public var colorsCoordinator: ColorsCoordinatorView.State

        public var home: HomeView.State {
            get {
                .init(
                    settings: settings,
                    colors: colorsCoordinator.colors
                )
            }
            set {
                settings = newValue.settings
                colorsCoordinator.colors = newValue.colors
            }
        }

        public init(
            routes: [Route<ScreenState>],
            settings: SettingsView.State,
            colorsCoordinator: ColorsCoordinatorView.State
        ) {
            self.routes = routes
            self.settings = settings
            self.colorsCoordinator = colorsCoordinator
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
            case .routeAction(_, .home(.goToSettingsTapped)):
                state.routes.push(.settings(state.settings))

            case .routeAction(_, action: .home(.goToColorsTapped)):
                state.routes.push(.colorsCoordinator(state.colorsCoordinator))

//            case .routeAction(_, action: .settings(.stateChanged(let newState))):
//                for (index, route) in zip(state.routes.indices, state.routes) {
//                    if var homeState = (/ScreenState.home).extract(from: route.screen) {
//                        homeState.settings = newState
//                        state.routes[index].screen = .home(homeState)
//                    }
//                }
//                return .none

            default:
                break
            }
            return .none
        }
    )
    .combined(with: .combine(
        settingsReducer.pullback(
            state: \CoordinatorView.State.settings,
            action: <#T##CasePath<GlobalAction, SettingsView.Action>#>,
            environment: <#T##(GlobalEnvironment) -> Void#>
        )
    ))

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
                    state: /ScreenState.colorsCoordinator,
                    action: ScreenAction.colorsCoordinator,
                    then: ColorsCoordinatorView.init(store:)
                )
            }
        }
    }
}

struct CoordinatorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CoordinatorView(
                store: .init(
                    initialState: .init(
                        routes: [
                            .root(.home(.init(settings: .initial, colors: .init()))),
                        ],
                        settings: .initial,
                        colorsCoordinator: .initial
                    ),
                    reducer: coordinatorReducer,
                    environment: ()
                )
            )
        }
    }
}
