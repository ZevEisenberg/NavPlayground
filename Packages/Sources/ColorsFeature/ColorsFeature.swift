import ComposableArchitecture
import Overture
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

        public var currentlyPickingIndex: WhichColor?

        public var allColors: [Color] {
            [color0, color1, color2, color3]
        }

        public init(
            color0: Color,
            color1: Color,
            color2: Color,
            color3: Color,
            currentlyPickingIndex: WhichColor? = nil
        ) {
            self.color0 = color0
            self.color1 = color1
            self.color2 = color2
            self.color3 = color3
            self.currentlyPickingIndex = currentlyPickingIndex
        }

        public static var initial: Self {
            .init(color0: .red, color1: .green, color2: .blue, color3: .orange)
        }
    }

    public enum Action: Equatable {
        case tappedItem(WhichColor)
        case pickedColor(Color, index: WhichColor)

        case dismissColorPicker
    }
}

public let colorsReducer = ColorsView.Reducer { state, action, _ in
    switch action {
    case .pickedColor(let color, index: let index):
        switch index {
        case .color0:
            state.color0 = color
        case .color1:
            state.color1 = color
        case .color2:
            state.color2 = color
        case .color3:
            state.color3 = color
        }
        state.currentlyPickingIndex = nil
        return .none

    case .tappedItem(let index):
        state.currentlyPickingIndex = index
        return .none

    case .dismissColorPicker:
        state.currentlyPickingIndex = nil
        return .none
    }
}

public struct ColorsView: View {

    let store: Self.Store

    public init(store: Self.Store) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                HStack {
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
                }
                HStack {
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
            }
            .sheet(
                item: viewStore.binding(
                    get: \.currentlyPickingIndex,
                    send: .dismissColorPicker)
            ) { currentlyPickingIndex in
                NavigationView {
                    VStack {
                        HStack {
                            Button {
                                viewStore.send(.pickedColor(.red, index: currentlyPickingIndex))
                            } label: {
                                Color.red
                            }
                            Button {
                                viewStore.send(.pickedColor(.green, index: currentlyPickingIndex))
                            } label: {
                                Color.green
                            }
                        }

                        HStack {
                            Button {
                                viewStore.send(.pickedColor(.blue, index: currentlyPickingIndex))
                            } label: {
                                Color.blue
                            }
                            Button {
                                viewStore.send(.pickedColor(.orange, index: currentlyPickingIndex))
                            } label: {
                                Color.orange
                            }
                        }
                    }
                    .navigationTitle("Pick a Color")
                    #if !os(macOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        ToolbarItemGroup(placement: .cancellationAction) {
                            Button {
                                viewStore.send(.dismissColorPicker)
                            } label: {
                                Text("Cancel")
                            }
                        }
                    }
                }

            }
        }
        .navigationTitle("Colors")
    }
}

func get(_ currentlyPickingIndex: WhichColor) -> KeyPath<ColorsView.State, Color> {
    let get: KeyPath<ColorsView.State, Color>
    switch currentlyPickingIndex {
    case .color0: get = \.color0
    case .color1: get = \.color1
    case .color2: get = \.color2
    case .color3: get = \.color3
    }
    return get
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

        NavigationView {
            ColorsView(store: .init(
                initialState: update(.initial) { $0.currentlyPickingIndex = .color0 },
                reducer: colorsReducer,
                environment: ())
            )
        }
    }
}
