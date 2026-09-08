# LumaMobile

**LumaMobile** is an open-source mobile operating system built directly on the Linux kernel.

It is **not based on Android**. LumaMobile is building its own mobile shell, platform framework, services layer, SDK, package format, applications, and development VM while using proven open-source components underneath.

> **Status:** Early development / experimental. LumaMobile is not ready for everyday use yet.

> **Build State:** ```nightly-beta``` is the current build of LumaMobile.

## Quick start

The easiest way to try the current LumaMobile UI is the Linux host preview.

### Supported setup hosts

The automated setup currently supports Debian-family distributions such as:

- Linux Mint
- Ubuntu
- Debian

Clone the project:

```bash
git clone https://github.com/mindyannakawee2-tech/LumaMobile.git
cd LumaMobile
```

Run the setup:

```bash
bash setup.sh
```

The setup script installs the required development packages and builds:

- LumaShell
- Luma Framework host tools
- LMS host tools
- the C++ Luma SDK static library
- dependencies needed by LumaVM

Then launch the host preview:

```bash
./run-preview.sh
```

If the executable bit was not preserved by your download method, use:

```bash
bash run-preview.sh
```

### Full LumaVM boot

LumaVM is included in `tools/lumavm/`, but a complete VM boot currently also requires generated artifacts that are intentionally not committed to Git:

```text
kernel/linux-6.18.49/arch/x86/boot/bzImage
output/lumamobile-initramfs.cpio.gz
output/lumadata.img
```

So for new users, the **host preview is currently the recommended way to try LumaMobile**. A reproducible full-OS build script is planned.

## Vision

LumaMobile aims to provide a complete Linux-native mobile platform with a consistent application model and a UI designed for phones from the start.

```text
Luma Apps
  ├── QML UI
  └── C++ logic
       ↓
Luma SDK
       ↓
┌────────────────┬────────────────┐
│ Luma Framework │ LMS            │
│ OS/platform API│ ecosystem      │
└────────────────┴────────────────┘
       ↓
Linux
```

## Main components

- **LumaShell** — the mobile shell and built-in user interface.
- **Luma Framework** — native platform APIs and system services exposed through `lumad`.
- **LMS (LumaMobile Services)** — higher-level ecosystem services such as app, permission, and notification services.
- **Luma SDK** — APIs for native LumaMobile applications.
- **LPK** — LumaMobile's native package format and tooling.
- **LumaVM** — the x86_64 development VM/frontend used to run and test LumaMobile during development.
- **Luma Apps** — built-in applications written with Qt Quick/QML and native logic.

## Technology

LumaMobile currently uses:

- Linux kernel
- C and C++
- Qt 6 / Qt Quick / QML
- Unix domain sockets for core service IPC
- BusyBox and other upstream open-source components where appropriate

Rust may be used for additional system components in the future.

## Repository layout

```text
LumaMobile/
├── apps/          # Luma applications and examples
├── framework/     # Luma Framework / lumad
├── kernel/        # LumaMobile kernel configs and related files
├── packages/      # Package-related source and metadata
├── scripts/       # Build and development scripts
├── sdk/           # Luma SDK
├── services/      # System and ecosystem services (including LMS)
├── shell/         # LumaShell
├── setup.sh       # One-command Debian/Ubuntu/Mint setup
├── run-preview.sh # Launch the host LumaShell preview
└── tools/
    ├── lpk/       # LPK tooling
    └── lumavm/    # LumaVM
```

Generated root filesystems, disk images, build output, downloaded upstream sources, and caches are intentionally not stored in Git.

## Current progress

- [x] Linux boot prototype
- [x] LumaShell prototype
- [x] LumaVM development frontend
- [x] Luma Framework prototype
- [x] LMS prototype
- [x] C++ SDK prototype
- [x] LPK prototype
- [x] Host setup + preview workflow
- [ ] Reproducible full OS build from a fresh clone
- [X] Complete application navigation model
- [X] Luma on-screen keyboard
- [ ] Persistent user storage workflow
- [X] Functional browser and file workflows
- [ ] Notifications UI
- [ ] App recents / task management
- [ ] Application sandboxing
- [ ] Accelerated graphics path
- [ ] Stable public application API

## Application model

The intended native LumaMobile application stack is:

```text
QML / Qt Quick UI
       +
C++ application logic
       +
Luma SDK
       ↓
     .lpk
```

The long-term goal is for application developers to use the Luma SDK without needing to depend on LumaShell internals or direct system implementation details.

## Development

LumaMobile currently targets an x86_64 VM for primary development and testing.

The project is still changing quickly, so build instructions and APIs may change between commits.

## Contributing

LumaMobile is open source and contributions are welcome.

Because the project is still in an early architectural stage, please open an issue before beginning a large change so that duplicate or conflicting work can be avoided.

Useful contribution areas include:

- Qt/QML UI and mobile UX
- C/C++ system services
- Linux integration
- application framework and SDK design
- packaging and application lifecycle
- networking, audio, display, and input
- documentation and testing

A dedicated `CONTRIBUTING.md` will be added as the contribution workflow matures.

## Licensing

LumaMobile's original source code in this repository is licensed under the **Apache License 2.0** unless a file states otherwise. See [`LICENSE`](LICENSE).

Third-party and upstream components retain their own licenses. In particular, Linux kernel code and modifications are subject to the Linux kernel's applicable GPL-2.0 licensing terms.

## Project identity

The source code is open source, but the LumaMobile project name, logos, and other project branding may be governed separately from the source-code license.

---

**LumaMobile — a Linux-native mobile OS in development.**

