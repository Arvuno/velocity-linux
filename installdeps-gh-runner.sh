# Download AUR helper and apps
pacman -Syu --noconfirm base-devel git go gtk3 libxt mime-types dbus-glib nss ttf-liberation systemd ffmpeg qt6-declarative qt6-base jemalloc qt6-svg libpipewire qt6-shadertools wayland-protocols cli11 ninja cmake polkit
cd /tmp
git clone https://aur.archlinux.org/zen-browser-bin.git
git clone https://aur.archlinux.org/yay.git
git clone https://aur.archlinux.org/quickshell-git.git
git clone https://aur.archlinux.org/google-breakpad.git
git clone https://github.com/snowarch/iNiR.git

# Adding a non-root user for makepkg
useradd -m builder

# Building zen-browser
cd zen-browser-bin
chown -R builder:builder .
sudo -u builder makepkg --noconfirm --skippgpcheck --nodeps
find *.pkg.tar.zst
cp *.pkg.tar.zst /workspace/releng/airootfs/packages/

# Building yay
cd ..
cd yay
chown -R builder:builder .
sudo -u builder makepkg --noconfirm --skippgpcheck
find *.pkg.tar.zst
cp *.pkg.tar.zst /workspace/releng/airootfs/packages/
pacman -U --noconfirm *.pkg.tar.zst

# Building google-breakpad
cd ..
cd google-breakpad
chown -R builder:builder .
sudo -u builder makepkg --noconfirm --skippgpcheck
find *.pkg.tar.zst
cp *.pkg.tar.zst /workspace/releng/airootfs/packages/
pacman -U --noconfirm *.pkg.tar.zst

# Building quickshell
echo Building qs
cd ..
cd quickshell-git
chown -R builder:builder .
sudo -u builder makepkg --noconfirm --skippgpcheck
find *.pkg.tar.zst
cp *.pkg.tar.zst /workspace/releng/airootfs/packages/

# Building packages for iNiR
cd ..
cd iNiR/sdata/dist-arch/inir-core
chown -R builder:builder .
sudo -u builder makepkg --noconfirm --skippgpcheck
find *.pkg.tar.zst
cp *.pkg.tar.zst /workspace/releng/airootfs/packages/

# Setting up custom local repository
cd /workspace/releng/airootfs/packages
repo-add -s -v packages.db.tar.gz *.pkg.tar.zst
ln -sf packages.db.tar.gz packages.db
ln -sf packages.files.tar.gz packages.files
ls -la packages.*