# Dockerfile for Cadnano2 with GUI support
FROM ubuntu:18.04

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python \
    python-dev \
    python-pip \
    python-setuptools \
    python-wheel \
    python-numpy \
    python-scipy \
    x11-apps \
    x11-utils \
    x11-xserver-utils \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxtst6 \
    libxi6 \
    libxrandr2 \
    libxinerama1 \
    libxcursor1 \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libgtk-3-0 \
    libdbus-1-3 \
    python-qt4 \
    libqt4-opengl-dev \
    wget \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash cadnano && \
    usermod -aG audio,video cadnano

# Set working directory
WORKDIR /home/cadnano

# Download and install Cadnano2 v2.2.0
RUN wget -O cadnano2.tar.gz https://github.com/cadnano/cadnano2/archive/refs/tags/v2.2.0.tar.gz && \
    tar -xzf cadnano2.tar.gz && \
    mv cadnano2-2.2.0 cadnano2 && \
    rm cadnano2.tar.gz

# Install Cadnano2
RUN cd cadnano2 && \
    chmod +x main.py

# Create desktop entry for Cadnano2
RUN mkdir -p /home/cadnano/.local/share/applications && \
    echo '[Desktop Entry]\n\
Version=1.0\n\
Type=Application\n\
Name=Cadnano2\n\
Comment=DNA origami design software\n\
Exec=python /home/cadnano/cadnano2/cadnano2/main.py\n\
Icon=applications-engineering\n\
Terminal=false\n\
Categories=Science;Engineering;' > /home/cadnano/.local/share/applications/cadnano2.desktop

# Set ownership of cadnano home directory
RUN chown -R cadnano:cadnano /home/cadnano

# Switch to non-root user
USER cadnano

# Set environment variables for GUI
ENV DISPLAY=:0
ENV QT_X11_NO_MITSHM=1
ENV QT_QPA_PLATFORM=xcb

# Create a startup script
RUN echo '#!/bin/bash\n\
export DISPLAY=$DISPLAY\n\
export QT_X11_NO_MITSHM=1\n\
export QT_QPA_PLATFORM=xcb\n\
cd /home/cadnano/cadnano2\n\
python main.py "$@"' > /home/cadnano/start_cadnano.sh && \
    chmod +x /home/cadnano/start_cadnano.sh

# Set the default command
CMD ["/home/cadnano/start_cadnano.sh"]