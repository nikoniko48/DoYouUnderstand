// analyze-message
//
// Proxies "explain" / "reply" / "tweak" analysis requests to Gemini so the
// API key never ships inside the iOS app.
//
// Deploy:
//   supabase functions deploy analyze-message
// Set the secret once (never commit the key itself):
//   supabase secrets set GEMINI_API_KEY=your-key-here

const GEMINI_MODEL = "gemini-flash-latest";

const TONES = [
  "Anxious",
  "Condescending",
  "Over-Eager",
  "Passive-Aggressive",
  "Sarcastic",
  "Professional",
  "Assertive",
  "Friendly",
];

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// If the input includes a screenshot of a multi-message thread, the model
// tends to reply to (or summarize) the whole conversation instead of the
// specific message it was asked about. This rule keeps it focused.
const THREAD_IMAGE_RULE_EXPLAIN =
  `If the user provides an image of a chat or email thread, read the entire conversation to understand ` +
  `the context, relationship, and tone. However, you must analyze the tone specifically of the FINAL ` +
  `message sent by the other person, not the conversation as a whole. Do not summarize the whole exchange.`;

const THREAD_IMAGE_RULE_REPLY =
  `If the user provides an image of a chat or email thread, read the entire conversation to understand ` +
  `the context, relationship, and tone. However, you must generate your reply specifically addressing the ` +
  `FINAL message sent by the other person. Do not reply to the summary of the chat.`;

const explainSchema = {
  type: "object",
  properties: {
    tone: { type: "string", enum: TONES },
    toneScore: { type: "integer" },
    said: { type: "string" },
    meant: { type: "string" },
    subtext: { type: "string" },
    eli5: { type: "string" },
  },
  required: ["tone", "toneScore", "said", "meant", "subtext", "eli5"],
};

const replySchema = {
  type: "object",
  properties: {
    tone: { type: "string", enum: TONES },
    toneScore: { type: "integer" },
    toneQuote: { type: "string" },
    replies: {
      type: "array",
      items: {
        type: "object",
        properties: {
          tone: { type: "string", enum: TONES },
          text: { type: "string" },
        },
        required: ["tone", "text"],
      },
    },
  },
  required: ["tone", "toneScore", "toneQuote", "replies"],
};

const tweakSchema = {
  type: "object",
  properties: {
    text: { type: "string" },
  },
  required: ["text"],
};

function buildExplainPrompt(text: string): string {
  return `You are analyzing a message someone received so they can understand its real tone and subtext.
Message: """${text}"""

Identify the single dominant tone (one of: ${TONES.join(", ")}), a confidence score 0-100 for that tone,
what was literally said, what the sender actually meant, the unspoken subtext, and a one-sentence
explain-like-I'm-5 summary.

${THREAD_IMAGE_RULE_EXPLAIN}`;
}

function buildReplyPrompt(text: string, excludeTones: string[]): string {
  const base = `You are drafting reply options to a message someone received.
Message: """${text}"""

First identify the single dominant tone of the ORIGINAL message (one of: ${TONES.join(", ")}), a confidence
score 0-100, and the exact quoted phrase from the original message that best reveals that tone.`;

  const repliesInstruction = excludeTones.length > 0
    ? `Then draft exactly 3 NEW ready-to-send reply options, each in a DIFFERENT tone than these already-shown ` +
      `tones: ${excludeTones.join(", ")}. Pick 3 varied, distinct tones from: ${TONES.join(", ")} (excluding the ` +
      `ones already shown) that would be interesting alternative ways to respond.`
    : `Then draft exactly 3 ready-to-send reply options: one Professional, one Assertive, one Friendly.`;

  return `${base}\n${repliesInstruction}\n\n${THREAD_IMAGE_RULE_REPLY}`;
}

function buildTweakPrompt(replyText: string, tone: string, instruction: string): string {
  return `You previously drafted this reply in a ${tone} tone:
"""${replyText}"""

${instruction}

Rewrite the reply accordingly. Keep it a complete, ready-to-send message addressing the same point as the
original reply. Return only the rewritten reply text.`;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const apiKey = Deno.env.get("GEMINI_API_KEY");
    if (!apiKey) {
      throw new Error("Missing GEMINI_API_KEY secret");
    }

    const { mode, text, images, excludeTones, tone, instruction } = await req.json();
    if (mode !== "explain" && mode !== "reply" && mode !== "tweak") {
      throw new Error("mode must be 'explain', 'reply', or 'tweak'");
    }
    if (!text || typeof text !== "string") {
      throw new Error("text is required");
    }

    let promptText: string;
    let schema: Record<string, unknown>;

    switch (mode) {
      case "explain":
        promptText = buildExplainPrompt(text);
        schema = explainSchema;
        break;
      case "reply":
        promptText = buildReplyPrompt(text, (excludeTones ?? []) as string[]);
        schema = replySchema;
        break;
      case "tweak": {
        if (!tone || typeof tone !== "string" || !instruction || typeof instruction !== "string") {
          throw new Error("tone and instruction are required for tweak mode");
        }
        promptText = buildTweakPrompt(text, tone, instruction);
        schema = tweakSchema;
        break;
      }
    }

    const parts: Record<string, unknown>[] = [{ text: promptText }];
    if (mode !== "tweak") {
      for (const base64 of (images ?? []) as string[]) {
        parts.push({ inlineData: { mimeType: "image/jpeg", data: base64 } });
      }
    }

    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-goog-api-key": apiKey,
        },
        body: JSON.stringify({
          contents: [{ role: "user", parts }],
          generationConfig: {
            responseMimeType: "application/json",
            responseSchema: schema,
          },
        }),
      },
    );

    if (!geminiResponse.ok) {
      const errorBody = await geminiResponse.text();
      throw new Error(`Gemini request failed: ${errorBody}`);
    }

    const geminiJson = await geminiResponse.json();
    const rawText = geminiJson.candidates?.[0]?.content?.parts?.[0]?.text;
    if (!rawText) {
      throw new Error("Gemini returned no content");
    }

    return new Response(rawText, {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : String(error) }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
