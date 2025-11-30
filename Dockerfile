FROM archlinux:latest

# Install dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm archiso git sudo && \
    pacman -Scc --noconfirm
# FORCE zstd compression globally
RUN sed -i 's/_squashfscomp=.*/_squashfscomp=("zstd" "-Xcompression-level" "3")/' /usr/share/archiso/configs/releng/profiledef.sh

WORKDIR /build
