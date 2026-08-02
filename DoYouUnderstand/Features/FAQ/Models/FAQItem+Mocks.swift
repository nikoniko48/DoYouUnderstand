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
            icon: "lock.shield.fill",
            question: "Why is our app so private?",
            answer: "There's no account or sign-in, no ad-tracking IDs, and no cloud database of your messages under our control. Your text or photo is sent to our server only at the moment you ask for an analysis, purely to generate that one result - it isn't stored there or used to train any model. Your history then lives only on your device, so deleting the app deletes it too."
        ),
        FAQItem(
            id: "2",
            icon: "magnifyingglass",
            question: "What is a tone analysis?",
            answer: "We break down a message's subtext, detecting things like passive-aggressiveness, sarcasm, or anxiety, so you understand what someone actually means, not just what they wrote."
        ),
        FAQItem(
            id: "3",
            icon: "doc.text.magnifyingglass",
            question: "What can I do with an Explanation?",
            answer: "An Explanation shows the detected tone with a confidence score, then breaks the message into what was actually said, what they probably meant, the hidden subtext, and a plain-English \"explain it like I'm 5\" summary - everything you need to read between the lines."
        ),
        FAQItem(
            id: "4",
            icon: "bubble.left.and.bubble.right.fill",
            question: "What can I do with a Reply?",
            answer: "You get 5 ready-to-send replies right away in contrasting tones, then can generate any of the other 16 tones on demand by tapping its pill. Tap Tweak on any option to nudge it between two ends of its tone (e.g. more diplomatic vs. more blunt) with a slider, then Regenerate - or just Copy Reply once you've got the one you want."
        ),
        FAQItem(
            id: "5",
            icon: "iphone.gen3",
            question: "Are my messages saved securely?",
            answer: "Yes. Your analysis history is stored locally on your device as part of the app's own data, not in a cloud database we run - it's only ever used to show you your past results."
        ),
        FAQItem(
            id: "6",
            icon: "trash.fill",
            question: "Can I delete my history?",
            answer: "Yes, any time. Swipe left on any entry in your Dashboard history and tap Delete to remove it immediately - there's no confirmation email or waiting period."
        ),
        FAQItem(
            id: "7",
            icon: "checkmark.seal.fill",
            question: "How accurate is the reply generator?",
            answer: "The reply generator drafts options based on the detected tone of the original message. It's a starting point, always review a suggestion before sending it."
        ),
        FAQItem(
            id: "8",
            icon: "wifi",
            question: "Do I need an account or internet connection?",
            answer: "No traditional account or password - just the quick setup you did once. You do need an internet connection though, since each analysis is a live call to our server."
        ),
        FAQItem(
            id: "9",
            icon: "briefcase.fill",
            question: "Can I use this for work and personal messages?",
            answer: "Yes. Whether it's a tricky Slack message, a text from a friend, or a family group chat, you can paste or photograph it and get the same breakdown."
        ),
        FAQItem(
            id: "10",
            icon: "globe",
            question: "Will more languages be supported?",
            answer: "It's on the roadmap. You can already pick a preferred language under Settings > Language - full translated results will roll out to that setting once they're ready."
        )
    ]
}
