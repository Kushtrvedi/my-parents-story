import { createHash, createHmac, randomBytes } from "crypto";

// ─── Types ──────────────────────────────────────────────

export type EvidenceCategory = "state-transition" | "prediction" | "decision" | "privacy" | "physics" | "observation" | "custom";

export interface ScientificMetadata {
  modelId?: string;
  modelVersion?: string;
  parameters?: Record<string, unknown>;
  calibrationDate?: string;
  confidence?: number;
  uncertainty?: number;
}

export interface ExperimentMetadata {
  experimentId?: string;
  hypothesis?: string;
  methodology?: string;
  sampleSize?: number;
  duration?: number;
  outcome?: string;
}

export interface CertificationMetadata {
  certificationId?: string;
  standard?: string;
  auditor?: string;
  certifiedAt?: string;
  expiresAt?: string;
  level?: string;
}

export interface EvidenceBundle {
  id: string;
  bundleId: string;
  createdAt: Date;
  updatedAt: Date;
  timestamp: Date;
  source: string;
  action: string;
  rationale: string;
  input: Record<string, unknown>;
  output: Record<string, unknown>;
  confidence: number;
  category: EvidenceCategory;
  constitutionalArticles: string[];
  architecturalLaws: string[];
  trustScore: number;
  hash: string;
  previousHash: string;
  chainDepth: number;
  signature: string;
  metadata: Record<string, unknown>;
  scientific?: ScientificMetadata;
  experiment?: ExperimentMetadata;
  certification?: CertificationMetadata;
  /** Duration of the action in milliseconds */
  duration?: number;
  /** Result of the action: success, failure, partial, pending */
  result?: "success" | "failure" | "partial" | "pending";
}

export interface AuditEntry {
  timestamp: Date;
  action: "record" | "retrieve" | "verify" | "replay" | "tamper-detected";
  bundleId: string;
  details: string;
}

export interface ChainIntegrityResult {
  valid: boolean;
  totalBundles: number;
  brokenLinks: number;
  firstBrokenLink?: string;
}

export interface ReplayResult {
  bundle: EvidenceBundle;
  replayedAt: Date;
  originalHash: string;
  replayHash: string;
  match: boolean;
}

// ─── Hashing ────────────────────────────────────────────

export function hashPayload(payload: unknown): string {
  const json = JSON.stringify(payload, Object.keys(payload as Record<string, unknown>).sort());
  return createHash("sha256").update(json).digest("hex");
}

export function hashBundle(bundle: Omit<EvidenceBundle, "hash">): string {
  const HASH_EXCLUDED = new Set(["hash", "signature"]);
  const clean: Record<string, unknown> = {};
  for (const [key, val] of Object.entries(bundle)) {
    if (HASH_EXCLUDED.has(key)) continue;
    if (val !== undefined) clean[key] = val;
  }
  return hashPayload(clean);
}

// ─── Signatures ─────────────────────────────────────────

const SIGNING_KEY = "reyou-evidence-signing-key";

export function signPayload(data: string): string {
  return createHmac("sha256", SIGNING_KEY).update(data).digest("hex");
}

export function verifySignature(data: string, signature: string): boolean {
  const expected = signPayload(data);
  return expected === signature;
}

// ─── Store ──────────────────────────────────────────────

class InMemoryStore {
  private readonly bundles = new Map<string, EvidenceBundle>();
  private readonly bySource = new Map<string, Set<string>>();
  private readonly byCategory = new Map<string, Set<string>>();

  store(bundle: EvidenceBundle): void {
    this.bundles.set(bundle.bundleId, bundle);
    // Index by source
    if (!this.bySource.has(bundle.source)) this.bySource.set(bundle.source, new Set());
    this.bySource.get(bundle.source)!.add(bundle.bundleId);
    // Index by category
    if (!this.byCategory.has(bundle.category)) this.byCategory.set(bundle.category, new Set());
    this.byCategory.get(bundle.category)!.add(bundle.bundleId);
  }

  retrieve(id: string): EvidenceBundle | undefined {
    return this.bundles.get(id);
  }

  getAll(): EvidenceBundle[] {
    return Array.from(this.bundles.values());
  }

  getBySource(source: string): EvidenceBundle[] {
    const ids = this.bySource.get(source);
    if (!ids) return [];
    return Array.from(ids).map((id) => this.bundles.get(id)!).filter(Boolean);
  }

  getByCategory(category: EvidenceCategory): EvidenceBundle[] {
    const ids = this.byCategory.get(category);
    if (!ids) return [];
    return Array.from(ids).map((id) => this.bundles.get(id)!).filter(Boolean);
  }

  size(): number {
    return this.bundles.size;
  }

  clear(): void {
    this.bundles.clear();
    this.bySource.clear();
    this.byCategory.clear();
  }
}

// ─── EvidenceRuntime ────────────────────────────────────

export class EvidenceRuntime {
  private readonly store = new InMemoryStore();
  private readonly auditTrail: AuditEntry[] = [];
  private lastHash = "0".repeat(64);
  private chainDepth = 0;

