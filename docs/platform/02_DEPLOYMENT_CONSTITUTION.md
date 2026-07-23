# Deployment Constitution

The Deployment Constitution governs every production release of My Parents' Story. We do not deploy manually; every release follows a unified CI/CD pipeline.

---

## 1. CI/CD Pipeline

Every deployment must flow through the following automated sequence:

```text
GitHub
   ↓
Pull Request
   ↓
Flutter Analyze
   ↓
Flutter Test
   ↓
Build Flutter Web
   ↓
Lighthouse Audit
   ↓
Deploy Preview (Vercel)
   ↓
Manual Approval
   ↓
Production Deployment
   ↓
Post-Deployment Verification
```

## 2. Release Gates

No production deployment may occur unless the following gates pass:

1. **Gate 1:** `flutter analyze` completes with 0 issues.
2. **Gate 2:** `flutter test` completes with 100% success.
3. **Gate 3:** `flutter build web` succeeds with no fatal WebAssembly or plugin errors.
4. **Gate 4:** Lighthouse CI meets the Performance Budget.
5. **Gate 5:** Manual QA on the Vercel Preview URL.
6. **Gate 6:** Production Deploy.

## 3. Release Versioning

Every deployment must generate and log the following metadata:
- **Version:** SemVer (e.g., v1.2.0)
- **Build Number:** Incremental integer
- **Git Commit:** Full SHA
- **Deployment Time:** ISO 8601 UTC
- **Flutter Version:** The version of the Flutter SDK used to build
- **Deployment URL:** The canonical URL
- **Release Notes:** Functional changes and fixes

## 4. Release Deliverables

Each production deployment must generate and archive:
- Deployment Report
- Lighthouse Report
- Performance Report
- Accessibility Report
- SEO Report
- Browser Compatibility Report
- Release Notes
- Version Manifest

## 5. Domain Structure

To ensure scalable architecture, domains are strictly separated by responsibility:

- `reyouos.com` → Landing page (Marketing)
- `myparents.reyouos.com` → The Application
- `docs.reyouos.com` → Documentation
- `api.reyouos.com` → Future backend services
- `status.reyouos.com` → Service status

*Note: `reyouos.com` and `www.reyouos.com` must use a single canonical redirect.*
