"""
Verifies the heart-module QR rendering strategy (lib/widgets/heart_qr_painter.dart)
is actually scannable, without needing Flutter's renderer (which hangs to
render in this sandboxed container).

Uses segno (a spec-compliant QR encoder) to get the canonical module matrix
for the same data + error-correction level the Dart code uses, rasterizes it
with the *exact same heart Bezier control points* as heart_qr_painter.dart,
then decodes the result with OpenCV's QRCodeDetector — a real, independent
scanner — to prove round-trip correctness.
"""

import cv2
import numpy as np
import segno

DATA = "https://qrbloom.app/test-scan-12345"
CELL = 24  # px per module — generous, matches an on-screen ~260-400px QR
QUIET = 4  # modules of quiet zone, matching StyledQrView's outer padding


def heart_polygon(cell_px):
    """Same control points as _drawHeart in heart_qr_painter.dart, sampled
    into a polygon via De Casteljau subdivision of the two cubic Beziers."""
    s = cell_px * 0.92
    dx = (cell_px - s) / 2
    dy = (cell_px - s) / 2

    def cubic(p0, p1, p2, p3, n=24):
        pts = []
        for i in range(n + 1):
            t = i / n
            mt = 1 - t
            x = (mt**3) * p0[0] + 3 * (mt**2) * t * p1[0] + 3 * mt * (t**2) * p2[0] + (t**3) * p3[0]
            y = (mt**3) * p0[1] + 3 * (mt**2) * t * p1[1] + 3 * mt * (t**2) * p2[1] + (t**3) * p3[1]
            pts.append((x, y))
        return pts

    start = (dx + s * 0.5, dy + s * 0.95)
    c1 = cubic(
        start,
        (dx - s * 0.4, dy + s * 0.45),
        (dx + s * 0.05, dy - s * 0.12),
        (dx + s * 0.5, dy + s * 0.3),
    )
    c2 = cubic(
        (dx + s * 0.5, dy + s * 0.3),
        (dx + s * 0.95, dy - s * 0.12),
        (dx + s * 1.4, dy + s * 0.45),
        (dx + s * 0.5, dy + s * 0.95),
    )
    return np.array(c1 + c2, dtype=np.int32)


def in_finder_zone(r, c, count):
    return (r < 7 and c < 7) or (r < 7 and c >= count - 7) or (r >= count - 7 and c < 7)


def main():
    qr = segno.make(DATA, error='h')
    matrix = qr.matrix
    count = len(matrix)
    print(f"module count: {count}x{count}")

    img_size = (count + 2 * QUIET) * CELL
    img = np.full((img_size, img_size, 3), 255, dtype=np.uint8)

    heart_poly = heart_polygon(CELL)
    fg = (74, 50, 56)  # BGR-ish, doesn't matter for a grayscale-decoded QR

    for r in range(count):
        for c in range(count):
            if not matrix[r][c]:
                continue
            x0 = (c + QUIET) * CELL
            y0 = (r + QUIET) * CELL
            if in_finder_zone(r, c, count):
                cv2.rectangle(img, (x0, y0), (x0 + CELL, y0 + CELL), fg, -1)
            else:
                offset_poly = heart_poly + np.array([x0, y0])
                cv2.fillPoly(img, [offset_poly], fg)

    cv2.imwrite('/tmp/heart_qr_verify.png', img)
    print("wrote /tmp/heart_qr_verify.png")

    detector = cv2.QRCodeDetector()
    decoded, points, _ = detector.detectAndDecode(img)
    print(f"decoded: {decoded!r}")
    assert decoded == DATA, f"MISMATCH: expected {DATA!r}, got {decoded!r}"
    print("PASS: heart-module QR decoded correctly by an independent scanner")


if __name__ == "__main__":
    main()
