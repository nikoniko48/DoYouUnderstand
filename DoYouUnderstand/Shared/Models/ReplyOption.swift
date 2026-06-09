//
//  ReplyOption.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 10/06/2026.
//

import SwiftUI

struct ReplyOption: Identifiable, Hashable {
    let id: String
    let tone: String
    let emoji: String
    let colorHex: String
    let bgHex: String
    let borderColorHex: String
    let reply: String
}
