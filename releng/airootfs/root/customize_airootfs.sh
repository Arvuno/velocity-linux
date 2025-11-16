#!/bin/bash

# Create liveuser with sudo permissions
useradd -m -G wheel -s /bin/bash liveuser
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
Theme=velocity
ShowDelay=0
DeviceTimeout=8
EOF

# Enable Plymouth in mkinitcpio
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block plymouth filesystems fsck)/' /etc/mkinitcpio.conf

# Add basic graphics modules
echo "MODULES=(i915 amdgpu radeon nouveau)" >> /etc/mkinitcpio.conf

# Set Velocity as default theme
plymouth-set-default-theme -R velocity

# Rebuild initramfs
mkinitcpio -P

# Configure GRUB for quiet boot with Plymouth
if [ -f /etc/default/grub ]; then
    sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 udev.log_priority=3"/' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
fi

# Set default wallpaper for XFCE4
echo "Setting up Velocity wallpaper..."

# Create XFCE4 desktop configuration
mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/

cat > /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="image-path" type="string" value="/usr/share/backgrounds/velocity/default-wallpaper.jpg"/>
        <property name="image-style" type="int" value="5"/>
        <property name="last-image" type="string" value="/usr/share/backgrounds/velocity/default-wallpaper.jpg"/>
        <property name="last-single-image" type="string" value="/usr/share/backgrounds/velocity/default-wallpaper.jpg"/>
      </property>
    </property>
  </property>
</channel>
EOF

# Also set for the liveuser directly (in case skel doesn't work)
mkdir -p /home/liveuser/.config/xfce4/xfconf/xfce-perchannel-xml/
cp /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml /home/liveuser/.config/xfce4/xfconf/xfce-perchannel-xml/

# Set ownership
chown -R liveuser:liveuser /home/liveuser/.config

echo "✅ Wallpaper configured for Velocity Linux"

# Setup Sweet Theme (pre-downloaded)
setup_sweet_theme() {
    echo "Setting up Sweet theme..."
    
    # Ensure themes are properly installed
    if [ -d "/usr/share/themes/Sweet" ]; then
        echo "✅ Sweet theme found"
    else
        echo "❌ Sweet theme not found"
        return 1
    fi
    
    # Create XFCE4 configuration
    mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/
    
    # xsettings.xml
    cat > /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Sweet"/>
    <property name="IconThemeName" type="string" value="Papirus-Dark"/>
    <property name="CursorThemeName" type="string" value="Adwaita"/>
  </property>
  <property name="Xft" type="empty">
    <property name="DPI" type="int" value="96"/>
    <property name="Antialias" type="int" value="1"/>
    <property name="Hinting" type="int" value="1"/>
    <property name="HintStyle" type="string" value="hintfull"/>
    <property name="RGBA" type="string" value="rgb"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="FontName" type="string" value="Noto Sans, 10"/>
  </property>
</channel>
EOF

    # xfwm4.xml - Window manager
    cat > /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="Sweet"/>
    <property name="title_font" type="string" value="Noto Sans Bold, 10"/>
  </property>
</channel>
EOF

    # Copy to liveuser
    mkdir -p /home/liveuser/.config/xfce4/xfconf/xfce-perchannel-xml/
    cp /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml /home/liveuser/.config/xfce4/xfconf/xfce-perchannel-xml/
    chown -R liveuser:liveuser /home/liveuser/.config
    
    echo "✅ Sweet theme configured for XFCE4"
}

setup_sweet_theme

# Configure SDDM for autologin
mkdir -p /etc/sddm.conf.d/
cat > /etc/sddm.conf.d/autologin.conf << 'EOF'
[Autologin]
User=liveuser
Session=xfce
EOF

# Set up automatic login on TTY1 (fallback)
mkdir -p /etc/systemd/system/getty@tty1.service.d/
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << 'EOF'
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin liveuser --noclear %I $TERM
EOF

# Create desktop entry for liveuser
mkdir -p /etc/skel/Desktop
cat > /etc/skel/Desktop/README.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Link
Name=Velocity Linux Documentation
URL=https://github.com/colmehurze-tech/velocity-linux
Icon=system-help
EOF

# Copy skel to liveuser home (if it exists)
if [ -d "/etc/skel" ]; then
    cp -r /etc/skel/. /home/liveuser/
    chown -R liveuser:liveuser /home/liveuser
fi

# Enable SDDM
systemctl enable sddm 
