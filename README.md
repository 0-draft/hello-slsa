# hello-slsa

A minimal, end-to-end demo of **SLSA Build Level 3 provenance**: generate it for your own Go binary with `slsa-github-generator`, and verify a real-world release with `slsa-verifier`.

Companion repo for the *Supply Chain Security* series on [dev.to/kanywst](https://dev.to/kanywst).

## What you get

- A 12-line Go program (`hello-slsa`) that ships SLSA L3 provenance on every `v*` tag.
- A reproducible script that downloads `slsa-verifier`'s own release and verifies its provenance offline.
- The generated `.intoto.jsonl` files, ready to inspect with `jq`.

## Quick start: verify a real artifact

Requires [`slsa-verifier`](https://github.com/slsa-framework/slsa-verifier) and `jq` on `PATH`.

```bash
cd verify-real-artifact
./run.sh
```

Expected tail:

```text
PASSED: SLSA verification passed
```

The script also prints the provenance `subject`, `builder`, and `configSource` so you can see exactly what is being attested.

## Build your own SLSA L3 binary

Try it locally first:

```bash
go build -trimpath -ldflags "-s -w" -o hello-slsa .
./hello-slsa
# hello-slsa 0.1.0 (darwin/arm64)
```

Then fork this repo (or copy the four files at the root plus `.github/`), update `go.mod` to your module path, and tag:

```bash
git tag v0.1.0
git push origin v0.1.0
```

The reusable workflow `slsa-framework/slsa-github-generator/.github/workflows/builder_go_slsa3.yml@v2.0.0` builds the binary inside an isolated runner, signs the provenance with a Sigstore-issued Fulcio cert, and uploads both to the GitHub Release.

## Verify your own release

```bash
slsa-verifier verify-artifact hello-slsa-linux-amd64 \
  --provenance-path hello-slsa-linux-amd64.intoto.jsonl \
  --source-uri github.com/0-draft/hello-slsa \
  --source-tag v0.1.0
```

## Why SLSA L3?

Signing proves *who*. SBOM proves *what*. Provenance proves *how*: the source commit, the builder, the build steps. L3 adds an isolated, non-tamperable builder, which is what closes the SUNSPOT-style attack on the build server itself.

## References

- [SLSA v1.0 spec](https://slsa.dev/spec/v1.0/)
- [`slsa-github-generator`](https://github.com/slsa-framework/slsa-github-generator)
- [`slsa-verifier`](https://github.com/slsa-framework/slsa-verifier)
- [in-toto Attestation Framework](https://github.com/in-toto/attestation)

## License

MIT
