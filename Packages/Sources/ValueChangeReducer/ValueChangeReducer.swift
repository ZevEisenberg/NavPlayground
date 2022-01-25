import ComposableArchitecture
import SwiftUI
import TCACoordinators
import FlowStacks

// Everything in this file is partial and experimental

public enum ValueChanged<State: Equatable, Action> {
    /// The child reducer changed state
    case stateChanged(State)

    /// Pass along an action from a child reducer
    case action(Action)
}

extension ValueChanged: Equatable where Action: Equatable {}
extension ValueChanged: Hashable where Action: Hashable, State: Hashable {}

// Lightly inspired by https://github.com/pointfreeco/isowords/blob/244925184babddd477d637bdc216fb34d1d8f88d/Sources/TcaHelpers/OnChange.swift
public extension Reducer where State: Equatable {
    func valueChangeReducer() -> Reducer<State, ValueChanged<State, Action>, Environment> {
        .init { state, action, environment in
            switch action {
            case .stateChanged:
                return .none

            case .action(let childAction):
                let previousState = state
                var actions = self.run(&state, childAction, environment)
                    .map(ValueChanged<State, Action>.action)
                if state != previousState {
                    actions = actions
                        .merge(with: .init(value: ValueChanged<State, Action>.stateChanged(state)))
                        .eraseToEffect()
                }
                return actions
            }
        }
    }
}

// LocalAction is ScreenAction
public extension Reducer {
    func onChange<LocalStateThatChanges: Equatable, IntermediateCase>(
        of toLocalState: CasePath<State.Screen, LocalStateThatChanges>,
        updateAll caseKeyPath: CaseKeyPath<State.Screen, IntermediateCase, LocalStateThatChanges>
    ) -> Self
    where State: IndexedRouterState
    {
        .init { state, action, environment in
            let previousLocalState = toLocalState.extract(from: state.)
            let actions = self.run(&state, action, environment)
            let newLocalState = toLocalState.extract(from: state)
            if newLocalState != previousLocalState {
                for (index, route) in zip(state.routes.indices, state.routes) {
                    if var localState = toLocalState.extract(from: state) {
//                        state.routes[index].screen = caseKeyPath.casePath.embed(<#T##value: IntermediateCase##IntermediateCase#>)
//                        state[keyPath: caseKeyPath.keyPath] = caseKeyPath.casePath.embed(state[keyPath: caseKeyPath.keyPath])
                    }
                }
            }
            return actions
        }
    }
}

public struct CaseKeyPath<Root, Case, Value> {
    public var casePath: CasePath<Root, Case>
    public var keyPath: WritableKeyPath<Case, Value>

    public init(
        casePath: CasePath<Root, Case>,
        keyPath: WritableKeyPath<Case, Value>
    ) {
        self.casePath = casePath
        self.keyPath = keyPath
    }
}

public extension CasePath {
    static func .. <Root, Case, Value>(
        casePath: CasePath<Root, Case>,
        keyPath: WritableKeyPath<Case, Value>
    ) -> CaseKeyPath<Root, Case, Value> {
        CaseKeyPath<Root, Case, Value>(casePath: casePath, keyPath: keyPath)
    }
}

//extension Reducer {
//    func pullback<GlobalState, GlobalAction, GlobalEnvironment, GlobalCase>(
//        state toLocalState: CaseKeyPath<GlobalState, GlobalCase, State>,
//        action toLocalAction: CasePath<GlobalAction, Action>,
//        environment toLocalEnvironment: @escaping (GlobalEnvironment) -> Environment
//    ) -> Reducer<GlobalState, GlobalAction, GlobalEnvironment> {
//        .init { globalState, globalAction, globalEnvironment in
//            guard let localAction = toLocalAction.extract(from: globalAction) else { return .none }
//
//            var localCase = toLocalState.casePath.extract(from: globalState)!
//            var localState = localCase[keyPath: toLocalState.keyPath]
//
//            defer {
//                localCase[keyPath: toLocalState.keyPath] = localState
//                globalState = toLocalState.casePath.embed(localCase)
//            }
//
//            let effects = self.run(
//                &localState,
//                localAction,
//                toLocalEnvironment(globalEnvironment)
//            )
//            .map(toLocalAction.embed)
//
//            return effects
//        }
//    }
//}

//public func appending<AppendedValue>(path: CasePath<Value, AppendedValue>) -> CasePath<
//  Root, AppendedValue
//> {
//  CasePath<Root, AppendedValue>(
//    embed: { self.embed(path.embed($0)) },
//    extract: { self.extract(from: $0).flatMap(path.extract) }
//  )
//}
