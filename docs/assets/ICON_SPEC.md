# Icon Specifications

## Brand: My Parents' Story

### Colors
- **Primary (Book)**: #3A5A40 (Forest Green)
- **Background (Pages)**: #FAF8F5 (Warm Cream)
- **Accent (Heart)**: #D4A373 (Warm Gold)

### Icon Concept
An open book with a small heart, representing the stories we preserve for our parents.

---

## Android Adaptive Icon

### Files Created
- `android/app/src/main/res/drawable/ic_launcher_background.xml` — Background layer
- `android/app/src/main/res/drawable/ic_launcher_foreground.xml` — Foreground layer
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` — Adaptive icon config
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml` — Round adaptive icon

### Safe Zone
- Canvas: 108dp x 108dp
- Safe zone: 66dp circle centered (61% of canvas)
- All visible content must stay within the inner 66dp circle
- Background extends to full 108dp (handles masking)

### Layer Structure
```
┌─────────────────────────────┐
│         Background          │  108dp (warm cream #FAF8F5)
│  ┌───────────────────────┐  │
│  │      Safe Zone        │  │  66dp circle
│  │  ┌─────────────────┐  │  │
│  │  │   Foreground     │  │  │  Book + heart
│  │  │   (Book + Heart) │  │  │
│  │  └─────────────────┘  │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

---

## Required PNG Sizes

### Android Launcher Icons
| Density | Size | Filename |
|---------|------|----------|
| mdpi | 48x48 | ic_launcher.png |
| hdpi | 72x72 | ic_launcher.png |
| xhdpi | 96x96 | ic_launcher.png |
| xxhdpi | 144x144 | ic_launcher.png |
| xxxhdpi | 192x192 | ic_launcher.png |

### Google Play Store
| Asset | Size | Filename |
|-------|------|----------|
| Hi-res icon | 512x512 | ic_launcher-playstore.png |
| Feature graphic | 1024x500 | feature-graphic.png |

### Screenshots (Phone)
| Device | Resolution |
|--------|------------|
| Pixel 7 | 1080x2400 |
| Pixel 7 Pro | 1440x3120 |
| Samsung S23 | 1080x2340 |

---

## Design Guidelines

### Do
- Keep the book shape simple and recognizable at small sizes
- Use high contrast between book (#3A5A40) and background (#FAF8F5)
- Place the heart within the book's center area
- Test at all density buckets

### Don't
- Add text to the icon (Android guidelines prohibit this)
- Use gradients that break at small sizes
- Place critical elements outside the 66dp safe zone
- Use low-contrast colors that blend together

### Monochrome (Android 13+)
The foreground vector doubles as the monochrome layer. On Android 13+ devices with themed icons, the system will apply a single color to the foreground shape.

---

## Export Checklist

- [ ] Generate PNGs from vector at all 5 density buckets
- [ ] Generate 512x512 Play Store icon
- [ ] Generate 1024x500 feature graphic
- [ ] Test adaptive icon on Android 8.0+ device/emulator
- [ ] Test monochrome on Android 13+ device/emulator
- [ ] Verify safe zone compliance
- [ ] Test on round icon masks (Pixel, Samsung, etc.)
