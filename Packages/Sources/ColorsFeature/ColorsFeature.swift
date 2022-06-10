import ComposableArchitecture
import SwiftUI
import AutoTCA

public enum ColorIndex: Int, Identifiable {
    case color0
    case color1
    case color2
    case color3

    public var id: Int {
        rawValue
    }
}

extension ColorsFeatureView: AutoTCA {
    public struct State: Equatable {
        public var list: ColorsListView.State
        public var picker: ColorPickerView.State?

        public init(
            root: ColorsListView.State,
            picker: ColorPickerView.State? = nil
        ) {
            self.list = root
            self.picker = picker
        }

        public static var initial: Self {
            .init(root: .init(color0: .red, color1: .green, color2: .blue, color3: .orange))
        }
    }

    public enum Action: Equatable {
        case list(ColorsListView.Action)
        case picker(ColorPickerView.Action)
    }
}

public let colorsFeatureReducer = ColorsFeatureView.Reducer { state, action, _ in
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
    }
}

public struct ColorsFeatureView: View {

    let store: Self.Store

    public init(store: Self.Store) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ColorsListView(store: store.scope(state: \.list, action: Action.list))
                .sheet(isPresented: Binding(
                    get: { viewStore.picker != nil },
                    set: { newValue in
                        if !newValue {
                            viewStore.send(.picker(.dismiss))
                        }
                    }
                )) {
                    IfLetStore(store.scope(state: \.picker, action: Action.picker)) { store in
                        NavigationView {
                            ColorPickerView(store: store)
                        }
                    }
                }
        }
        .navigationTitle("Colors")
    }
}

struct ColorsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ColorsFeatureView(store: .init(
                initialState: .initial,
                reducer: colorsFeatureReducer,
                environment: ())
            )
        }
    }
}
