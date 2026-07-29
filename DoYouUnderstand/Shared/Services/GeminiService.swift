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

    static func reply(text: String, images: [Data], excludeTones: [Tone] = []) async throws -> ReplyViewModel.Payload {
        let body = AnalyzeRequestBody(
            mode: "reply",
            text: text,
            images: images.map { $0.base64EncodedString() },
            excludeTones: excludeTones.isEmpty ? nil : excludeTones.map { $0.rawValue }
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
}

// MARK: - Networking -

extension GeminiService {

    private struct AnalyzeRequestBody: Encodable {
        let mode: String
        let text: String
        let images: [String]
        var excludeTones: [String]?
        var tone: String?
        var instruction: String?

        init(
            mode: String,
            text: String,
            images: [String],
            excludeTones: [String]? = nil,
            tone: String? = nil,
            instruction: String? = nil
        ) {
            self.mode = mode
            self.text = text
            self.images = images
            self.excludeTones = excludeTones
            self.tone = tone
            self.instruction = instruction
        }
    }

    private static func invoke(_ body: AnalyzeRequestBody) async throws -> Data {
        var request = URLRequest(url: SupabaseManager.functionURL(named: "analyze-message"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(SupabaseManager.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(SupabaseManager.anonKey, forHTTPHeaderField: "apikey")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ServiceError.server(message)
        }

        return data
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
}
