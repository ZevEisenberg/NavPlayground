import ComposableArchitecture
import SwiftUI
import SwiftUINavigation

public enum ColorIndex: Int, Identifiable {
    case color0
    case color1
    case color2
    case color3

    public var id: Int {
        rawValue
    }
}

public struct ColorsFeature: ReducerProtocol {
    public struct State: Equatable {
        public var list: ColorsList.State

        @BindableState
        public var picker: ColorPickerFeature.State?

        public init(
            root: ColorsList.State,
            picker: ColorPickerFeature.State? = nil
        ) {
            self.list = root
            self.picker = picker
        }

        public static var initial: Self {
            .init(root: .init(color0: .red, color1: .green, color2: .blue, color3: .orange))
        }
    }

    public enum Action: Equatable, BindableAction {
        case list(ColorsList.Action)
        case picker(ColorPickerFeature.Action)

        case binding(_ action: BindingAction<State>)
    }

    public init() {}

    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case let .list(.tappedItem(item)):
                state.picker = .init(colorIndex: item)
                return .none

            case .picker(.dismiss):
                state.picker = nil
                return .none

            case let .picker(.picked(color)):
                defer { state.picker = nil }
                guard let colorIndex = state.picker?.colorIndex else {
                    return .none
                }
                switch colorIndex {
                case .color0:
                    state.list.color0 = color
                case .color1:
                    state.list.color1 = color
                case .color2:
                    state.list.color2 = color
                case .color3:
                    state.list.color3 = color
                }
                return .none

            case .binding:
                return .none
            }
        }

        BindingReducer()
    }
}

public struct ColorsFeatureView: View {

    let store: StoreOf<ColorsFeature>

    public init(store: StoreOf<ColorsFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ColorsListView(store: store.scope(state: \.list, action: ColorsFeature.Action.list))
                .sheet(
                    store: store,
                    bindableState: \.$picker,
                    bindableAction: ColorsFeature.Action.picker
                ) { store in
                    NavigationView {
                        ColorPickerView(store: store)
                    }
                }
        }
        .navigationTitle("Colors")
    }
}

struct ColorsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ColorsFeatureView(
                store: .init(
                    initialState: .initial,
                    reducer: ColorsFeature()
                )
            )
        }
    }
}
