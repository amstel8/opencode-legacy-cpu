# OpenCode 2.1.2 for older Intel Macs

This fork starts at upstream tag `v2.1.2` (`a517687fde`). It keeps the upstream
application and adds a build recipe for Intel Macs without AVX, including the
Xeon X5690 and Core 2 Duo T9900 running macOS 12.

The runtime matters more than the target name. A binary built with a runtime
that works on Westmere can still hang on Penryn, even on `--version`.
The recipe uses the separately built Penryn-compatible Bun `1.4.4-canary.1+6c1eb067e` runtime with
SHA-256:

```text
b88430d95e893b42b46a00f1087ed9886947dcb00febf4236d62212969d65ab3
```

That runtime is an external build prerequisite, not included in this source
repository. The original local Bun/JSC build tree is no longer available, so
this repository does not yet contain the patches needed to reproduce that
runtime. The checksum identifies the runtime used for the published executable;
stock Bun and the earlier Nehalem build are not substitutes for the T9900.
The runtime source and its build instructions need to be recovered before
publishing a separately reproducible runtime release. Upstream runtime notices
are preserved in [licenses/Bun-LICENSE.md](licenses/Bun-LICENSE.md), from
[Bun revision 6c1eb067e](https://github.com/oven-sh/bun/blob/6c1eb067e/LICENSE.md).

## Build

Supply the absolute path to the runtime, then install the pinned dependencies:

```sh
export BUN_BIN=/absolute/path/to/penryn-compatible/bun
BUN_JSC_useJIT=0 "$BUN_BIN" install --frozen-lockfile --ignore-scripts
sh script/build-non-avx.sh
```

The script verifies the runtime checksum, embeds the source package version,
uses isolated build configuration and data, and signs the executable ad hoc.
It does not install the executable. It skips the embedded web UI.
If selecting another runtime, set `BUN_SHA256` to its independently verified
checksum and repeat all hardware checks below. Do not set `BUN_COMPILE_RELEASE`:
that option downloads a different runtime.

Output:

```text
packages/cli/dist-non-avx/cli-darwin-x64/bin/opencode
```

## Verify and install

Run `--version`, `--help`, the TUI, and an authenticated API model-list request
on the actual target Mac before installation. A successful build or code
signature does not establish CPU compatibility. The build wrapper verifies only
version and signature on the build host.

Keep a rollback binary, then install atomically:

```sh
cp "$HOME/.local/bin/opencode" "$HOME/.local/bin/opencode.rollback"
install -m 755 packages/cli/dist-non-avx/cli-darwin-x64/bin/opencode \
  "$HOME/.local/bin/opencode.new"
mv "$HOME/.local/bin/opencode.new" "$HOME/.local/bin/opencode"
export OPENCODE_DISABLE_AUTOUPDATE=true
```

Persist `OPENCODE_DISABLE_AUTOUPDATE=true` in the shell or application launch
environment. An official update can replace this runtime. Restart clients and
managed servers after installation; already running processes retain their old
executable. Do not run v1 against a data directory migrated by v2.

## Compatibility changes

- Select only the baseline target when `--single --baseline` is requested.
- Allow Bun resolution errors that are not `Error` instances to reach the
  directory-plugin `index` fallback.
- Serve authenticated `GET /api/status` as an alias of `/api/info` for older
  clients, preserving authentication.
- Allow up to 30 seconds for location plugins to activate. On the T9900, a cold
  start with the user's custom provider took about 16 seconds. The upstream
  five-second wait returned HTTP 503 before the catalog was ready, and T3 did
  not retry that response.

## T3 Code

Use [T3 Code Legacy 0.1.1-2 or newer](https://github.com/amstel8/t3code-legacy/releases)
for the corrected catalog merge behavior. After upgrading OpenCode, refresh its
provider status and model catalog in T3.
A catalog cached before the upgrade may offer reasoning variants the new
model does not support. For example, Big Pickle has no variants, so sending
`variant=medium` produces `Variant unavailable for opencode/big-pickle: medium`.
Clear a previously saved variant in an affected conversation as well.
Do not add fake variants to OpenCode to accommodate stale client state.

The extended activation wait also lets T3 fetch a cold catalog in one request.
It remains bounded: a plugin that never finishes still returns HTTP 503.

Local passwords, endpoints, machine notes, runtime binaries, and build outputs
are not part of this fork's source changes. No release is published by the build
script.
