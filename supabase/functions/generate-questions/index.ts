import Anthropic from "npm:@anthropic-ai/sdk@0.36.3";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const anthropicKey = Deno.env.get("ANTHROPIC_API_KEY")!;

interface HNStory {
  title: string;
  url?: string;
  score: number;
}

interface GeneratedQuestion {
  type: string;
  category: string;
  difficulty: string;
  prompt: string;
  content: Record<string, unknown>;
  explanation: string;
  tags: string[];
  xp_value: number;
  estimated_seconds: number;
  published_date: string;
}

async function fetchTopTechStories(): Promise<string[]> {
  const res = await fetch("https://hacker-news.firebaseio.com/v0/topstories.json");
  const ids: number[] = await res.json();
  const top20 = ids.slice(0, 20);

  const stories: HNStory[] = await Promise.all(
    top20.map(async (id) => {
      const r = await fetch(`https://hacker-news.firebaseio.com/v0/item/${id}.json`);
      return r.json();
    })
  );

  return stories
    .filter((s) => s && s.title)
    .map((s) => s.title)
    .slice(0, 10);
}

async function generateQuestions(stories: string[]): Promise<GeneratedQuestion[]> {
  const client = new Anthropic({ apiKey: anthropicKey });
  const today = new Date().toISOString().split("T")[0];

  const prompt = `You are generating daily Product Manager learning questions for an app called PM Daily.

Today's top tech news headlines:
${stories.map((s, i) => `${i + 1}. ${s}`).join("\n")}

Generate exactly 8 questions in valid JSON array format. Requirements:
- 2 questions of type "currentEvents" inspired by the headlines above
- 2 questions of type "interviewPrep" (PM interview scenarios or frameworks)
- 2 questions of type "pmFrameworks" (RICE, AARRR, CIRCLES, Jobs-to-be-Done, etc.)
- 2 questions of type "aiTechFundamentals" (AI/ML concepts relevant to PMs)

Each question must follow this exact JSON structure:
{
  "type": "multipleChoice" | "trueFalse" | "scenario" | "fillInBlank" | "matching" | "ordering",
  "category": "currentEvents" | "interviewPrep" | "pmFrameworks" | "aiTechFundamentals",
  "difficulty": "beginner" | "intermediate" | "advanced",
  "prompt": "The question text",
  "content": { ... type-specific fields ... },
  "explanation": "Why this answer is correct (2-3 sentences)",
  "tags": ["tag1", "tag2"],
  "xp_value": 10 | 15 | 20,
  "estimated_seconds": 20-90,
  "published_date": "${today}"
}

Content field formats by type:
- multipleChoice: { "type": "multipleChoice", "options": ["A","B","C","D"], "correctIndex": 0 }
- trueFalse: { "type": "trueFalse", "answer": true }
- scenario: { "type": "scenario", "scenarioText": "...", "options": ["A","B","C","D"], "correctIndex": 0 }
- fillInBlank: { "type": "fillInBlank", "template": "... ___ ...", "blanks": [{"position":0,"answer":"x","alternateAnswers":[],"caseSensitive":false}] }
- matching: { "type": "matching", "pairs": [{"id":"p1","left":"x","right":"y"}], "distractors": ["z"] }
- ordering: { "type": "ordering", "steps": ["A","B","C","D"], "correctOrder": [2,0,3,1] }

Use a mix of types. Make questions practical and relevant to working PMs in 2025.
Return ONLY a valid JSON array, no markdown, no explanation outside the JSON.`;

  const message = await client.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 4096,
    messages: [{ role: "user", content: prompt }],
  });

  const text = message.content[0].type === "text" ? message.content[0].text : "";
  const jsonMatch = text.match(/\[[\s\S]*\]/);
  if (!jsonMatch) throw new Error("No JSON array found in Claude response");
  return JSON.parse(jsonMatch[0]);
}

async function insertQuestions(questions: GeneratedQuestion[]): Promise<void> {
  const res = await fetch(`${supabaseUrl}/rest/v1/questions`, {
    method: "POST",
    headers: {
      "apikey": supabaseKey,
      "Authorization": `Bearer ${supabaseKey}`,
      "Content-Type": "application/json",
      "Prefer": "return=minimal",
    },
    body: JSON.stringify(questions),
  });
  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Supabase insert failed: ${err}`);
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: { "Access-Control-Allow-Origin": "*" } });
  }

  try {
    console.log("Fetching top HN stories...");
    const stories = await fetchTopTechStories();
    console.log(`Got ${stories.length} stories`);

    console.log("Generating questions with Claude...");
    const questions = await generateQuestions(stories);
    console.log(`Generated ${questions.length} questions`);

    console.log("Inserting into Supabase...");
    await insertQuestions(questions);

    return Response.json({
      success: true,
      generated: questions.length,
      date: new Date().toISOString().split("T")[0],
    });
  } catch (err) {
    console.error(err);
    return Response.json({ success: false, error: String(err) }, { status: 500 });
  }
});
