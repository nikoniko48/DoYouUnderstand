//
//  DashboardView.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 09/06/2026.
//

import SwiftUI

struct DashboardView: View {
    
    typealias Typography = Theme.Typography
    typealias Colors = Theme.Colors
    
    @State var viewModel: DashboardViewModel
    
    init(output: @escaping (DashboardViewModel.Output) -> Void) {
        self.viewModel = .init(
            useMocks: true,
            output: output
        )
    }
    
    var body: some View {
        StateScreen(state: viewModel.state) { stateModel in
            ContentView(
                stateModel: stateModel,
                actions: viewModel.actions
            )
        }
    }
}

extension DashboardView {
    
    struct ContentView: View {
        
        let stateModel: DashboardViewModel.StateModel
        let actions: DashboardViewModel.Actions
        
        var body: some View {
            VStack(spacing: .space0) {
                
                HStack(alignment: .center, spacing: .space0) {
                    
                    VStack(alignment: .leading, spacing: .space2) {
                        Text("TEXT ANALYZER")
                            .font(Typography.bodyText)
                            .foregroundStyle(Colors.Text.muted)
                        
                        Text("DO YOU\nUNDERSTAND?!")
                            .font(Typography.hugeTitle)
                            .foregroundStyle(Colors.Text.title)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "questionmark.circle")
                        .font(Typography.screenTitle)
                        .foregroundStyle(Colors.Text.muted)
                        .padding(.trailing, .space12)
                    
                    HStack(spacing: .space4) {
                        Image(systemName: "bolt.fill")
                            .font(Typography.bodyText)
                        
                        Text("\(stateModel.scansRemaining)")
                            .font(Typography.bodyText)
                    }
                    .foregroundStyle(Colors.Main.accent)
                    .padding(.horizontal, .space12)
                    .padding(.vertical, .space6)
                    .background(Colors.Main.accent.opacity(0.12))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Colors.Main.accent.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.bottom, .space16)
                
                Rectangle()
                    .fill(Colors.Main.borderSubtle)
                    .frame(height: 1)
                    .padding(.horizontal, -StaticData.Layout.screenPadding)
                    .padding(.bottom, .space16)
                
                Text("RECENT ANALYSES")
                    .font(Typography.bodyText)
                    .foregroundStyle(Colors.Text.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, .space8)
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: .space12) {
                        // TODO: add a nice screen for when the user doesn't have any history items yet
                        if stateModel.history.isEmpty {
                            Text("No analyses yet. Start decoding!")
                                .font(Typography.bodyText)
                                .foregroundStyle(Colors.Text.muted)
                        } else {
                            ForEach(stateModel.history) { item in
                                HistoryCardView(item: item)
                            }
                        }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    Button {
                        actions.onNavigate?(.input)
                    } label: {
                        Image(systemName: "plus")
                            .font(Typography.hugeTitle)
                            .foregroundStyle(Colors.Text.title)
                            .frame(width: StaticData.Layout.buttonSize.height, height: StaticData.Layout.buttonSize.width)
                            .background(
                                LinearGradient(
                                    colors: [Colors.Main.primary, Colors.Main.primaryGradientEnd],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Colors.Text.title.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Colors.Main.accent.opacity(0.4), radius: 16, x: 0, y: 8)
                    }
                    .padding(.bottom, .space12)
                }
            }
            .padding(.horizontal, StaticData.Layout.screenPadding)
        }
    }
}

#Preview {
    let view = DashboardView(output: { _ in })
    
    view.viewModel.state = .loaded(
        DashboardViewModel.StateModel(history: HistoryItem.mockList, scansRemaining: 7)
    )
    
    return view
}
