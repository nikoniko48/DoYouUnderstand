//
//  InputStateModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 16/06/2026.
//

extension InputViewModel {
    
    struct StateModel: StateModelProtocol {
        var inputText: String = ""
        var selectedType: AnalysisType = .explain
        
        var characterCount: Int {
            inputText.count
        }
        
        var isAnalysisEnabled: Bool {
            !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            // TODO: also include when photo is added
        }
    }
}
