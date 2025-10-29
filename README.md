# Cadnano2 Docker with GUI Support

This project provides a Docker container setup for running Cadnano2 v2.2.0 with GUI support on both macOS and Linux systems. The Docker image is now available on Docker Hub as `subhajitroy/cadnano`.

## Known Problems

The cadnano gui might face issues with saving the files inside the data folder. Change the folder to `chmod 777 folderName` to allow edit by any user. The cadnano is inside docker with different permission set.

## Overview

Cadnano2 is a software tool for designing DNA origami structures. This Docker setup includes:
- Ubuntu 18.04 base with Python 2.7
- PyQt4, NumPy, and SciPy dependencies
- X11 forwarding for GUI support
- Cadnano2 v2.2.0 pre-installed
- Non-root user for security
- Persistent data volumes
- Pre-built Docker image available on Docker Hub

## Prerequisites

### General Requirements
- Docker installed and running
- Docker Compose installed

### macOS Specific Requirements
- [XQuartz](https://www.xquartz.org/) installed and running
  ```bash
  brew install --cask xquartz
  ```

### Linux Specific Requirements
- X11 server running (default on most Linux desktop environments)

## Quick Start

1. Clone or download this repository
2. Run the setup script for your platform:
   ```bash
   ./run_cadnano.sh setup
   ```
3. Pull the Docker image from Docker Hub:
   ```bash
   ./run_cadnano.sh pull
   ```
4. Run Cadnano2:
   ```bash
   ./run_cadnano.sh run
   ```

### Alternative: Direct Docker Hub Usage

You can also run Cadnano2 directly from Docker Hub without cloning this repository:

```bash
# Setup X11 forwarding (see platform-specific instructions below)
./run_cadnano.sh setup

# Run directly from Docker Hub
docker run -it --rm \
  -e DISPLAY=host.docker.internal:0 \
  -e QT_X11_NO_MITSHM=1 \
  -e QT_QPA_PLATFORM=xcb \
  --add-host "host.docker.internal:host-gateway" \
  -v $(pwd)/cadnano_data:/home/cadnano/data \
  -v $(pwd)/cadnano_projects:/home/cadnano/projects \
  subhajitroy/cadnano:latest
```

## Detailed Instructions

### Pulling the Docker Image

To pull the Cadnano2 Docker image from Docker Hub manually:

```bash
docker pull subhajitroy/cadnano:latest
```

Or using the provided script:

```bash
./run_cadnano.sh pull
```

### Building from Source (Optional)

If you want to build the image from source instead of using the pre-built Docker Hub image:

```bash
docker-compose build
```

### Running Cadnano2

#### Using the Script (Recommended)

The `run_cadnano.sh` script handles platform-specific setup automatically:

```bash
# Setup X11 forwarding for your platform
./run_cadnano.sh setup

# Pull the image from Docker Hub
./run_cadnano.sh pull

# Run Cadnano2
./run_cadnano.sh run
```

#### Manual Execution

**For macOS:**

1. Start XQuartz if not already running:
   ```bash
   open -a XQuartz
   ```

2. Allow X11 connections:
   ```bash
   xhost +localhost
   ```

3. Set environment variables:
   ```bash
   export DISPLAY=:0
   export XAUTHORITY=~/.Xauthority
   ```

4. Run the container:
   ```bash
   docker-compose up
   ```

**For Linux:**

1. Allow X11 connections from Docker:
   ```bash
   xhost +local:docker
   ```

2. Set environment variables:
   ```bash
   export DISPLAY=${DISPLAY:-:0}
   export XAUTHORITY=${XAUTHORITY:-~/.Xauthority}
   ```

3. Run the container:
   ```bash
   docker-compose up
   ```

### Stopping the Container

To stop the running container:

```bash
./run_cadnano.sh stop
```

Or manually:

```bash
docker-compose down
```

## Data Persistence

The Docker setup includes two persistent volumes:

- `cadnano_data`: General data storage
- `cadnano_projects`: Project-specific files

These volumes are automatically created when you first run the container and will persist between container restarts.

## Troubleshooting

### Common GUI Forwarding Issues

#### "Cannot connect to display" Error

**macOS:**
1. Ensure XQuartz is installed and running
2. Check that XQuartz allows network connections:
   - Open XQuartz → Preferences → Security
   - Ensure "Allow connections from network clients" is checked
3. Restart XQuartz and run `./run_cadnano.sh setup` again

**Linux:**
1. Verify X11 server is running: `echo $DISPLAY`
2. Check if X11 authentication is working: `xauth list`
3. Try running: `xhost +local:docker`

#### Permission Denied Errors

1. Ensure the script is executable:
   ```bash
   chmod +x run_cadnano.sh
   ```

2. Check Docker permissions:
   ```bash
   sudo usermod -aG docker $USER
   ```
   Then log out and log back in.

#### Performance Issues

1. For better performance on macOS, consider using [XQuartz with OpenGL acceleration](https://www.xquartz.org/):
   - Open XQuartz Preferences → Advanced
   - Check "Use OpenGL acceleration"

2. Ensure sufficient memory is allocated to Docker:
   - Docker Desktop → Settings → Resources → Memory
   - Allocate at least 4GB

### Container Issues

#### Build Failures

1. Check your internet connection
2. Verify Docker has sufficient disk space
3. Try rebuilding with no cache:
   ```bash
   docker-compose build --no-cache
   ```

#### Runtime Errors

1. Check container logs:
   ```bash
   docker-compose logs cadnano2
   ```

2. Run container in interactive mode for debugging:
   ```bash
   docker-compose run --rm cadnano2 /bin/bash
   ```

## Platform-Specific Notes

### macOS

- XQuartz must be installed and running before launching Cadnano2
- The first time you run XQuartz, you may need to restart your terminal
- Some macOS security features may require additional permissions:
  - System Preferences → Security & Privacy → Privacy
  - Add Docker and Terminal to "Accessibility" if prompted

### Linux

- Most Linux distributions with desktop environments have X11 pre-configured
- On Wayland-based systems, you may need additional configuration:
  ```bash
  # For GNOME/Wayland
  export XDG_SESSION_TYPE=x11
  # Or use XWayland
  export GDK_BACKEND=x11
  ```

## Advanced Usage

### Custom Configuration

You can modify the `docker-compose.yml` file to:
- Add additional volume mounts
- Change environment variables
- Modify network settings

### Development

For development purposes, you can mount additional directories:

```yaml
volumes:
  - ./cadnano2:/home/cadnano/cadnano2  # Mount source code
  - ./custom_data:/home/cadnano/custom_data  # Mount custom data
```

### Running Commands Inside Container

To execute commands inside the running container:

```bash
docker-compose exec cadnano2 /bin/bash
```

## File Structure

```
.
├── Dockerfile              # Docker image definition
├── docker-compose.yml      # Docker Compose configuration
├── run_cadnano.sh          # Convenience script for running Cadnano2
├── README.md               # This file
├── cadnano_data/           # Persistent data volume (created automatically)
└── cadnano_projects/       # Persistent projects volume (created automatically)
```

## Version Information

- Cadnano2: v2.2.0
- Python: 2.7
- PyQt4: Latest
- Ubuntu: 18.04
- Docker Image: `subhajitroy/cadnano:latest` and `subhajitroy/cadnano:v2.2.0`

## Docker Hub

The pre-built Docker image is available on Docker Hub:
- Repository: [subhajitroy/cadnano](https://hub.docker.com/r/subhajitroy/cadnano)
- Tags: `latest`, `v2.2.0`

You can pull and run the image directly:
```bash
docker pull subhajitroy/cadnano:latest
docker run -it --rm subhajitroy/cadnano:latest
```
- Docker Image: `subhajitroy/cadnano:latest` and `subhajitroy/cadnano:v2.2.0`

## Docker Hub

The pre-built Docker image is available on Docker Hub:
- Repository: [subhajitroy/cadnano](https://hub.docker.com/r/subhajitroy/cadnano)
- Tags: `latest`, `v2.2.0`

You can pull and run the image directly:
```bash
docker pull subhajitroy/cadnano:latest
docker run -it --rm subhajitroy/cadnano:latest
```

## Support

For issues related to:
- Cadnano2 functionality: [Cadnano2 GitHub Repository](https://github.com/cadnano/cadnano2)
- Docker setup: Create an issue in this repository
- X11 forwarding: Consult your platform's documentation

## License

This Docker setup is provided under the same license as Cadnano2. Please refer to the [Cadnano2 license](https://github.com/cadnano/cadnano2/blob/master/LICENSE) for more information.
