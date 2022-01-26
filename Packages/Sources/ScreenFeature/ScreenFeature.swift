import ComposableArchitecture
import HomeFeature
import SettingsFeature
import ColorsFeature

public enum ScreenState: Equatable {
    case home(HomeView.State)
    case settings(SettingsView.State)
    case colors(ColorsCoordinatorView.State)
}

public enum ScreenAction: Equatable {
    case home(HomeView.Action)
    case settings(SettingsView.Action)
    case colors(ColorsCoordinatorView.Action)
}

public let screenReducer = Reducer<ScreenState, ScreenAction, Void>.combine(
    homeReducer.pullback(
        state: /ScreenState.home,
        action: /ScreenAction.home,
        environment: { _ in }
    ),
    settingsReducer.pullback(
        state: /ScreenState.settings,
        action: /ScreenAction.settings,
        environment: { _ in }
    ),
    colorsCoordinatorReducer.pullback(
        state: /ScreenState.colors,
        action: /ScreenAction.colors,
        environment: { _ in }
    )
)
