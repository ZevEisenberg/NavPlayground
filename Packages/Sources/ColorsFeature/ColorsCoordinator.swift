import SwiftUI
import ComposableArchitecture
import TCACoordinators
import AutoTCA
import FlowStacks
import CasePaths

public enum WhichColor: Int, Identifiable {
    case color0
    case color1
    case color2
    case color3

    public var id: Int {
        rawValue
    }
}

extension ColorsCoordinatorView: AutoTCA {
    public struct State: Equatable, IndexedRouterState {
        public var routes: [Route<ColorsScreenState>]
        public var colors = [Color.red, .green, .blue, .orange]
        public var currentlyPickingItem: WhichColor? = nil

        public init(
            colors: [Color] = [Color.red, .green, .blue, .orange],
            currentlyPickingItem: WhichColor? = nil
        ) {
            self.colors = colors
            self.currentlyPickingItem = currentlyPickingItem

            self.routes = [
                .root(.main(.init(color0: colors[0], color1: colors[1], color2: colors[2], color3: colors[3])))
            ]
            if currentlyPickingItem != nil {
                self.routes.presentSheet(.picker(.init()))
            }
        }
    }

    public enum Action: Equatable, IndexedRouterAction {
        case routeAction(Int, action: ColorsScreenAction)
        case updateRoutes([Route<ColorsScreenState>])
    }
}

public let colorsCoordinatorReducer: ColorsCoordinatorView.Reducer = colorsScreenReducer
    .forEachIndexedRoute(environment: { _ in })
    .withRouteReducer(
        .init { state, action, _ in
            switch action {
            case .routeAction(_, action: .main(.tappedItem(let item))):
                state.currentlyPickingItem = item
                state.routes.presentSheet(.picker(.init()), embedInNavigationView: true)

            case .routeAction(_, action: .picker(.dismiss)):
                state.currentlyPickingItem = nil
                state.routes.dismiss()

            case .routeAction(_, action: .picker(.picked(let color))):
                guard var root = (/ColorsScreenState.main).extract(from: state.routes[0].screen) else {
                    return .failing("failed to unwrap root screen at index 0")
                }
                switch state.currentlyPickingItem {
                case .color0:
                    root.color0 = color
                case .color1:
                    root.color1 = color
                case .color2:
                    root.color2 = color
                case .color3:
                    root.color3 = color
                case nil:
                    return .failing("Picked color when currentlyPickingIndex was nil")
                }
                state.routes[0].screen = .main(root)
                state.currentlyPickingItem = nil
                state.routes.dismiss()

            default:
                break
            }
            return .none
        }
    )

public struct ColorsCoordinatorView: View {
    let store: Self.Store

    public init(store: Self.Store) {
        self.store = store
    }

    public var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) {
                CaseLet(
                    state: /ColorsScreenState.main,
                    action: ColorsScreenAction.main,
                    then: ColorsView.init(store:)
                )
                CaseLet(
                    state: /ColorsScreenState.picker,
                    action: ColorsScreenAction.picker,
                    then: ColorPickerView.init(store:)
                )
            }
        }
    }
}

struct ColorsCoordinatorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ColorsCoordinatorView(store: .init(
                initialState: .init(),
                reducer: colorsCoordinatorReducer,
                environment: ())
            )
        }

        NavigationView {
            ColorsCoordinatorView(store: .init(
                initialState: .init(currentlyPickingItem: .color1),
                reducer: colorsCoordinatorReducer,
                environment: ())
            )
        }
    }
}
