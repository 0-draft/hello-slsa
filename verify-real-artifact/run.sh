#!/usr/bin/env bash
# Verify a real-world public artifact that ships SLSA L3 provenance.
set -euo pipefail

VERSION="v2.7.1"
ARTIFACT="slsa-verifier-darwin-arm64"
PROV="${ARTIFACT}.intoto.jsonl"
BASE="https://github.com/slsa-framework/slsa-verifier/releases/download/${VERSION}"

# 1. Download the artifact and its provenance (cached if already present).
[ -f "${ARTIFACT}" ] || curl -sLO "${BASE}/${ARTIFACT}"
[ -f "${PROV}" ] || curl -sLO "${BASE}/${PROV}"

# 2. Run SLSA verification, pinning the expected source repo and tag.
slsa-verifier verify-artifact "${ARTIFACT}" \
  --provenance-path "${PROV}" \
  --source-uri "github.com/slsa-framework/slsa-verifier" \
  --source-tag "${VERSION}"

# 3. Inspect the provenance payload to see what was actually attested.
echo "---- Provenance Subject ----"
jq -r '.payload' "${PROV}" | base64 -d | jq '.subject'

echo "---- Provenance Builder & buildType ----"
jq -r '.payload' "${PROV}" | base64 -d | jq '{builder: .predicate.builder, buildType: .predicate.buildType}'

echo "---- Source Repository (configSource) ----"
jq -r '.payload' "${PROV}" | base64 -d | jq '.predicate.invocation.configSource'
