### Velocity: Fast and lightweight linux distro based on arch linux

![pic1](pic1.png)
![pic2](pic2.png)

Velocity is designed to be a fast, user friendly Linux distribution which aims to give productive users the latest software, minus all the bloat. 

DOWNLOAD VELOCITY NOW ✅:

1. [GITHUB RELEASES](https://github.com/colmehurze-tech/velocity-linux/releases) 

Features 🎉:

1. Hassle free coding with useful tools like VS code and lazyvim pre installed and pre configured. Just start the application and get going, no worries!
3. The latest and greatest zen browser is pre installed for swift, productive browsing. Based on your favourite browser firefox, this browser is has the best of all worlds!
4. Custom zsh shell and themes pre configured. Set those boring terminals aside and get a minimalistic and beautiful terminal, out of the box!
5. Tiling window manager included for maximum productivity and easy multitasking.

If you like my work, consider starring my repository. It keeps me motivated to continue building velocity ❤️

If you want to contribute to the building of velocity linux, you can email me at [this link](mailto:colmehurze@gmail.com). 

## Building from source

Velocity is built on top of [archiso](https://wiki.archlinux.org/title/Archiso), the official tool for creating Arch Linux live ISO images. The build pipeline relies on the `releng/` profile in this repository and the tooling installed by the project's CI scripts.

**Prerequisite:** Install `archiso` on your host (Arch-based system required):

```bash
sudo pacman -S --needed archiso
```

**Option 1 — Build with Docker (recommended, reproducible):**

```bash
docker build -t velocity-linux .
docker run --rm -v "$(pwd)/out":/build/out velocity-linux
```

**Option 2 — Build locally using the provided GitHub runner scripts:**

The repo ships two helper scripts that mirror the CI pipeline. Run them in order from the repository root:

```bash
sudo ./installdeps-gh-runner.sh   # installs pacman packages, builds AUR deps, and stages them into releng/airootfs/packages/
sudo ./buildiso-gh-runner.sh      # runs mkarchiso against releng/ to produce the final ISO
```

`buildiso-gh-runner.sh` invokes `mkarchiso -v /workspace/releng` and produces the live ISO you can flash with `dd`, `balenaEtcher`, or similar.