  /** Produce a new immutable evidence bundle and store it. */
  record(params: {
    source: string;
    action: string;
    rationale: string;
    input: Record<string, unknown>;
    output: Record<string, unknown>;
    confidence: number;
    category?: EvidenceCategory;
    constitutionalArticles?: string[];
    architecturalLaws?: string[];
    trustScore?: number;
    metadata?: Record<string, unknown>;
    scientific?: ScientificMetadata;
    experiment?: ExperimentMetadata;
    certification?: CertificationMetadata;
    duration?: number;
    result?: "success" | "failure" | "partial" | "pending";
  }): EvidenceBundle {
    const timestamp = new Date();
    const bundleId = `${params.source}-${timestamp.getTime()}-${randomBytes(4).toString("hex")}`;
    const category = params.category ?? "custom";

    const bundle: EvidenceBundle = {
      id: bundleId,
      bundleId,
      createdAt: timestamp,
      updatedAt: timestamp,
      timestamp,
      source: params.source,
      action: params.action,
      rationale: params.rationale,
      input: params.input,
      output: params.output,
      confidence: params.confidence,
      category,
      constitutionalArticles: params.constitutionalArticles ?? [],
      architecturalLaws: params.architecturalLaws ?? [],
      trustScore: params.trustScore ?? 0,
      hash: "",
      previousHash: this.lastHash,
      chainDepth: this.chainDepth,
      signature: "",
      metadata: params.metadata ?? {},
      scientific: params.scientific,
      experiment: params.experiment,
      certification: params.certification,
      duration: params.duration,
      result: params.result,
    };

    // Compute hash
    bundle.hash = hashBundle(bundle);
    // Sign
    bundle.signature = signPayload(bundle.hash);

    // Update chain
    this.lastHash = bundle.hash;
    this.chainDepth++;

    // Store
    this.store.store(bundle);
    this.auditTrail.push({
      timestamp,
      action: "record",
      bundleId,
      details: `Recorded evidence from ${params.source}: ${params.action}`,
    });

    return bundle;
  }

  /** Retrieve a stored bundle by ID. */
  retrieve(bundleId: string): EvidenceBundle | undefined {
    const bundle = this.store.retrieve(bundleId);
    if (bundle) {
      this.auditTrail.push({
        timestamp: new Date(),
        action: "retrieve",
        bundleId,
        details: `Retrieved bundle ${bundleId}`,
      });
    }
    return bundle;
  }

  /** Get all bundles. */
  getAll(): EvidenceBundle[] {
    return this.store.getAll();
  }

  /** Get bundles by source. */
  getBySource(source: string): EvidenceBundle[] {
    return this.store.getBySource(source);
  }

  /** Get bundles by category. */
  getByCategory(category: EvidenceCategory): EvidenceBundle[] {
    return this.store.getByCategory(category);
  }

  /** Verify the integrity of a single bundle. */
  verifyBundle(bundle: EvidenceBundle): { valid: boolean; reason?: string } {
    const recomputed = hashBundle(bundle);
    if (recomputed !== bundle.hash) {
      return { valid: false, reason: "Hash mismatch — bundle may have been tampered with" };
    }
    if (!verifySignature(bundle.hash, bundle.signature)) {
      return { valid: false, reason: "Signature verification failed" };
    }
    return { valid: true };
  }

  /** Verify the integrity of the entire chain. */
  verifyChain(): ChainIntegrityResult {
    const bundles = this.store.getAll();
    if (bundles.length === 0) {
      return { valid: true, totalBundles: 0, brokenLinks: 0 };
    }

    // Sort by chainDepth
    const sorted = bundles.sort((a, b) => a.chainDepth - b.chainDepth);
    let brokenLinks = 0;
    let firstBrokenLink: string | undefined;

    for (let i = 0; i < sorted.length; i++) {
      const bundle = sorted[i]!;
      const bundleResult = this.verifyBundle(bundle);
      if (!bundleResult.valid) {
        brokenLinks++;
        if (!firstBrokenLink) firstBrokenLink = bundle.bundleId;
      }
      if (i > 0) {
        const prev = sorted[i - 1]!;
        if (bundle.previousHash !== prev.hash) {
          brokenLinks++;
          if (!firstBrokenLink) firstBrokenLink = bundle.bundleId;
        }
      }
    }

    return {
      valid: brokenLinks === 0,
      totalBundles: sorted.length,
      brokenLinks,
      firstBrokenLink,
    };
  }

  /** Replay a bundle — recompute hash and compare. */
  replay(bundleId: string): ReplayResult | undefined {
    const bundle = this.store.retrieve(bundleId);
    if (!bundle) return undefined;

    const replayHash = hashBundle(bundle);
    this.auditTrail.push({
      timestamp: new Date(),
      action: "replay",
      bundleId,
      details: `Replayed bundle ${bundleId}: match=${replayHash === bundle.hash}`,
    });

    return {
      bundle,
      replayedAt: new Date(),
      originalHash: bundle.hash,
      replayHash,
      match: replayHash === bundle.hash,
    };
  }

  /** Get the full audit trail. */
  getAuditTrail(): AuditEntry[] {
    return [...this.auditTrail];
  }

  /** Get chain depth. */
  getChainDepth(): number {
    return this.chainDepth;
  }

  /** Get the last hash in the chain. */
  getLastHash(): string {
    return this.lastHash;
  }

  /** Get total bundle count. */
  getCount(): number {
    return this.store.size();
  }

  /** Clear all evidence (for testing). */
  clear(): void {
    this.store.clear();
    this.auditTrail.length = 0;
    this.lastHash = "0".repeat(64);
    this.chainDepth = 0;
  }
}
