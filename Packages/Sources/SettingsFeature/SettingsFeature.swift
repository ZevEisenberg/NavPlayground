import ComposableArchitecture
import SwiftUI

public struct Settings: ReducerProtocol {
    public struct State: Equatable {
        @BindableState public var foo: Bool
        @BindableState public var bar: Bool
        @BindableState public var baz: Bool

        public init(foo: Bool, bar: Bool, baz: Bool) {
            self.foo = foo
            self.bar = bar
            self.baz = baz
        }

        public static let initial = Self(foo: true, bar: true, baz: true)
    }

    public enum Action: BindableAction, Equatable {
        case gotoColorsTapped
        case sayHelloTapped
        case binding(BindingAction<State>)
    }

    public init() {}

    public var body: some ReducerProtocolOf<Self> {
        BindingReducer()
    }
}

public struct SettingsView: View {

    let store: StoreOf<Settings>

    public init(store: StoreOf<Settings>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    Toggle("Foo", isOn: viewStore.binding(\.$foo))
                    Toggle("Bar", isOn: viewStore.binding(\.$bar))
                    Toggle("Baz", isOn: viewStore.binding(\.$baz))
                }
                Section {
                    Button(
                        action: { viewStore.send(.sayHelloTapped) },
                        label: { Text("Say Hello, World") }
                    )
                    
                    Button(
                        action: { viewStore.send(.gotoColorsTapped) },
                        label: { Text("Colors") }
                    )
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(
                store: .init(
                    initialState: .init(foo: true, bar: true, baz: false),
                    reducer: Settings()
                )
            )
        }
    }
}
