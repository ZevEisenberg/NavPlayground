import SwiftUI
import AutoTCA
import ComposableArchitecture

extension ColorsListView: AutoTCA {
    public struct State: Equatable {
        public var color0: Color
        public var color1: Color
        public var color2: Color
        public var color3: Color

        public var allColors: [Color] {
            get {
                [color0, color1, color2, color3]
            }
            set {
                guard newValue.count == 4 else {
                    preconditionFailure("you lose")
                }

                color0 = newValue[0]
                color1 = newValue[1]
                color2 = newValue[2]
                color3 = newValue[3]
            }
        }
    }

    public enum Action: Equatable {
        case tappedItem(ColorIndex)
    }
}

public struct ColorsListView: View {

    let store: Self.Store

    public init(store: Self.Store) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
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
    }
}
