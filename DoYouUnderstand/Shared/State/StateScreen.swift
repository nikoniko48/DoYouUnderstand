//
//  StateScreen.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 10/06/2026.
//

import SwiftUI

struct StateScreen<StateModel, Content: View>: View {
    
    let state: ViewState<StateModel>
    
    @ViewBuilder let content: (StateModel) -> Content
    
    init(
        state: ViewState<StateModel>,
        @ViewBuilder content: @escaping (StateModel) -> Content
    ) {
        self.state = state
        self.content = content
    }
    
    var body: some View {
        ZStack {
            Theme.Colors.Main.background
                .ignoresSafeArea()
            
            switch state {
            case .loading:
                // TODO: Implement a nice loading view
                ProgressView()
                    .tint(Theme.Colors.Main.accent)
                    .scaleEffect(1.5)
                
            case .loaded(let stateModel):
                content(stateModel)
                
            case .error(let message):
                // TODO: Implement a nice error alert view
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(Theme.Typography.hugeTitle)
                        .foregroundStyle(Theme.Colors.Text.title)
                    Text(message)
                        .font(Theme.Typography.bodyText)
                        .foregroundStyle(Theme.Colors.Text.muted)
                }
            }
        }
    }
}
