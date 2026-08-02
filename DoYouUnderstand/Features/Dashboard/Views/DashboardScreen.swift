//
//  DashboardScreen.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 09/06/2026.
//

import SwiftUI

struct DashboardScreen: View {
    
    typealias Typography = Theme.Typography
    typealias Colors = Theme.Colors
    
    @State var viewModel: DashboardViewModel
    
    init(
        historyService: HistoryServiceProtocol = HistoryServiceProvider.shared,
        output: @escaping (DashboardViewModel.Output) -> Void
    ) {
        self.viewModel = .init(
            historyService: historyService,
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

extension DashboardScreen {
    
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
                    
                    Button {
                        actions.onNavigate?(.faq)
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .font(Typography.screenTitle)
                            .foregroundStyle(Colors.Text.muted)
                    }
                    .padding(.trailing, .space12)

                    Button {
                        actions.onNavigate?(.settings)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(Typography.screenTitle)
                            .foregroundStyle(Colors.Text.muted)
                    }
                    .accessibilityIdentifier("dashboardSettingsButton")
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
                
                Group {
                    if stateModel.history.isEmpty {
                        VStack(spacing: .space16) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 40, weight: .light))
                                .foregroundStyle(Colors.Text.muted)

                            VStack(spacing: .space6) {
                                Text("No analyses yet")
                                    .font(Typography.screenTitle)
                                    .foregroundStyle(Colors.Text.title)

                                Text("Start decoding a message to see\nyour history here.")
                                    .font(Typography.bodyText)
                                    .foregroundStyle(Colors.Text.muted)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.horizontal, StaticData.Layout.majorSpacing)
                        .padding(.bottom, StaticData.Layout.floatingButtonSize.height)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        List {
                            ForEach(stateModel.history) { item in
                                Button {
                                    actions.onTapHistoryItem?(item)
                                } label: {
                                    HistoryCardView(item: item)
                                }
                                .buttonStyle(.plain)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .padding(.bottom, .space12)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        actions.onDeleteHistoryItem?(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .environment(\.defaultMinListRowHeight, 0)
                        .refreshable {
                            actions.onRefresh?()
                        }
                    }
                }
                .onAppear {
                    actions.onRefresh?()
                }
                .safeAreaInset(edge: .bottom) {
                    Button {
                        actions.onNavigate?(.input)
                    } label: {
                        Image(systemName: "plus")
                            .font(Typography.hugeTitle)
                            .foregroundStyle(Colors.Main.accent.contrastingForeground)
                            .frame(width: StaticData.Layout.floatingButtonSize.height, height: StaticData.Layout.floatingButtonSize.width)
                            .background(Colors.Main.accent)
                            .clipShape(Circle())
                    }
                    .accessibilityIdentifier("newAnalysisButton")
                    .padding(.bottom, .space12)
                }
            }
            .padding(.horizontal, StaticData.Layout.screenPadding)
        }
    }
}

#Preview {
    DashboardScreen(historyService: MockHistoryService(), output: { _ in })
}
