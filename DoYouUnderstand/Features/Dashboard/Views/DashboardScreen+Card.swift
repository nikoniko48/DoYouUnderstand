//
//  DashboardScreen+Card.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 10/06/2026.
//

import SwiftUI

struct HistoryCardView: View {
    let item: HistoryItem

    typealias Typography = Theme.Typography
    typealias Colors = Theme.Colors

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius, style: .continuous)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .space12) {
            
            HStack(alignment: .center, spacing: .space0) {
                
                HStack(spacing: .space4) {
                    Text(item.toneBadge.label.uppercased())
                        .font(Typography.badgeLabel)
                        .foregroundStyle(item.toneBadge.color)
                        .padding(.horizontal, .space8)
                        .padding(.vertical, .space4)
                        .background(item.toneBadge.color.opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(item.toneBadge.color.opacity(0.3), lineWidth: 1)
                        )
                    
                    Text(item.type.displayName.uppercased())
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
        .glassEffect(.regular.interactive(), in: shape)
        .contentShape(shape)
    }
}
