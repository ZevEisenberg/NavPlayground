import ComposableArchitecture

/// Conform a type to this protocol and get a properly typed `Reducer`, `Store`, and `ViewStore` for free.
public protocol AutoTCA {
    associatedtype State = Void
    associatedtype Action = Void
    associatedtype Environment = Void
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias ViewStore = ComposableArchitecture.ViewStore<State, Action>
}
