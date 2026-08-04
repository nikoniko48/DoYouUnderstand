//
//  GeminiService.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 09/06/2026.
//
//  Talks to the `analyze-message` Supabase Edge Function, which in turn calls
//  Gemini. The Gemini API key never lives in the app - it stays server-side.

import Foundation

enum GeminiService {

    enum ServiceError: Error {
        case invalidResponse
        case server(String)
        /// The server's own fair-use cap (keyed by `DeviceIdentifier`, not
        /// the client's local `UsageLimiter` pre-check) rejected this call
        /// before it ever reached Gemini.
        case rateLimited
    }

    static func explain(text: String, images: [Data]) async throws -> ExplanationViewModel.Payload {
        let body = AnalyzeRequestBody(mode: "explain", text: text, images: images.map { $0.base64EncodedString() })
        let data = try await invoke(body)
        let decoded = try JSONDecoder().decode(ExplainResponseBody.self, from: data)

        guard let tone = Tone(rawValue: decoded.tone) else {
            throw ServiceError.invalidResponse
        }

        return ExplanationViewModel.Payload(
            originalMessage: text,
            extractedText: decoded.extractedText,
            tone: tone,
            toneScore: decoded.toneScore,
            said: decoded.said,
            meant: decoded.meant,
            subtext: decoded.subtext,
            eli5: decoded.eli5
        )
    }

    /// Requests one reply per tone in `tones`, in one Gemini call - used for
    /// the initial batch (a handful of contrasting default tones, for a fast
    /// first result) rather than all 16 up front.
    static func reply(
        text: String,
        images: [Data],
        tones: [Tone],
        targetLanguage: ReplyLanguage = .autoDetect
    ) async throws -> ReplyViewModel.Payload {
        let body = AnalyzeRequestBody(
            mode: "reply",
            text: text,
            images: images.map { $0.base64EncodedString() },
            tones: tones.map { $0.rawValue },
            targetLanguage: targetLanguage.rawValue
        )
        let data = try await invoke(body)
        let decoded = try JSONDecoder().decode(ReplyResponseBody.self, from: data)

        guard let tone = Tone(rawValue: decoded.tone) else {
            throw ServiceError.invalidResponse
        }

        let entries = try decoded.replies.map { entry -> ReplyViewModel.Payload.ReplyEntry in
            guard let entryTone = Tone(rawValue: entry.tone) else {
                throw ServiceError.invalidResponse
            }
            return ReplyViewModel.Payload.ReplyEntry(tone: entryTone, text: entry.text)
        }

        return ReplyViewModel.Payload(
            originalMessage: text,
            extractedText: decoded.extractedText,
            tone: tone,
            toneScore: decoded.toneScore,
            toneQuote: decoded.toneQuote,
            replies: entries
        )
    }

    /// On-demand "generate just this one tone" - used when the user taps a
    /// not-yet-generated tone pill on the Reply screen after the initial
    /// batch, and also to regenerate an existing card in a different
    /// language via its Tweak panel's language toggle. Skips re-analyzing
    /// the original message's tone.
    static func replyForTone(text: String, tone: Tone, targetLanguage: ReplyLanguage = .autoDetect) async throws -> String {
        let body = AnalyzeRequestBody(
            mode: "replyForTone",
            text: text,
            images: [],
            tone: tone.rawValue,
            targetLanguage: targetLanguage.rawValue
        )
        let data = try await invoke(body)
        let decoded = try JSONDecoder().decode(TweakResponseBody.self, from: data)
        return decoded.text
    }

    static func tweak(replyText: String, tone: Tone, instruction: String) async throws -> String {
        let body = AnalyzeRequestBody(
            mode: "tweak",
            text: replyText,
            images: [],
            tone: tone.rawValue,
            instruction: instruction
        )
        let data = try await invoke(body)
        let decoded = try JSONDecoder().decode(TweakResponseBody.self, from: data)
        return decoded.text
    }

