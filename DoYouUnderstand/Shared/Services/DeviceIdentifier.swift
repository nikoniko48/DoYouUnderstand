//
//  DeviceIdentifier.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 03/08/2026.
//
//  A stable, anonymous per-device identifier - no account, sign-in, or
//  personal data involved. Backs the server-side fair-use cap on Gemini
//  calls (see `usage_limits` in the `analyze-message` Edge Function): unlike
//  `UsageLimiter`'s local `UserDefaults` counter, a Keychain item survives
//  an app delete + reinstall on the same device, which is what makes this a
//  meaningful signal the server can actually rely on.

import Foundation
import Security

enum DeviceIdentifier {

    private static let service = "com.doyouunderstand.deviceId"
    private static let account = "deviceId"

    static var current: String {
        if let existing = readFromKeychain() {
            return existing
        }
        let generated = UUID().uuidString
        saveToKeychain(generated)
        return generated
    }

    private static func readFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func saveToKeychain(_ value: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        // Clear any stale item first - `SecItemAdd` fails with `errSecDuplicateItem`
        // if one already exists under this service/account.
        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = Data(value.utf8)
        SecItemAdd(attributes as CFDictionary, nil)
    }
}
