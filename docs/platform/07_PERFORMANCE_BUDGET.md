# Performance Budgets

Rather than only targeting Lighthouse scores, this document defines measurable performance budgets for the Flutter Web application.

---

## 1. Web Vitals Targets

The following metrics must be validated via Lighthouse CI or Chrome DevTools before every production release:

| Metric | Budget Target |
| :--- | :--- |
| **First Contentful Paint (FCP)** | `< 2.0 seconds` |
| **Largest Contentful Paint (LCP)** | `< 2.5 seconds` |
| **Time To Interactive (TTI)** | `< 3.0 seconds` |
| **Total Blocking Time (TBT)** | `< 200 ms` |
| **Cumulative Layout Shift (CLS)** | `< 0.1` |

## 2. Bundle Size Budgets
Flutter Web outputs can be large. We must aggressively manage payload sizes.
- **Initial JavaScript Bundle (`main.dart.js`):** `< 2 MB` (compressed/gzipped target).
- **Assets (Fonts, Images):** Must be tree-shaken. Use `--no-tree-shake-icons` strictly only if necessary, otherwise ensure tree-shaking is active.

## 3. Optimization Requirements
- **Wasm:** Actively monitor Flutter's WebAssembly support. Migrate to Wasm compilation (`flutter build web --wasm`) when all plugins are compatible to drastically improve startup time.
- **Renderer:** Use the appropriate renderer (CanvasKit/Skia vs HTML) based on device capabilities if dynamic renderer selection is enabled.

## 4. Quality Scores
Lighthouse baseline scores for the root domain:
- **Accessibility:** `100`
- **SEO:** `100`
- **Best Practices:** `100`
