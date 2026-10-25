# OpenCode Legacy CPU

OpenCode for older Intel Macs, including Core 2 Duo systems without AVX.
This independently maintained fork starts from upstream **OpenCode 2.1.4**.

- **Current build:** macOS 12 Monterey, Intel x86_64, Penryn-compatible runtime.
- **Tested CPUs:** Core 2 Duo T9900 and Xeon X5690. Other Core 2 Duo models have
  not all been tested; this is not a universal compatibility claim.
- **Download:** [releases](https://github.com/amstel8/opencode-legacy-cpu/releases/latest).
- **Build details and compatibility patches:** [NON_AVX.md](NON_AVX.md).

## Install the release

Download `opencode-2.1.4-darwin-x64-penryn.tar.gz` and `SHA256SUMS` from the release.
From the download directory:

```sh
shasum -a 256 -c SHA256SUMS
tar -xzf opencode-2.1.4-darwin-x64-penryn.tar.gz
cd opencode-2.1.4-darwin-x64-penryn
shasum -a 256 -c SHA256SUMS
mkdir -p "$HOME/.local/bin"
if [ -f "$HOME/.local/bin/opencode" ]; then
  cp -p "$HOME/.local/bin/opencode" "$HOME/.local/bin/opencode.rollback"
fi
install -m 755 opencode "$HOME/.local/bin/opencode.new"
mv "$HOME/.local/bin/opencode.new" "$HOME/.local/bin/opencode"
export OPENCODE_DISABLE_AUTOUPDATE=true
"$HOME/.local/bin/opencode" --version
```

Add `$HOME/.local/bin` to `PATH` and persist `OPENCODE_DISABLE_AUTOUPDATE=true`
in your shell or application's launch environment. An official update can
replace the compatible runtime. Restart clients after replacing the binary.
The executable is signed ad hoc, without Apple Developer ID notarization.
The embedded web UI is omitted; the terminal UI and API are included.

For T3 Code, use [T3 Code Legacy 0.1.1-2 or newer](https://github.com/amstel8/t3code-legacy/releases)
and refresh the OpenCode provider catalog. That fork clears stale model variants
when OpenCode reports that a model has no options.

The build recipe requires an external, patched Bun runtime. Its checksum and
known source-provenance limitation are documented in [NON_AVX.md](NON_AVX.md).

Upstream project: [anomalyco/opencode](https://github.com/anomalyco/opencode).
The upstream documentation follows.

---

<p align="center">
  <a href="https://opencode.ai">
    <picture>
      <source srcset="packages/console/app/src/asset/logo-ornate-dark.svg" media="(prefers-color-scheme: dark)">
      <source srcset="packages/console/app/src/asset/logo-ornate-light.svg" media="(prefers-color-scheme: light)">
      <img src="packages/console/app/src/asset/logo-ornate-light.svg" alt="OpenCode logo">
    </picture>
  </a>
</p>
<p align="center">The open source AI coding agent.</p>
<p align="center">
  <a href="https://opencode.ai/discord"><img alt="Discord" src="https://img.shields.io/discord/1391832426048651334?style=flat-square&label=discord" /></a>
  <a href="https://www.npmjs.com/package/@opencode/cli"><img alt="npm" src="https://img.shields.io/npm/v/@opencode/cli?style=flat-square" /></a>
  <a href="https://github.com/anomalyco/opencode/actions/workflows/publish.yml"><img alt="Build status" src="https://img.shields.io/github/actions/workflow/status/anomalyco/opencode/publish.yml?style=flat-square&branch=dev" /></a>
</p>

<p align="center">
  <a href="README.md">English</a> |
  <a href="README.zh.md">简体中文</a> |
  <a href="README.zht.md">繁體中文</a> |
  <a href="README.ko.md">한국어</a> |
  <a href="README.de.md">Deutsch</a> |
  <a href="README.es.md">Español</a> |
  <a href="README.fr.md">Français</a> |
  <a href="README.it.md">Italiano</a> |
  <a href="README.da.md">Dansk</a> |
  <a href="README.ja.md">日本語</a> |
  <a href="README.pl.md">Polski</a> |
  <a href="README.ru.md">Русский</a> |
  <a href="README.bs.md">Bosanski</a> |
  <a href="README.ar.md">العربية</a> |
  <a href="README.no.md">Norsk</a> |
  <a href="README.br.md">Português (Brasil)</a> |
  <a href="README.th.md">ไทย</a> |
  <a href="README.tr.md">Türkçe</a> |
  <a href="README.uk.md">Українська</a> |
  <a href="README.bn.md">বাংলা</a> |
  <a href="README.gr.md">Ελληνικά</a> |
  <a href="README.vi.md">Tiếng Việt</a>
</p>

[![OpenCode Terminal UI](packages/web/src/assets/lander/screenshot.png)](https://opencode.ai)

---

### Installation

```bash
# YOLO
curl -fsSL https://opencode.ai/v2/install | bash

# Package managers
npm i -g @opencode/cli@latest      # or bun/pnpm/yarn
brew install anomalyco/tap/opencode-v2 # macOS and Linux (recommended, always up to date)
brew install opencode              # macOS and Linux (official brew formula, updated less)
sudo pacman -S opencode            # Arch Linux (Stable)
paru -S opencode-beta              # Arch Linux (Latest from AUR)
mise use -g opencode               # Any OS
nix run github:anomalyco/opencode  # Nix
```

> [!TIP]
> Remove versions older than 0.1.x before installing.

### Desktop App (BETA)

OpenCode is also available as a desktop application. Download it from [opencode.ai/download](https://opencode.ai/download).

| Platform              | Download                           |
| --------------------- | ---------------------------------- |
| macOS (Apple Silicon) | `opencode-desktop-mac-arm64.dmg`   |
| macOS (Intel)         | `opencode-desktop-mac-x64.dmg`     |
| Windows               | `opencode-desktop-win-x64.exe`     |
| Linux                 | `.deb`, `.rpm`, or `.AppImage`     |

```bash
# macOS (Homebrew)
brew install --cask opencode-desktop
```

#### Installation Directory

The install script installs OpenCode to `$HOME/.opencode/bin`.

### Agents

OpenCode includes two built-in agents you can switch between with the `Tab` key.

- **build** - Default, full-access agent for development work
- **plan** - Read-only agent for analysis and code exploration
  - Denies file edits by default
  - Asks permission before running bash commands
  - Ideal for exploring unfamiliar codebases or planning changes

Also included is a **general** subagent for complex searches and multistep tasks.
This is used internally and can be invoked using `@general` in messages.

Learn more about [agents](https://opencode.ai/v2/docs/agents).

### Documentation

For more info on how to configure OpenCode, [**head over to our docs**](https://opencode.ai/v2/docs).

### Contributing

If you're interested in contributing to OpenCode, please read our [contributing docs](./CONTRIBUTING.md) before submitting a pull request.

### Building on OpenCode

If you are working on a project that's related to OpenCode and is using "opencode" as part of its name, for example "opencode-dashboard" or "opencode-mobile", please add a note to your README to clarify that it is not built by the OpenCode team and is not affiliated with us in any way.

---

**Join our community** [Discord](https://discord.gg/opencode) | [X.com](https://x.com/opencode)
