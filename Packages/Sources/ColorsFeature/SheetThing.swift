import SwiftUI
import SwiftUINavigation
import ComposableArchitecture

extension View {
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
}
