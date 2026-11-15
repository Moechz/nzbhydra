# Changelog

All notable user-visible changes to the NZBHydra 2 TOS application package.

## 3.0.0-1 — 2026-11-15

### Added
- First release. NZBHydra 2 (`linuxserver/hydra2:version-v3.0.0`, Docker Hub official image, unmodified)
  packaged as a TOS 7 Docker application, published on port 8142 and running
  as a non-root user (1000:1000).
- Persistent data is kept under `/Volume1/DockerAppData/nzbhydradocker/`.
