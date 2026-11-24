# 🪐 NovaMind — AI Cognitive Learning & Focus OS

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Gemini AI](https://img.shields.io/badge/Google_Gemini-3.5_Flash-8E75C2?style=for-the-badge&logo=google&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-Auth_%26_DB-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Riverpod](https://img.shields.io/badge/State-Riverpod_2.0-blueviolet?style=for-the-badge)

**A next-generation AI learning and productivity operating system designed with dark cyberpunk glassmorphism, real-time neural gamification, and arcade knowledge battles.**

</div>

---

## ✨ Features That Stand Out

### 🪐 1. Living Core Hero & Cyber-Bento Matrix
* **Living Core Engine**: Multi-orbital rotating gyro-rings with pulsating energy core that responds dynamically to touch and system status.
* **Cyber-Bento Grid**: Clean, high-density modular dashboard tracking live daily task velocity, focus minutes, and cognitive sparks.

### 🎮 2. AI Quiz Arena (Arcade Gamification)
* **Streak Multipliers**: Hit consecutive correct answers for fire combos (`🔥 2x STREAK`, `⚡ 3x STREAK`, `👑 5x UNSTOPPABLE`).
* **Real-time XP Engine**: Earn Cognitive XP, rank up from *Neural Initiate* to *Cognitive Polymath 💎*, and unlock holographic badges.
* **Accuracy Tiering**: Automated performance analysis (`S-Tier Neural Titan`, `A-Tier Cyber Scholar`).

### 🎧 3. Cyber Flow Chamber (Pomodoro Studio)
* **Live Audio Equalizer**: 24 animated neon audio bars that undulate rhythmically during focus sessions.
* **Ambient Soundscapes**: Selectable focus frequencies:
  * `🧠 Alpha 432Hz`
  * `🌧️ Cyber Rain`
  * `🌌 Deep Void 528Hz`
  * `⚡ Gamma 40Hz`
* **Radial Countdown**: Glowing neon timer ring with customizable 15m, 25m, 45m, and 60m sprints.

### 🗺️ 4. Interactive Study Roadmap Engine
* **Vertical Timeline Roadmap**: Converts high-level learning goals into visual milestones with glowing node connectors.
* **1-Tap Task Deployment**: Pushes all roadmap milestones directly into your personal task manager with +50 XP bonus.
* **Interactive Checkpoints**: Track individual milestone progress with completion glows.

### 🧠 5. Smart Cognitive Scanner (Summarizer)
* **High-Yield Distillation**: Compress long articles, lecture notes, and sprint logs with compression analytics (`📉 78% Compression`).
* **Auto-Action Item Detection**: Detects and extracts actionable tasks from meeting notes with 1-tap deployment.
* **Preset Sparks**: Instant quick-fill templates (*AI Agents*, *System Architecture*, *Sprint Notes*).

### 💳 6. Viral Cognitive Flex Cards (Social Sharing)
* **Customizable Skins**: 3 switchable cyberpunk card themes:
  * 🟣 **Cyber Neon** (Violet/Cyan)
  * 🟡 **Obsidian Gold** (Dark Slate/Amber Gold)
  * 🔴 **Solar Plasma** (Purple/Crimson/Pink)
* **Ready for Socials**: Export card stats to Instagram Stories, TikTok, and WhatsApp with 1 tap.

---

## 🛠️ Architecture & Tech Stack

```
lib/
├── core/
│   ├── config/      # AppConfig (Supabase keys, Gemini models)
│   ├── theme/       # AppTheme (Nova dark cyberpunk palette)
│   └── widgets/     # LivingCore, FloatingDock, Background, Logo
├── models/          # Task, Profile data structures
├── providers/       # Riverpod State (GamificationNotifier, TasksNotifier, Profile)
├── screens/         # MainNav, Home, Tasks, Chat, Quiz, Focus, Roadmap, Scanner, Profile
└── services/        # AiService (Gemini failover), AuthService, TaskService, ProfileService
```

* **Client**: Flutter (Mobile, Desktop, Web ready)
* **AI Engine**: Google Gemini API (`gemini-flash-lite-latest` with automatic multi-model failover)
* **Backend**: Supabase (PostgreSQL + Row-Level Security + Supabase Auth)
* **State Management**: Riverpod (`AsyncNotifierProvider` & `StateNotifierProvider`)
* **Local Storage**: `FlutterSecureStorage` (Encrypted gamification & preferences)

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK `^3.10.4`
* Android Studio / VS Code with Flutter extension
* Android Device or Emulator (API 34+)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/SahillmalikUI/novamind.git
   cd novamind
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

4. **(Optional) Configure Gemini API Key**:
   Pass your key via `--dart-define` or configure `lib/core/config/app_config.dart`:
   ```bash
   flutter run --dart-define=GEMINI_API_KEY=your_gemini_api_key
   ```
   *Note: If no API key is supplied, NovaMind automatically runs in offline coaching mode with intelligent built-in fallback heuristics.*

---

## 📄 License
This project is licensed under the MIT License.