    /// Analyzes the tone of the user's OWN draft (about to be sent), not a
    /// received message - `tone` is a short freeform label rather than one
    /// of the fixed `Tone` cases, since Refine isn't constrained to that
    /// taxonomy. `colorTone` is a second, separate classification into one
    /// of the fixed `Tone` cases, purely so the UI can reuse `Tone.color`
    /// for the card instead of showing everything in one flat color.
    static func refineAnalyze(text: String) async throws -> RefineAnalysis {
        let body = AnalyzeRequestBody(mode: "refineAnalyze", text: text, images: [])
        let data = try await invoke(body)
        let decoded = try JSONDecoder().decode(RefineAnalyzeResponseBody.self, from: data)

        guard let colorTone = Tone(rawValue: decoded.colorTone) else {
            throw ServiceError.invalidResponse
        }

        return RefineAnalysis(tone: decoded.tone, colorTone: colorTone, summary: decoded.summary)
    }

    static func refineTransform(text: String, action: RefineAction) async throws -> String {
        let body = AnalyzeRequestBody(mode: "refineTransform", text: text, images: [], action: action.rawValue)
        let data = try await invoke(body)
        let decoded = try JSONDecoder().decode(TweakResponseBody.self, from: data)
        return decoded.text
    }
}

extension GeminiService {
    struct RefineAnalysis {
        let tone: String
        let colorTone: Tone
        let summary: String
    }
}

// MARK: - Networking -

extension GeminiService {

    private struct AnalyzeRequestBody: Encodable {
        let mode: String
        let text: String
        let images: [String]
        var tones: [String]?
        var tone: String?
        var instruction: String?
        var targetLanguage: String?
        var action: String?
        // Not part of the memberwise-style init below - every request gets
        // these automatically, so no call site needs to think about them.
        let deviceId: String = DeviceIdentifier.current
        // `nil` outside of `#if DEBUG` builds, so Release/TestFlight/App
        // Store requests never carry it - see `DebugBypass`.
        let debugBypassToken: String? = DebugBypass.token

        init(
            mode: String,
            text: String,
            images: [String],
            tones: [String]? = nil,
            tone: String? = nil,
            instruction: String? = nil,
            targetLanguage: String? = nil,
            action: String? = nil
        ) {
            self.mode = mode
            self.text = text
            self.images = images
            self.tones = tones
            self.tone = tone
            self.instruction = instruction
            self.targetLanguage = targetLanguage
            self.action = action
        }
    }

    /// The very first Gemini call of a session occasionally fails - most
    /// likely a cold Supabase Edge Function start or a transient upstream
    /// 429/503 from Gemini - and simply retrying makes it succeed, which
    /// matches what manually tapping again already did. Retrying here once
    /// automatically means the user usually never sees that first failure
    /// at all.
    private static func invoke(_ body: AnalyzeRequestBody, retriesRemaining: Int = 2) async throws -> Data {
        do {
            var request = URLRequest(url: SupabaseManager.functionURL(named: "analyze-message"))
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(SupabaseManager.anonKey)", forHTTPHeaderField: "Authorization")
            request.setValue(SupabaseManager.anonKey, forHTTPHeaderField: "apikey")
            request.httpBody = try JSONEncoder().encode(body)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ServiceError.invalidResponse
            }

            // The server's own fair-use cap - never worth retrying, since a
            // fixed daily limit won't un-reject itself a moment later.
            if httpResponse.statusCode == 429 {
                throw ServiceError.rateLimited
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw ServiceError.server(message)
            }

            return data
        } catch ServiceError.rateLimited {
            throw ServiceError.rateLimited
        } catch {
            guard retriesRemaining > 0 else { throw error }
            try? await Task.sleep(nanoseconds: 700_000_000)
            return try await invoke(body, retriesRemaining: retriesRemaining - 1)
        }
    }
}

// MARK: - Response DTOs -

extension GeminiService {

    private struct ExplainResponseBody: Decodable {
        let extractedText: String
        let tone: String
        let toneScore: Int
        let said: String
        let meant: String
        let subtext: String
        let eli5: String
    }

    private struct ReplyResponseBody: Decodable {
        struct ReplyEntry: Decodable {
            let tone: String
            let text: String
        }

        let extractedText: String
        let tone: String
        let toneScore: Int
        let toneQuote: String
        let replies: [ReplyEntry]
    }

    private struct TweakResponseBody: Decodable {
        let text: String
    }

    private struct RefineAnalyzeResponseBody: Decodable {
        let tone: String
        let colorTone: String
        let summary: String
    }
}
