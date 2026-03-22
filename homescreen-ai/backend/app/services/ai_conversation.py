"""
AI conversation service using Claude to gather user preferences
and generate personalized home screen themes.
"""

import anthropic
from typing import AsyncGenerator

client = anthropic.AsyncAnthropic()

SYSTEM_PROMPT = """You are a creative home screen designer AI assistant.
Your goal is to understand the user's aesthetic preferences through friendly conversation,
then generate a complete home screen theme.

Ask about:
1. Favorite colors and color palettes
2. Style preferences (minimalist, vibrant, dark, nature, futuristic, vintage, etc.)
3. Inspirations (movies, games, characters, places, moods)
4. Favorite apps they want highlighted
5. Any specific icons or wallpaper imagery they envision

After gathering info (4-6 questions max), generate a structured theme profile.
Always respond in the user's language.
Keep responses concise and engaging."""


async def chat_stream(
    messages: list[dict],
    theme_profile: dict | None = None,
) -> AsyncGenerator[str, None]:
    """Stream AI responses for the onboarding conversation."""
    system = SYSTEM_PROMPT
    if theme_profile:
        system += f"\n\nCurrent theme profile: {theme_profile}"

    async with client.messages.stream(
        model="claude-sonnet-4-6",
        max_tokens=1024,
        system=system,
        messages=messages,
    ) as stream:
        async for text in stream.text_stream:
            yield text


async def generate_theme_profile(conversation: list[dict]) -> dict:
    """Extract structured theme data from conversation history."""
    response = await client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=2048,
        system="""Extract a structured JSON theme profile from this conversation.
Return ONLY valid JSON with this structure:
{
  "primary_color": "#hex",
  "secondary_color": "#hex",
  "accent_color": "#hex",
  "background_style": "gradient|solid|image",
  "aesthetic": "minimalist|vibrant|dark|nature|futuristic|vintage|gaming|anime",
  "mood": "calm|energetic|mysterious|playful|professional",
  "keywords": ["keyword1", "keyword2"],
  "wallpaper_prompt": "detailed DALL-E prompt for wallpaper",
  "icon_style": "flat|3d|glassmorphism|neon|watercolor",
  "icon_color_scheme": "monochrome|colorful|gradient",
  "app_categories": ["social", "productivity", "games"]
}""",
        messages=conversation + [
            {"role": "user", "content": "Generate the theme profile JSON now."}
        ],
    )
    import json
    return json.loads(response.content[0].text)
