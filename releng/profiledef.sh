#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="velocity-linux"
iso_label="VELOCITY_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Velocity Linux"
iso_application="Velocity Linux Live/Rescue CD"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="velocity"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
           'uefi-ia32.systemd-boot.esp' 'uefi-x64.systemd-boot.esp'
           'uefi-ia32.systemd-boot.eltorito' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
# Set the compression type
#_squashfscomp=('gzip')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'gzip' '-b' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
)


make_customize_airootfs() {
    echo "==================================="
    echo "Starting customization"
    echo "==================================="
    
    # Check available space
    echo "Disk space:"
    df -h
    
    # Check if packages directory exists
    echo "Checking /packages directory:"
    ls -lh /packages/ 2>&1 || echo "ERROR: /packages not found"
    
    # Count package files
    echo "Package files found:"
    ls /packages/*.pkg.tar.zst 2>&1 || echo "No .pkg.tar.zst files found"
    
    # Try to install with verbose output
    echo "Attempting to install packages:"
    if ls /packages/*.pkg.tar.zst 1> /dev/null 2>&1; then
        pacman -U --noconfirm /packages/*.pkg.tar.zst
        INSTALL_RESULT=$?
        echo "Installation exit code: $INSTALL_RESULT"
    else
        echo "ERROR: No package files to install"
    fi
    
    # Verify installation
    echo "Verifying zen-browser installation:"
    pacman -Q zen-browser-bin 2>&1 || echo "zen-browser-bin NOT installed"
    
    # Set zsh as default shell
    echo "Setting zsh as default shell:"
    sed -i 's|SHELL=/bin/bash|SHELL=/usr/bin/zsh|' /etc/default/useradd
    
    echo "==================================="
    echo "Customization complete"
    echo "==================================="
} 
