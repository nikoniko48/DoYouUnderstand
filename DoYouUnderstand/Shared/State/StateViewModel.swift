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
