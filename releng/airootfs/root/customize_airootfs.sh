#!/bin/bash

# Create liveuser with sudo permissions
useradd -m -G wheel -s /bin/bash liveuser
echo "liveuser:velocity" | chpasswd

# Set up sudo for wheel group (uncomment %wheel line in sudoers)
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

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
URL=https://github.com/yourusername/velocity
Icon=system-help
EOF

# Copy skel to liveuser home (if it exists)
if [ -d "/etc/skel" ]; then
    cp -r /etc/skel/. /home/liveuser/
    chown -R liveuser:liveuser /home/liveuser
fi

# Enable SDDM
systemctl enable sddm 
