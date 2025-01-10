# Base Image
FROM ubuntu:23.10 as base

# Update and install essential tools
RUN apt update && apt install -y \
    ca-certificates sudo ssh netplan.io udev parted net-tools kmod bridge-utils \
    && apt clean

# NVIDIA Jetson-specific packages
RUN apt install -y -o Dpkg::Options::="--force-overwrite" \
    nvidia-l4t-core \
    nvidia-l4t-init \
    nvidia-l4t-bootloader \
    nvidia-l4t-initrd \
    nvidia-l4t-xusb-firmware \
    nvidia-l4t-kernel \
    nvidia-l4t-kernel-dtbs \
    nvidia-l4t-kernel-headers \
    nvidia-l4t-cuda \
    jetson-gpio-common \
    python3-jetson-gpio \
    && rm -rf /opt/nvidia/l4t-packages

# Install XFCE Desktop Environment
RUN apt update && apt install -y \
    xfce4 xfce4-goodies \
    xserver-xorg x11-utils dbus-x11 \
    && apt clean

# Set XFCE as the default desktop
RUN echo "xfce4-session" > /root/.xsession

# Enable required systemd services
COPY root/etc/systemd/ /etc/systemd
RUN systemctl enable resizerootfs
RUN systemctl enable ssh
RUN systemctl enable systemd-networkd
RUN systemctl enable setup-resolve

# Add Jetson user with sudo privileges
RUN useradd -ms /bin/bash jetson
RUN echo 'jetson:jetson' | chpasswd
RUN usermod -a -G sudo jetson

# Setup graphical login manager (optional)
RUN apt install -y lightdm && systemctl enable lightdm

# Copy additional configuration files
COPY root/etc/apt/ /etc/apt
COPY root/usr/share/keyrings /usr/share/keyrings
RUN apt update && apt clean

# Default entry point
CMD ["/usr/sbin/init"]
