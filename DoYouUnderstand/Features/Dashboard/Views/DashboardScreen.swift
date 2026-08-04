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
                        // A bigger jump than the app-wide `Theme.wideScale`
                        // bump alone - this is the Dashboard's own hero
                        // header, so on iPad it gets to be genuinely bold
                        // rather than just "a little bigger."
                        Text("TEXT ANALYZER")
                            .font(Theme.isWideDevice ? Typography.inter(size: 16, weight: .bold) : Typography.bodyText)
                            .foregroundStyle(Colors.Text.muted)

                        Text("DO YOU\nUNDERSTAND?!")
                            .font(Theme.isWideDevice ? Typography.heroTitle : Typography.hugeTitle)
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
                                // Paired with the List's own `-16` horizontal
                                // padding below: the List's frame is widened
                                // by exactly as much as this insets the row,
                                // so the card lands at the same size/position
                                // it always had, but with real clip-safe
                                // margin around it - both for the card's own
                                // native glass shadow (barely visible in Dark/
                                // Terminal, but clipped hard on the sides in
                                // Light, where it actually shows) and for the
                                // press-and-hold grow. The original 8pt was
                                // only ever sized for the grow, never the
                                // shadow, so it clipped the shadow on the
                                // sides the same way the top used to clip it
                                // before `contentMargins` above fixed that.
                                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
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
                        .scrollIndicators(.hidden)
                        // The glass cards' own native ambient shadow rendered
                        // with nowhere to bleed into above the very first
                        // row - the List's clip boundary sat flush against
                        // the top of that row, chopping the shadow off in a
                        // hard line instead of letting it fade out softly
                        // (this read as much harsher/less subtle than the
                        // same shadow rendered whole, especially obvious
                        // against Light theme's near-white background).
                        // `contentMargins` insets the *scrollable content*
                        // specifically - unlike outer `.padding`, which would
                        // just move the List's own clip boundary along with
                        // its content and never actually create breathing
                        // room inside it.
                        .contentMargins(.top, .space16, for: .scrollContent)
                        // Widens the List's own frame 16pt past the outer
                        // VStack's `screenPadding` on each side - paired
                        // with the matching `listRowInsets` above, the card
                        // itself ends up in exactly the same place it was
                        // before, just with real margin between it and the
                        // List's clip boundary now.
                        //
                        // `.scrollClipDisabled()` used to live here to stop
                        // the List from slicing the glass cards' rounded
                        // corners on the sides - but it disables ALL
                        // clipping, not just horizontal, which let rows
                        // scroll up and render on top of the fixed header
                        // above the List. This fixes the side-clipping
                        // without needing that.
                        .padding(.horizontal, -16)
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
                            .glassEffect(.regular.tint(Colors.Main.accent).interactive(), in: Circle())
                            .contentShape(Circle())
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
