// Generates the Vibes Nest app icon artwork.
//
//   dart run tool/generate_icon.dart
//
// Writes:
//   assets/icon/icon.png             full icon (legacy launchers, store listing)
//   assets/icon/icon_foreground.png  transparent artwork for adaptive icons
//   assets/icon/splash.png           artwork for the splash screen
//
// Then run `dart run flutter_launcher_icons` and
// `dart run flutter_native_splash:create` to apply them.
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const size = 1024;
final green = img.ColorRgba8(0x29, 0x6e, 0x48, 255);
final lightGreen = img.ColorRgba8(0x4c, 0xa8, 0x76, 255);
final white = img.ColorRgba8(255, 255, 255, 255);
final cream = img.ColorRgba8(0xff, 0xf4, 0xd6, 255);
final leafGreen = img.ColorRgba8(0xa8, 0xe6, 0xb8, 255);

/// Vertical gradient background.
void paintBackground(img.Image im) {
  for (var y = 0; y < im.height; y++) {
    final t = y / (im.height - 1);
    final c = img.ColorRgba8(
      (lightGreen.r + (green.r - lightGreen.r) * t).round(),
      (lightGreen.g + (green.g - lightGreen.g) * t).round(),
      (lightGreen.b + (green.b - lightGreen.b) * t).round(),
      255,
    );
    img.drawLine(im, x1: 0, y1: y, x2: im.width - 1, y2: y, color: c);
  }
}


/// A leaf shape (two arcs meeting at points), rotated by [angle].
void leaf(img.Image im, double cx, double cy, double length, double width,
    double angle, img.Color color) {
  final pts = <img.Point>[];
  const steps = 40;
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    final x = (t - 0.5) * length;
    final y = math.sin(math.pi * t) * width / 2;
    pts.add(_rot(cx, cy, x, -y, angle));
  }
  for (var i = steps; i >= 0; i--) {
    final t = i / steps;
    final x = (t - 0.5) * length;
    final y = math.sin(math.pi * t) * width / 2;
    pts.add(_rot(cx, cy, x, y, angle));
  }
  img.fillPolygon(im, vertices: pts, color: color);
}

img.Point _rot(double cx, double cy, double x, double y, double a) => img.Point(
      cx + x * math.cos(a) - y * math.sin(a),
      cy + x * math.sin(a) + y * math.cos(a),
    );

/// A filled band between two lower half-ellipses (a crescent / bowl shape).
void bowlBand(img.Image im, double cx, double cy, double rxOuter,
    double ryOuter, double rxInner, double ryInner, img.Color color) {
  const steps = 120;
  final pts = <img.Point>[
    for (var i = 0; i <= steps; i++)
      img.Point(cx + rxOuter * math.cos(math.pi * i / steps),
          cy + ryOuter * math.sin(math.pi * i / steps)),
    for (var i = steps; i >= 0; i--)
      img.Point(cx + rxInner * math.cos(math.pi * i / steps),
          cy + ryInner * math.sin(math.pi * i / steps)),
  ];
  img.fillPolygon(im, vertices: pts, color: color);
}

/// A horizontal bar with rounded ends.
void roundedBar(img.Image im, double cx, double cy, double halfWidth,
    double radius, img.Color color) {
  img.fillRect(im,
      x1: (cx - halfWidth).round(),
      y1: (cy - radius).round(),
      x2: (cx + halfWidth).round(),
      y2: (cy + radius).round(),
      color: color);
  img.fillCircle(im,
      x: (cx - halfWidth).round(),
      y: cy.round(),
      radius: radius.round(),
      color: color,
      antialias: true);
  img.fillCircle(im,
      x: (cx + halfWidth).round(),
      y: cy.round(),
      radius: radius.round(),
      color: color,
      antialias: true);
}

/// Draws the nest + sprout artwork centred at (cx, cy), scaled by [s]
/// (s = 1.0 fills roughly the middle 60% of a 1024px canvas).
void artwork(img.Image im, double cx, double cy, double s) {
  // Sprout: stem and two leaves rising from the nest.
  img.fillRect(im,
      x1: (cx - 11 * s).round(),
      y1: (cy - 160 * s).round(),
      x2: (cx + 11 * s).round(),
      y2: cy.round(),
      color: leafGreen);
  leaf(im, cx - 80 * s, cy - 150 * s, 180 * s, 84 * s, -0.6, leafGreen);
  leaf(im, cx + 90 * s, cy - 205 * s, 210 * s, 96 * s, 0.55, leafGreen);

  // Nest: a white bowl with a cream "woven" band.
  bowlBand(im, cx, cy, 300 * s, 190 * s, 0, 0, white);
  bowlBand(im, cx, cy, 262 * s, 158 * s, 226 * s, 118 * s, cream);

  // Rim of the nest.
  roundedBar(im, cx, cy, 300 * s, 24 * s, white);
}

void main() {
  Directory('assets/icon').createSync(recursive: true);

  // Full icon: gradient background + artwork.
  final full = img.Image(width: size, height: size, numChannels: 4);
  paintBackground(full);
  artwork(full, size / 2, size * 0.58, 1.0);
  File('assets/icon/icon.png').writeAsBytesSync(img.encodePng(full));

  // Adaptive foreground: artwork only, kept inside the 66% safe zone.
  final fg = img.Image(width: size, height: size, numChannels: 4);
  artwork(fg, size / 2, size * 0.56, 0.72);
  File('assets/icon/icon_foreground.png').writeAsBytesSync(img.encodePng(fg));

  // Splash artwork: same as the foreground, on transparent background.
  File('assets/icon/splash.png').writeAsBytesSync(img.encodePng(fg));

  stdout.writeln('Icons written to assets/icon/');
}
