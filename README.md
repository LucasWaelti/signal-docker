# signal-docker
Dockerize Signal Desktop to run on OS versions no longer supported by the app.

**Tested on**:
- `Ubuntu 20.04`

## Setup
Build the image with
```bash
./build.sh
```

Run the container with
```bash
./run.sh
```

The GUI will launch from the container and the app can be paired with a Signal account following the usual procedure. 

> **Note**: Data is persisted and stored on the host at `~/.signal-container/home`. This directory is mounted in the container. 