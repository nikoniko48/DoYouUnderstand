//
//  StateViewModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 16/06/2026.
//

@MainActor
protocol StateViewModelProtocol: AnyObject {
    associatedtype StateModel: StateModelProtocol
    
    var state: ViewState<StateModel> { get set }
    var stateModel: StateModel { get set }
}

extension StateViewModelProtocol {
    var stateModel: StateModel {
        get {
            if case .loaded(let model) = state { return model }
            return StateModel()
        }
        set {
            state = .loaded(newValue)
        }
    }
}
