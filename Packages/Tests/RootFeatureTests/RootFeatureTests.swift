import ComposableArchitecture
import RootFeature
import XCTest
import CoordinatorFeature
import TabBarFeature

final class RootFeatureTests: XCTestCase {

    func testCoordinatorReducer() {
        let store = TestStore(
            initialState: .init(routes: [
                .root(.home(.init(settings: .initial, colors: .init())))
            ]),
            reducer: coordinatorReducer,
            environment: ()
        )

        store.send(.routeAction(0, action: .home(.goToSettingsTapped)))
        store.receive(.routeAction(0, action: .home(.goToSettings(.initial)))) {
            $0.routes.append(.push(.settings(.initial)))
        }
    }

    func testTabBarReducer() {
        let store = TestStore(
            initialState: .init(tab: .home, home: .init(settings: .initial, colors: .init()), coordinator: .init(routes: [
                .root(.home(.init(settings: .initial, colors: .init())))
            ])),
            reducer: tabBarReducer,
            environment: ()
        )

        store.send(.coordinator(.routeAction(0, action: .home(.goToSettingsTapped))))
        store.receive(.coordinator(.routeAction(0, action: .home(.goToSettings(.initial))))) {
            $0.coordinator.routes.append(.push(.settings(.initial)))
        }
    }

    func testFlow() {
        let store = TestStore(
            initialState: .init(),
            reducer: rootReducer,
            environment: .init(mainQueue: .immediate)
        )

        store.send(.appear)
        store.receive(.moveFromSplashPageToApp) {
            $0.screen = .app
        }

        store.send(.tabBar(.coordinator(.routeAction(0, action: .home(.goToSettingsTapped)))))
        store.receive(.tabBar(.coordinator(.routeAction(0, action: .home(.goToSettings(.initial)))))) {
            $0.tabBar.coordinator.routes.append(.push(.settings(.initial)))
        }
    }

}
