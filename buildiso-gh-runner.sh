# Getting tools to build the iso
pacman -Syu --noconfirm archiso squashfs-tools sed
            
# If zstd compression fails, uncomment the line below to use gzip instead
#sed -i 's/_squashfscomp=.*/_squashfscomp=(\"gzip\")/' /workspace/releng/profiledef.sh
            
# Build the ISO
cd /workspace 
mkarchiso -v /workspace/releng 