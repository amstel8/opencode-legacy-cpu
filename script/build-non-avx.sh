#!/bin/sh
set -eu

# Compile with the supplied runtime: a target named "baseline" alone is insufficient.
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
: "${BUN_BIN:?Set BUN_BIN to an absolute path to a tested Penryn-compatible Bun}"
case "$BUN_BIN" in
  /*) ;;
  *) echo "BUN_BIN must be an absolute path" >&2; exit 1 ;;
esac
expected=${BUN_SHA256:-b88430d95e893b42b46a00f1087ed9886947dcb00febf4236d62212969d65ab3}
actual=$(shasum -a 256 "$BUN_BIN" | awk '{print $1}')
if [ "$actual" != "$expected" ]; then
  echo "Bun checksum mismatch; see NON_AVX.md before selecting another runtime" >&2
  exit 1
fi
if [ "$(uname -s)" != Darwin ] || [ "$(uname -m)" != x86_64 ]; then
  echo "This recipe builds on Intel macOS" >&2
  exit 1
fi
if [ -n "${BUN_COMPILE_RELEASE:-}" ]; then
  echo "Unset BUN_COMPILE_RELEASE: it replaces the patched runtime with a download" >&2
  exit 1
fi
if [ ! -d "$root/packages/cli/node_modules/@opentui/core" ]; then
  echo "Install dependencies first; see NON_AVX.md" >&2
  exit 1
fi

scratch=$(mktemp -d "${TMPDIR:-/tmp}/opencode-build.XXXXXX")
trap 'rm -rf "$scratch"' EXIT HUP INT TERM
mkdir -p "$scratch/bin" "$scratch/home" "$scratch/data" "$scratch/cache" "$scratch/config"
ln -s "$BUN_BIN" "$scratch/bin/bun"
version=$("$BUN_BIN" -e 'console.log(JSON.parse(require("fs").readFileSync(process.argv[1], "utf8")).version)' "$root/package.json")
export PATH="$scratch/bin:$PATH"
export HOME="$scratch/home" XDG_DATA_HOME="$scratch/data"
export XDG_CACHE_HOME="$scratch/cache" XDG_CONFIG_HOME="$scratch/config"
export OPENCODE_VERSION="$version" OPENCODE_DISABLE_AUTOUPDATE=true BUN_JSC_useJIT=0
cd "$root/packages/cli"
"$BUN_BIN" run script/build.ts --single --skip-install --skip-web-ui --outdir=dist-non-avx
artifact="$root/packages/cli/dist-non-avx/cli-darwin-x64/bin/opencode"
codesign --force --sign - "$artifact"
codesign --verify --strict "$artifact"
"$artifact" --version
shasum -a 256 "$artifact"
