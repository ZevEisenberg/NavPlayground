import ComposableArchitecture
import SwiftUI
import AutoTCA

public enum WhichColor: Int, Identifiable {
    case color0
    case color1
    case color2
    case color3

    public var id: Int {
        rawValue
    }
}

extension ColorsView: AutoTCA {
    public struct State: Equatable {
        public var color0: Color
        public var color1: Color
        public var color2: Color
        public var color3: Color


        public var allColors: [Color] {
            [color0, color1, color2, color3]
        }

        var selectedColor: WhichColor? = nil

        @BindableState
        var isColorSelected: Bool = false

        public init(
            color0: Color,
            color1: Color,
            color2: Color,
            color3: Color
        ) {
            self.color0 = color0
            self.color1 = color1
            self.color2 = color2
            self.color3 = color3
        }

        public static var initial: Self {
            .init(color0: .red, color1: .green, color2: .blue, color3: .orange)
        }
    }

    public enum Action: Equatable {
        case tappedItem(WhichColor)
//        case colorPicker(ColorPickerView.Action)
    }
}

public let colorsReducer = ColorsView.Reducer.init() { state, action, _ in
    switch action {
    case let .tappedItem(whichColor):
        state.selectedColor = whichColor
        state.isColorSelected = true
        return .none
//    case .colorPicker:
//        return .none
    }
}

public struct ColorsView: View {

    let store: Self.Store

    public init(store: Self.Store) {
        self.store = store
    }

    @ViewBuilder
    func colorsView(_ viewStore: Self.ViewStore) -> some View {
        VStack {
            Button {
                viewStore.send(.tappedItem(.color0))
            } label: {
                viewStore.color0
            }

            Button {
                viewStore.send(.tappedItem(.color1))
            } label: {
                viewStore.color1
            }
            Button {
                viewStore.send(.tappedItem(.color2))
            } label: {
                viewStore.color2
            }

            Button {
                viewStore.send(.tappedItem(.color3))
            } label: {
                viewStore.color3
            }
        }
        .frame(width: 100, height: 300)
    }


    public var body: some View {
        WithViewStore(store) { viewStore in
            colorsView(viewStore)
                .sheet(isPresented: viewStore.binding(\.$isColorSelected) {
                    ColorPickerView(
                        store: store.scope(
                            state: .empty,
                            action: { pickedColor in .picked(pickedColor) }
                        )
                    )
                }
        }
        .navigationTitle("Colors")
    }
}

struct ColorsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ColorsView(store: .init(
                initialState: .initial,
                reducer: colorsReducer,
                environment: ())
            )
        }
    }
}
