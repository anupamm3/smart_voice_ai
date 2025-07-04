# 🧠 Smart Voice AI

Smart Voice AI is a voice-controlled Flutter application that acts as a personal assistant by understanding natural speech, generating intelligent responses using OpenAI's ChatGPT API, and reading them aloud using text-to-speech.

---

## ✨ Features

- 🎙️ **Voice Input** — Tap to speak using speech recognition
- 🤖 **ChatGPT Integration** — Get smart replies based on natural language
- 🗣️ **Text-to-Speech** — Assistant reads the response aloud
- 🖼️ **DALL·E Integration** — Generate AI images when prompted
- 🧵 **Basic Context Memory** — Retains short conversation history for better responses
- 💡 **Modern UI** — Clean and responsive design using Flutter Material 3
- 📜 **Chat Bubble & Assistant Avatar** — Shows conversation or generated image

---

## 🧰 Tech Stack
**Flutter** (Material 3, Dart)
**OpenAI API** (ChatGPT + DALL·E)
**speech_to_text** (Voice input)
**flutter_tts** (Voice output)
**http** (REST API integration)
**animate_do** (UI animations)

## 📂 Project Structure

lib/
├── main.dart
├── home_page.dart              # Main assistant screen
├── open_services.dart          # OpenAI API services
├── pallete.dart                # Theme & colors
├── feature_box.dart            # Feature UI widget
├── secrets.dart                # Your OpenAI API key
