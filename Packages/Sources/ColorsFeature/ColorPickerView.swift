import AutoTCA
import ComposableArchitecture
import SwiftUI

extension ColorPickerView: AutoTCA {
    public struct State: Equatable {}

    public enum Action: Equatable {
        case dismiss
        case picked(Color)
    }
}

let colorPickerReducer = ColorPickerView.Reducer.empty // parent handles all actions

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
                    }
                    Button {
                        viewStore.send(.picked(.green))
                    } label: {
                        Color.green
                    }
                }

                HStack {
                    Button {
                        viewStore.send(.picked(.blue))
                    } label: {
                        Color.blue
                    }
                    Button {
                        viewStore.send(.picked(.orange))
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
                        viewStore.send(.dismiss)
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}
