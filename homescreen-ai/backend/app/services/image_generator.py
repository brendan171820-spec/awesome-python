"""
Image generation service for wallpapers and app icons.
Uses DALL-E 3 for wallpapers and custom SVG generation for icons.
"""

import asyncio
import io
import re
from pathlib import Path

import httpx
from openai import AsyncOpenAI
from PIL import Image, ImageDraw, ImageFilter

openai_client = AsyncOpenAI()


async def generate_wallpaper(theme_profile: dict, resolution: str = "1179x2556") -> bytes:
    """
    Generate a wallpaper for iPhone 15 Pro resolution (1179x2556 px).
    Returns PNG bytes.
    """
    prompt = (
        f"{theme_profile['wallpaper_prompt']}. "
        f"Style: {theme_profile['aesthetic']}, mood: {theme_profile['mood']}. "
        "Ultra HD mobile wallpaper, portrait orientation, no text, no UI elements."
    )

    response = await openai_client.images.generate(
        model="dall-e-3",
        prompt=prompt,
        size="1024x1792",  # Closest to iPhone ratio
        quality="hd",
        n=1,
    )

    async with httpx.AsyncClient() as client:
        img_response = await client.get(response.data[0].url)
        img_bytes = img_response.content

    # Resize to exact iPhone resolution
    img = Image.open(io.BytesIO(img_bytes))
    w, h = map(int, resolution.split("x"))
    img = img.resize((w, h), Image.LANCZOS)

    output = io.BytesIO()
    img.save(output, format="PNG", optimize=True)
    return output.getvalue()


def generate_icon_svg(app_name: str, theme_profile: dict) -> str:
    """Generate an SVG icon for a given app based on the theme."""
    primary = theme_profile["primary_color"]
    secondary = theme_profile["secondary_color"]
    accent = theme_profile["accent_color"]
    style = theme_profile["icon_style"]

    # First letter of app name as icon
    letter = app_name[0].upper()

    gradient_id = f"grad_{re.sub(r'[^a-zA-Z0-9]', '', app_name)}"

    if style == "glassmorphism":
        svg = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 60 60">
  <defs>
    <linearGradient id="{gradient_id}" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:{primary};stop-opacity:0.8"/>
      <stop offset="100%" style="stop-color:{secondary};stop-opacity:0.6"/>
    </linearGradient>
    <filter id="blur"><feGaussianBlur stdDeviation="2"/></filter>
  </defs>
  <rect width="60" height="60" rx="13" fill="url(#{gradient_id})"/>
  <rect width="60" height="60" rx="13" fill="white" opacity="0.1"/>
  <text x="30" y="39" font-family="SF Pro Display, Arial" font-size="24"
        font-weight="600" fill="white" text-anchor="middle">{letter}</text>
</svg>"""
    elif style == "neon":
        svg = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 60 60">
  <rect width="60" height="60" rx="13" fill="#0a0a0a"/>
  <rect width="58" height="58" x="1" y="1" rx="12" fill="none"
        stroke="{accent}" stroke-width="1.5" opacity="0.8"/>
  <text x="30" y="39" font-family="SF Pro Display, Arial" font-size="24"
        font-weight="700" fill="{accent}" text-anchor="middle"
        filter="url(#glow)">{letter}</text>
  <defs>
    <filter id="glow">
      <feGaussianBlur stdDeviation="3" result="coloredBlur"/>
      <feMerge><feMergeNode in="coloredBlur"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>
</svg>"""
    else:  # flat default
        svg = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 60 60">
  <defs>
    <linearGradient id="{gradient_id}" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:{primary}"/>
      <stop offset="100%" style="stop-color:{secondary}"/>
    </linearGradient>
  </defs>
  <rect width="60" height="60" rx="13" fill="url(#{gradient_id})"/>
  <text x="30" y="39" font-family="SF Pro Display, Arial" font-size="26"
        font-weight="600" fill="white" text-anchor="middle">{letter}</text>
</svg>"""

    return svg


async def generate_icon_pack(
    app_names: list[str],
    theme_profile: dict,
) -> dict[str, bytes]:
    """Generate PNG icons for all requested apps."""
    import cairosvg

    icons = {}
    for app_name in app_names:
        svg = generate_icon_svg(app_name, theme_profile)
        png_bytes = cairosvg.svg2png(bytestring=svg.encode(), output_width=180, output_height=180)
        icons[app_name] = png_bytes

    return icons
