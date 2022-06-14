import SwiftUI
import SwiftUINavigation
import ComposableArchitecture

extension View {
    /// Present a sheet of a TCA view.
    /// ```swift
    /// someView
    ///     .sheet(
    ///         unwrapping: viewStore.binding(\.$someState),
    ///         store: store.scope(state: \.someState, action: Action.someAction)
    ///     ) { store in
    ///         NavigationView { // nav view is optional
    ///             SomeChildView(store: store)
    ///         }
    ///     }
    /// ```
    func sheet<State, Action, Content: View>(
        unwrapping state: Binding<State?>,
        store: Store<State?, Action>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Store<State, Action>) -> Content
    ) -> some View {
        self.sheet(
            unwrapping: state,
            onDismiss: onDismiss,
            content: { _ in
                IfLetStore(store) { nonOptionalStore in
                    content(nonOptionalStore)
                }
            }
        )
    }

    /// Present a sheet of a TCA view that uses `@BindableState` for its presentation state.
    ///
    /// ```swift
    /// someView
    ///     .sheet(
    ///         store: store,
    ///         bindableState: \.$someBindableState,
    ///         bindableAction: Action.someBindableAction
    ///     ) { store in
    ///         NavigationView {
    ///             SomeChildView(store: store)
    ///         }
    ///     }
    /// ```
    func sheet<GlobalState, LocalState, GlobalAction, LocalAction, Content>(
        store globalStore: Store<GlobalState, GlobalAction>,
        bindableState toBindableLocalState: WritableKeyPath<GlobalState, BindableState<LocalState?>>,
        bindableAction toGlobalAction: @escaping (LocalAction) -> GlobalAction,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Store<LocalState, LocalAction>) -> Content
    ) -> some View
    where Content: View,
          GlobalAction: BindableAction,
          GlobalAction.State == GlobalState,
          GlobalState: Equatable,
          LocalState: Equatable
    {
        self.sheet(
            unwrapping: ViewStore(globalStore).binding(toBindableLocalState),
            onDismiss: onDismiss,
            content: { _ in
                let optionalLocalStore = globalStore.scope(
                    state: { globalState in
                        globalState[keyPath: toBindableLocalState.appending(path: \.wrappedValue)]
                    },
                    action: toGlobalAction
                )
                IfLetStore(optionalLocalStore) { nonOptionalStore in
                    content(nonOptionalStore)
                }
            }
        )
    }
}
