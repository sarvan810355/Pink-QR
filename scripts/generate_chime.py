"""
Synthesizes QR Bloom's soft scan-success chime — a gentle two-note bell
"ting" (no external audio tools available in this environment to record
or encode a real sample). Deliberately soft/sine-based, not a harsh beep.

Run: python3 scripts/generate_chime.py
Outputs: assets/sounds/chime.wav
"""

import math
import os
import struct
import wave

SAMPLE_RATE = 44100


def note(freq, start_s, duration_s, amplitude, total_samples):
    """Renders one bell-like tone (fundamental + soft harmonic, exponential
    decay) into a buffer of `total_samples` starting at `start_s`."""
    buf = [0.0] * total_samples
    start_sample = int(start_s * SAMPLE_RATE)
    n = int(duration_s * SAMPLE_RATE)
    for i in range(n):
        idx = start_sample + i
        if idx >= total_samples:
            break
        t = i / SAMPLE_RATE
        decay = math.exp(-4.5 * t)
        # Fundamental + a quiet octave harmonic for a "bell" timbre, plus a
        # short attack fade-in to avoid a click at note onset.
        attack = min(1.0, i / (SAMPLE_RATE * 0.01))
        sample = (
            math.sin(2 * math.pi * freq * t) * 0.8
            + math.sin(2 * math.pi * freq * 2 * t) * 0.2
        ) * decay * attack * amplitude
        buf[idx] += sample
    return buf


def main():
    total_duration = 0.9
    total_samples = int(total_duration * SAMPLE_RATE)

    # A soft rising two-note "ting-ting" — a gentle fifth interval (C6 -> G6).
    mix = [0.0] * total_samples
    for i, s in enumerate(note(1046.5, 0.00, 0.55, 0.5, total_samples)):
        mix[i] += s
    for i, s in enumerate(note(1568.0, 0.12, 0.65, 0.42, total_samples)):
        mix[i] += s

    peak = max(1e-9, max(abs(x) for x in mix))
    scale = 0.9 / peak

    out_dir = os.path.join(os.path.dirname(__file__), "..", "assets", "sounds")
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, "chime.wav")

    with wave.open(out_path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        frames = b"".join(
            struct.pack("<h", int(max(-1.0, min(1.0, s * scale)) * 32767)) for s in mix
        )
        w.writeframes(frames)

    print(f"wrote {out_path}")


if __name__ == "__main__":
    main()
