//
//  HomeViewModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 09/06/2026.
//

import SwiftUI

@Observable
final class HomeViewModel {
    
    private(set) var actions: Actions = .init()
    private let output: (Output) -> Void
    
    init(output: @escaping (Output) -> Void) {
        self.output = output
        setActions()
    }
}

extension HomeViewModel {
    
    enum Output {
        case input
        case explanation
        case response
    }
}

extension HomeViewModel {
    
    struct Actions {
        var onNavigate: ((Route) -> Void)?
        
        enum Route {
            case input
            case explanation
            case response
        }
    }
    
    func setActions() {
        actions.onNavigate = { [weak self] route in
            switch route {
            case .input:
                self?.output(.input)
            case .explanation:
                break
            case .response:
                break
            }
        }
    }
}
