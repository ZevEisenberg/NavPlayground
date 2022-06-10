import AutoTCA
import ComposableArchitecture
import SwiftUI

extension ColorPickerView: AutoTCA {
    public struct State: Equatable {
        let colorIndex: ColorIndex
    }

    public enum Action: Equatable {
        case dismiss
        case picked(Color)
    }
}

public struct ColorPickerView: View {
    let store: Self.Store

    public init(store: Self.Store) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
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
