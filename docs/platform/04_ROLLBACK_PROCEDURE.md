# Rollback Procedure

If a production deployment introduces a critical regression, fails post-deployment verification, or degrades performance beyond acceptable limits, this rollback procedure must be executed immediately.

---

## 1. The Rollback Workflow

```text
If production fails
       ↓
Initiate Rollback
       ↓
Revert to Previous Stable Deployment
       ↓
Verify Stability
       ↓
Investigate Failure
       ↓
Redeploy Fix
```

## 2. Immediate Action (Vercel Rollback)
Vercel keeps all previous deployments immutable and available.
1. Log into the Vercel Dashboard.
2. Navigate to the **Deployments** tab for `my-parents-story`.
3. Identify the last known stable deployment using the Git Commit SHA or deployment timestamp.
4. Click the vertical dots (...) next to the stable deployment.
5. Select **"Assign Custom Domains"** or **"Promote to Production"** to instantly route production traffic back to the stable build.

## 3. Post-Rollback Verification
- Confirm that `myparents.reyouos.com` resolves to the rolled-back version.
- Ensure no data corruption occurred in the Life Graph during the faulty deployment window.
- Monitor observability tools for unhandled exceptions.

## 4. Investigation & Fix
- Do not attempt to "hotfix" production directly.
- Identify the root cause in a local environment.
- Create a new branch with the fix.
- Push the fix through the standard CI/CD pipeline and Release Gates defined in `02_DEPLOYMENT_CONSTITUTION.md`.
