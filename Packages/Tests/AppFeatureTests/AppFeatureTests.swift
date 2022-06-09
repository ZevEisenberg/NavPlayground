import ComposableArchitecture
@testable import AppFeature
import XCTest

import AppFeature

final class AppFeatureTests: XCTestCase {

    func testPushSettings() {
        let store = TestStore(
            initialState: .init(settings: .initial),
            reducer: appReducer,
            environment: ()
        )

        store.send(.home(.goToSettingsTapped)) {
            $0.isSettingsPresented = true
        }
    }

    func testGoToSettingsTab() {
        let store = TestStore(
            initialState: .init(settings: .initial),
            reducer: appReducer,
            environment: ()
        )

        store.send(.selectedTab(.settings)) {
            $0.tab = .settings
        }
    }

    func testIntegration() {
        let store = TestStore(
            initialState: .init(settings: .initial),
            reducer: appReducer,
            environment: ()
        )

        store.send(.selectedTab(.settings)) {
            $0.tab = .settings
        }

        store.send(.settings(.set(\.$foo, false))) {
            $0.settings.foo = false
        }
    }

}
