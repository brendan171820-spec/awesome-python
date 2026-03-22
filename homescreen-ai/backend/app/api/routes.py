"""
Main API routes for HomeScreen AI.
"""

import json
import zipfile
import io

from fastapi import APIRouter, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel

from app.services.ai_conversation import chat_stream, generate_theme_profile
from app.services.image_generator import generate_wallpaper, generate_icon_pack

router = APIRouter()


class ChatMessage(BaseModel):
    role: str  # "user" or "assistant"
    content: str


class ChatRequest(BaseModel):
    messages: list[ChatMessage]
    session_id: str


class GenerateThemeRequest(BaseModel):
    messages: list[ChatMessage]
    app_names: list[str] = [
        "Instagram", "TikTok", "Spotify", "Messages", "Camera",
        "Settings", "Safari", "Photos", "Maps", "Notes"
    ]


@router.post("/chat/stream")
async def chat_endpoint(request: ChatRequest):
    """Stream AI conversation responses."""
    messages = [m.model_dump() for m in request.messages]

    async def generate():
        async for chunk in chat_stream(messages):
            yield f"data: {json.dumps({'text': chunk})}\n\n"
        yield "data: [DONE]\n\n"

    return StreamingResponse(generate(), media_type="text/event-stream")


@router.post("/theme/generate")
async def generate_theme(request: GenerateThemeRequest):
    """
    From conversation history, extract theme profile and
    generate wallpaper + icon pack as a ZIP file.
    """
    messages = [m.model_dump() for m in request.messages]

    # Step 1: Extract structured theme from conversation
    try:
        theme_profile = await generate_theme_profile(messages)
    except Exception as e:
        raise HTTPException(status_code=422, detail=f"Could not parse theme: {e}")

    # Step 2: Generate wallpaper and icons in parallel
    wallpaper_bytes, icon_pack = await _generate_assets(theme_profile, request.app_names)

    # Step 3: Bundle everything in a ZIP
    zip_bytes = _create_theme_zip(theme_profile, wallpaper_bytes, icon_pack)

    return StreamingResponse(
        io.BytesIO(zip_bytes),
        media_type="application/zip",
        headers={"Content-Disposition": "attachment; filename=my_theme.zip"},
    )


@router.post("/theme/preview")
async def preview_theme(request: GenerateThemeRequest):
    """Return theme profile JSON for live preview (no image generation)."""
    messages = [m.model_dump() for m in request.messages]
    theme_profile = await generate_theme_profile(messages)
    return {"theme": theme_profile}


async def _generate_assets(
    theme_profile: dict, app_names: list[str]
) -> tuple[bytes, dict[str, bytes]]:
    import asyncio
    wallpaper_task = generate_wallpaper(theme_profile)
    icons_task = generate_icon_pack(app_names, theme_profile)
    return await asyncio.gather(wallpaper_task, icons_task)


def _create_theme_zip(
    theme_profile: dict,
    wallpaper_bytes: bytes,
    icon_pack: dict[str, bytes],
) -> bytes:
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.writestr("theme.json", json.dumps(theme_profile, indent=2))
        zf.writestr("wallpaper.png", wallpaper_bytes)
        for app_name, icon_bytes in icon_pack.items():
            safe_name = app_name.replace(" ", "_")
            zf.writestr(f"icons/{safe_name}.png", icon_bytes)
        zf.writestr("INSTALLATION_GUIDE.txt", _installation_guide())
    return buf.getvalue()


def _installation_guide() -> str:
    return """HomeScreen AI - Installation Guide
====================================

WALLPAPER:
1. Open Photos app → select wallpaper.png
2. Tap Share → Use as Wallpaper → Set Both

ICONS (requires iOS Shortcuts):
1. Open Shortcuts app → tap "+" → "Add Action"
2. Search "Open App" → select your app
3. Tap the icon next to the shortcut name → "Choose Photo"
4. Select the icon from the icons/ folder
5. Add shortcut to Home Screen

WIDGETS:
- Download "HomeScreen AI" app for dynamic AI widgets

Support: support@homescreenai.app
"""
