//
//  ViewState.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 10/06/2026.
//

import Foundation

enum ViewState<StateModel> {
    case loading
    case loaded(StateModel)
    case error(String)
}
