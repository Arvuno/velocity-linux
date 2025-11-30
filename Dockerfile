FROM archlinux:latest

# Install dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm archiso git sudo && \
    pacman -Scc --noconfirm
# FORCE zstd compression globally
RUN echo "_squashfscomp=('zstd')" > /etc/archiso/force-compression.conf
RUN sed -i "s/_squashfscomp=.*/_squashfscomp=('zstd')/" /usr/share/archiso/configs/releng/profiledef.sh
RUN sed -i "s/_squashfscomp=.*/_squashfscomp=('zstd')/" /usr/share/archiso/configs/baseline/profiledef.sh

WORKDIR /build
