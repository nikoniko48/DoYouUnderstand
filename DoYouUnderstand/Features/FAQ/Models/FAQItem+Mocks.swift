//
//  FAQItem+Mocks.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 29/07/2026.
//

import Foundation

extension FAQItem {

    static let mockList: [FAQItem] = [
        FAQItem(
            id: "1",
            question: "What is a tone analysis?",
            answer: "We break down a message's subtext, detecting things like passive-aggressiveness, sarcasm, or anxiety, so you understand what someone actually means, not just what they wrote."
        ),
        FAQItem(
            id: "2",
            question: "Are my messages saved securely?",
            answer: "Yes. Your pasted text and photos are only used to generate your analysis and reply history, and are stored securely tied to your account."
        ),
        FAQItem(
            id: "3",
            question: "How accurate is the reply generator?",
            answer: "The reply generator drafts options based on the detected tone of the original message. It's a starting point, always review a suggestion before sending it."
        ),
        FAQItem(
            id: "4",
            question: "Can I use this for work and personal messages?",
            answer: "Yes. Whether it's a tricky Slack message, a text from a friend, or a family group chat, you can paste or photograph it and get the same breakdown."
        )
    ]
}
