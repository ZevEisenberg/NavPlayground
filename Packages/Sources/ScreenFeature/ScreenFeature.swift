import ComposableArchitecture
import HomeFeature
import SettingsFeature
import ColorsFeature

public enum ScreenState: Equatable {
    case home(HomeView.State)
    case settings(SettingsView.State)
    case colors(ColorsView.State)
}

public enum ScreenAction: Equatable {
    case home(HomeView.Action)
    case settings(SettingsView.Action)
    case colors(ColorsView.Action)
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
    colorsReducer.pullback(
        state: /ScreenState.colors,
        action: /ScreenAction.colors,
        environment: { _ in }
    )
)
