Place a short, gentle chime sound effect here named "chime.mp3" (played on
successful scan by lib/services/feedback_service.dart). Keep it under ~1s
and soft — think a light bell/sparkle "ting", not a harsh beep.

FeedbackService already fails silently if this file is missing, so the app
still runs without it — but scan success will be haptic-only until you add it.
