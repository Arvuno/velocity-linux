#!/bin/bash

# Create liveuser with sudo permissions
useradd -m -G wheel -s /usr/bin/zsh liveuser
echo "liveuser:velocity" | chpasswd

# Set up sudo for wheel group (uncomment %wheel line in sudoers)
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Configure Plymouth
echo "Setting up Velocity Plymouth theme..."

# Create Plymouth config directory
mkdir -p /etc/plymouth

# Set Plymouth configuration
cat > /etc/plymouth/plymouthd.conf << 'EOF'
[Daemon]
Theme=arch-mac-style
ShowDelay=0
DeviceTimeout=8
EOF

# Enable Plymouth in mkinitcpio
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block plymouth filesystems fsck)/' /etc/mkinitcpio.conf

# Add basic graphics modules
echo "MODULES=(i915 amdgpu radeon nouveau)" >> /etc/mkinitcpio.conf

# Set Velocity as default theme
plymouth-set-default-theme -R arch-mac-style

# Rebuild initramfs
mkinitcpio -P

# Configure GRUB for quiet boot with Plymouth
if [ -f /etc/default/grub ]; then
    sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 udev.log_priority=3"/' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
fi


# Configure SDDM for autologin
mkdir -p /etc/sddm.conf.d/
cat > /etc/sddm.conf.d/autologin.conf << 'EOF'
[Autologin]
User=liveuser
Session=plasma.desktop
EOF

#Set file permissions
chmod 755 releng/airootfs/usr/share/backgrounds
chmod 755 releng/airootfs/usr/share/backgrounds/velocity
chmod 644 releng/airootfs/usr/share/backgrounds/velocity/default-wallpaper.jpg
chmod 755 releng/airootfs/etc/skel/.config/autostart
chmod 644 releng/airootfs/etc/skel/.config/autostart/set-wallpaper.desktop
chmod 755 releng/airootfs/usr/share/icons
chmod 777 releng/airootfs/usr/share/icons/velocity.png
chmod +x /usr/bin/oh-my-posh
chmod +x /usr/bin/yay

# Set up automatic login on TTY1 (fallback)
mkdir -p /etc/systemd/system/getty@tty1.service.d/
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << 'EOF'
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin liveuser --noclear %I $TERM
EOF

# Create desktop entry for liveuser
mkdir -p /etc/skel/Desktop
#cat > /etc/skel/Desktop/README.desktop << 'EOF'
#Version=1.0
#Type=Link
#Name=Velocity Linux Documentation
#URL=https://github.com/colmehurze-tech/velocity-linux
#Icon=system-help
#EOF

# Copy skel to liveuser home (if it exists)
if [ -d "/etc/skel" ]; then
    cp -r /etc/skel/. /home/liveuser/
    chown -R liveuser:liveuser /home/liveuser
fi

# Enable SDDM and Network Manager
systemctl enable sddm 
systemctl enable NetworkManager.service
