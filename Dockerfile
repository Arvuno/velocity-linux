FROM archlinux:latest

# Install dependencies
# Split pacman -Syu (system upgrade) and pacman -S (package install) into
# separate layers. Combining them in a single RUN risks a partial upgrade
# state if one of the steps fails or if the image is rebuilt on a stale cache.
RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm archiso git sudo
RUN pacman -Scc --noconfirm
# FORCE zstd compression globally
RUN sed -i 's/_squashfscomp=.*/_squashfscomp=("zstd" "-Xcompression-level" "3")/' /usr/share/archiso/configs/releng/profiledef.sh

WORKDIR /build
