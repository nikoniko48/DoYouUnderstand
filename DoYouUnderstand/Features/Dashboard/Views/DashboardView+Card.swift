//
//  DashboardView+Card.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 10/06/2026.
//

import SwiftUI

struct HistoryCardView: View {
    let item: HistoryItem
    
    typealias Typography = Theme.Typography
    typealias Colors = Theme.Colors
    
    var body: some View {
        VStack(alignment: .leading, spacing: .space12) {
            
            HStack(alignment: .center, spacing: .space0) {
                
                HStack(spacing: .space4) {
                    Text(item.tone.rawValue.uppercased())
                        .font(Typography.badgeLabel)
                        .foregroundStyle(item.toneColor)
                        .padding(.horizontal, .space8)
                        .padding(.vertical, .space4)
                        .background(item.toneColor.opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(item.toneColor.opacity(0.3), lineWidth: 1)
                        )
                    
                    Text(item.type.rawValue.uppercased())
                        .font(Typography.tinyLabel)
                        .foregroundStyle(item.typeColor)
                        .padding(.horizontal, .space6)
                        .padding(.vertical, .space2)
                        .background(item.typeColor.opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(item.typeColor.opacity(0.3), lineWidth: 1)
                        )
                    
                    Spacer(minLength: .space0)

                    Image(systemName: "chevron.right")
                        .font(Typography.smallBody)
                        .foregroundStyle(Colors.Text.muted)
                }
            }
            
            HStack(alignment: .center, spacing: .space12) {
                
                Text(item.snippet)
                    .font(Typography.bodyText)
                    .foregroundStyle(Colors.Text.title)
                    .opacity(0.9)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.trailing, .space32)
            }
            
            
            HStack(spacing: .space4) {
                Image(systemName: "clock")
                Text(item.timestamp)
            }
            .font(Typography.smallBody)
            .foregroundStyle(Colors.Text.muted)
        }
        .padding(.space16)
        .background(Colors.Main.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                .stroke(Colors.Main.borderSubtle, lineWidth: 1)
        )
    }
}
