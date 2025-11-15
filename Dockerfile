FROM archlinux:latest

# Install dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm archiso git sudo && \
    pacman -Scc --noconfirm

WORKDIR /build
