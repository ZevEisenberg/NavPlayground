import ComposableArchitecture
import SwiftUI

public struct ColorPickerFeature: ReducerProtocol {
    public struct State: Equatable {
        let colorIndex: ColorIndex
    }

    public enum Action: Equatable {
        case dismiss
        case picked(Color)
    }

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        .none
    }

}

public struct ColorPickerView: View {
    let store: StoreOf<ColorPickerFeature>

    public init(store: StoreOf<ColorPickerFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HStack {
                    Button {
                        viewStore.send(.picked(.red))
                    } label: {
                        Color.red
                            .clipShape(Circle())
                    }
                    Button {
                        viewStore.send(.picked(.green))
                    } label: {
                        Color.green
                            .clipShape(Circle())
                    }
                }

                HStack {
                    Button {
                        viewStore.send(.picked(.blue))
                    } label: {
                        Color.blue
                            .clipShape(Circle())
                    }
                    Button {
                        viewStore.send(.picked(.orange))
                    } label: {
                        Color.orange
                            .clipShape(Circle())
                    }
                }
            }
            .navigationTitle("Pick a New \(viewStore.colorIndex.navTitle)")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button {
                        viewStore.send(.dismiss)
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

extension ColorIndex {
    var navTitle: String {
        switch self {
        case .color0:
            return "Color 0"
        case .color1:
            return "Color 1"
        case .color2:
            return "Color 2"
        case .color3:
            return "Color 3"
        }
    }
}
