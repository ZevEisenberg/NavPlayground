//import ComposableArchitecture
//import Overture
//import SwiftUI
//import AutoTCA
//
//public enum ColorsScreenState: Equatable {
//    case main(ColorsView.State)
//    case picker(ColorPickerView.State)
//}
//
//public enum ColorsScreenAction: Equatable {
//    case main(ColorsView.Action)
//    case picker(ColorPickerView.Action)
//}
//
//let colorsScreenReducer = Reducer<ColorsScreenState, ColorsScreenAction, Void>.combine(
//    colorsReducer
//        .pullback(
//            state: /ColorsScreenState.main,
//            action: /ColorsScreenAction.main,
//            environment: { _ in }
//        ),
//    colorPickerReducer
//        .pullback(
//            state: /ColorsScreenState.picker,
//            action: /ColorsScreenAction.picker,
//            environment: { _ in }
//        )
//)
