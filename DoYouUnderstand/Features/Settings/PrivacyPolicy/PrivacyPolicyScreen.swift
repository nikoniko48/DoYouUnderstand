//
//  PrivacyPolicyScreen.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import SwiftUI

struct PrivacyPolicyScreen: View {

    typealias Typography = Theme.Typography
    typealias Colors = Theme.Colors

    @State var viewModel: PrivacyPolicyViewModel

    init(output: @escaping (PrivacyPolicyViewModel.Output) -> Void) {
        self.viewModel = .init(output: output)
    }

    var body: some View {
        StateScreen(state: viewModel.state) { stateModel in
            ContentView(actions: viewModel.actions)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton { viewModel.actions.onTapBack?() }
            }
            ToolbarItem(placement: .principal) {
                VStack(alignment: .leading, spacing: .space2) {
                    Text("SETTINGS")
                        .font(Typography.badgeLabel)
                        .foregroundStyle(Colors.Text.muted)

                    Text("Privacy Policy")
                        .font(Typography.screenTitle)
                        .foregroundStyle(Colors.Text.title)
                }
            }
        }
    }
}

extension PrivacyPolicyScreen {

    struct ContentView: View {

        let actions: PrivacyPolicyViewModel.Actions

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: .space24) {

                    Text("Last updated August 2026")
                        .font(Typography.smallBody)
                        .foregroundStyle(Colors.Text.muted)
                        .onboardingReveal(delay: 0.06)

                    VStack(alignment: .leading, spacing: .space24) {
                        ForEach(Array(Self.sections.enumerated()), id: \.offset) { index, section in
                            PolicySectionView(section: section)
                                .onboardingReveal(delay: 0.1 + Double(index) * 0.05)
                        }
                    }
                }
                .padding(.horizontal, StaticData.Layout.screenPadding)
                .padding(.top, .space16)
                .padding(.bottom, .space24)
            }
            .scrollIndicators(.hidden)
        }
    }
}

// MARK: - Content -

extension PrivacyPolicyScreen.ContentView {

    struct PolicySection {
        let title: String
        let body: String
    }

    static let sections: [PolicySection] = [
        PolicySection(
            title: "What we collect",
            body: "The text or photo you submit for analysis, and the basics you gave us during setup (name, age range, gender). That's it - no contacts, no location, no browsing history, no ad-tracking identifiers."
        ),
        PolicySection(
            title: "How your messages are analyzed",
            body: "Your message is sent, at the moment you ask for an analysis, to our Supabase Edge Function, which forwards it to Google's Gemini model to generate your explanation or reply. The Gemini API key lives only on our server - it never ships inside the app, and your message isn't used to train any model."
        ),
        PolicySection(
            title: "Where your history lives",
            body: "Your analysis history is stored locally on your device, not in a cloud database we control. Deleting the app deletes your history with it. Swipe-to-delete inside the app removes a single entry immediately."
        ),
        PolicySection(
            title: "Subscriptions",
            body: "Purchases are processed by RevenueCat and Apple's App Store. We receive your subscription status (active, trial, expired) but never your payment details - Apple handles those directly."
        ),
        PolicySection(
            title: "What we don't do",
            body: "We don't sell your data, run third-party ad networks, or share your messages with anyone beyond the Gemini call needed to generate your result."
        ),
        PolicySection(
            title: "Fair use",
            body: "To keep the app fast and free of spam abuse, accounts that generate an unusually high volume of analyses and replies in a single day may briefly hit a fair-use limit. This is generous enough that it shouldn't affect normal use - if you do see it, it resets the next day."
        ),
        PolicySection(
            title: "Your choices",
            body: "You can edit or clear your profile info any time from Settings, delete individual history items from Dashboard, or delete the app to remove everything stored on-device."
        ),
        PolicySection(
            title: "Contact",
            body: "Questions about this policy? Reach out from the FAQ section in Settings."
        )
    ]
}

extension PrivacyPolicyScreen {

    struct PolicySectionView: View {

        let section: ContentView.PolicySection

        var body: some View {
            VStack(alignment: .leading, spacing: .space8) {
                Text(LocalizedStringKey(section.title))
                    .font(Theme.Typography.biggerText)
                    .foregroundStyle(Theme.Colors.Text.title)

                Text(LocalizedStringKey(section.body))
                    .font(Theme.Typography.bodyText)
                    .foregroundStyle(Theme.Colors.Text.muted)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.space16)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius, style: .continuous))
        }
    }
}

#Preview {
    PrivacyPolicyScreen(output: { _ in })
}
