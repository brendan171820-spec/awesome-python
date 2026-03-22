# HomeScreen AI - Architecture & Development Plan

## Overview

An iOS app that uses Claude AI to personalize users' iPhone home screens through
a conversational experience. The AI generates wallpapers, icon packs, and widgets.

---

## iOS Constraints & Honest Limitations

### What IS possible
- ✅ Generate custom wallpapers (AI-generated PNG)
- ✅ Generate icon PNG files (custom SVG→PNG)
- ✅ Native WidgetKit widgets (dynamic, theme-aware)
- ✅ Guided installation flow (3-4 steps)
- ✅ Save icons to Photos app
- ✅ Deep link into Shortcuts app

### What is NOT possible on iOS
- ❌ Auto-set wallpaper programmatically (no public API since iOS 7)
- ❌ Change other apps' icons (sandbox restriction)
- ❌ Truly "1-click" full application without user steps
- ❌ Access Home Screen layout directly

### Best achievable UX
**4-step guided flow** (vs. user's 1-click dream):
1. AI chat (2-3 min) → theme generated
2. Wallpaper saved to Photos → user sets it (1 tap via Settings deep link)
3. Icon pack downloaded → semi-automated via Shortcuts (unavoidable on iOS)
4. Widgets added (1-2 taps)

---

## Tech Stack

### iOS App (Swift/SwiftUI)
- **Language**: Swift 5.9+
- **UI**: SwiftUI
- **Widgets**: WidgetKit
- **Min iOS**: 16.0
- **Key frameworks**: URLSession (streaming), Photos, StoreKit 2

### Backend (Python)
- **Framework**: FastAPI
- **AI**: Claude claude-sonnet-4-6 (Anthropic SDK)
- **Image gen**: DALL-E 3 (OpenAI)
- **Icon gen**: CairoSVG (custom SVG templates)
- **Deploy**: Docker + AWS ECS or Railway.app

### Infrastructure
- **Database**: PostgreSQL (user accounts, themes)
- **Cache**: Redis (session state)
- **Storage**: AWS S3 (generated assets)
- **Payments**: Stripe (subscription model)

---

## Monetization Strategy

### Free Tier
- 1 theme generation
- Basic icon styles
- Standard wallpaper quality

### Pro ($4.99/month or $29.99/year)
- Unlimited generations
- HD wallpapers (1179×2556)
- Premium icon styles (glassmorphism, neon, 3D)
- Priority AI queue

### Lifetime ($79.99 one-time)
- All Pro features forever

---

## Development Roadmap

### Phase 1 - MVP (6-8 weeks)
- [x] Backend API (chat + generation)
- [x] iOS chat UI (onboarding flow)
- [x] Wallpaper generation (DALL-E 3)
- [x] Icon pack generation (SVG templates)
- [x] Basic WidgetKit widget
- [ ] Installation guide flow
- [ ] Xcode project configuration
- [ ] TestFlight beta

### Phase 2 - App Store Launch (4 weeks)
- [ ] Apple Sign-In
- [ ] StoreKit 2 subscriptions
- [ ] Theme history / saved themes
- [ ] Share themes with friends
- [ ] App Store screenshots & preview video
- [ ] App Store submission

### Phase 3 - Growth (ongoing)
- [ ] Social: theme marketplace
- [ ] Seasonal themes (holidays, etc.)
- [ ] Integration with Focus Modes
- [ ] iPad support
- [ ] More icon styles & AI models

---

## App Store Submission Checklist

- [ ] Privacy Policy URL (required)
- [ ] Terms of Service URL
- [ ] App icon 1024×1024 (no alpha)
- [ ] Screenshots: 6.7", 6.1", iPad 12.9"
- [ ] App preview video (optional but recommended)
- [ ] Age rating: 4+
- [ ] Export Compliance: uses HTTPS encryption → answer YES to encryption
- [ ] Review notes explaining AI-generated content
- [ ] Tested on real device (not just simulator)
- [ ] No private API usage (crucial for approval)

---

## Project Structure

```
homescreen-ai/
├── backend/                    # Python FastAPI backend
│   ├── app/
│   │   ├── api/routes.py       # REST endpoints
│   │   ├── core/config.py      # Settings & env vars
│   │   └── services/
│   │       ├── ai_conversation.py   # Claude chat
│   │       └── image_generator.py  # DALL-E + SVG icons
│   ├── Dockerfile
│   └── requirements.txt
│
└── ios-app/
    └── HomeScreenAI/
        ├── Views/
        │   ├── OnboardingChatView.swift   # Main chat UI
        │   └── ThemePreviewView.swift     # Preview + install
        ├── Models/
        │   └── ChatViewModel.swift        # State management
        ├── Services/
        │   └── APIService.swift           # Backend calls
        └── Widgets/
            └── HomeScreenWidget.swift     # WidgetKit widget
```

---

## Environment Variables (backend/.env)

```
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
SECRET_KEY=your-random-secret
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
STRIPE_SECRET_KEY=sk_live_...
```
