# nzbhydra-for-tos

> TerraMaster TOS 7 App Center — **Docker application** package for
> [NZBHydra 2](https://github.com/theotherp/nzbhydra2).

## What this is

A four-file TOS Docker application archive (`nzbhydradocker.tar.gz`) that installs
NZBHydra 2 on TOS 7 through the App Center:

- `config.ini` — TOS application metadata (`application_type: docker`, id `nzbhydradocker`)
- `nzbhydradocker.lang` — 23-language superset (TOS requires 14)
- `nzbhydradocker.svg` — application icon (12752 bytes, 16 SVG elements)
- `docker-compose.yml` — one service, image `linuxserver/hydra2:version-v3.0.0`

## How it works

| | |
|---|---|
| Container image | `linuxserver/hydra2:version-v3.0.0` (Docker Hub, used unmodified) |
| Open | `http://<NAS-IP>:8142/` (container port 5076) |
| Runs as | non-root, `user: "1000:1000"` |
| Persistent data | `/config` → `/Volume1/DockerAppData/nzbhydradocker/config` |
| Logs | `docker logs nzbhydradocker` (stdout/stderr) |

`/config` (mounted from `DockerAppData/nzbhydradocker/config`) holds `nzbhydra.yml`, the H2 database, logs and the unpacked application jar.

## Design highlights

- **Non-root.** `user: "1000:1000"`; verified on real hardware (the container reports uid 1000).
- **Entrypoint wrapper**: the upstream s6 init cannot run as uid 1000; the wrapper runs the bundled `nzbhydra2wrapperPy3.py` launcher with `--datafolder /config`.
- **Fixed image tag, never `:latest`**, Docker Hub only, no `privileged`, no `network_mode: host`, and no Docker socket, no `cap_add`.
- **Health check** probing the service on container port 5076.
- **Deterministic build**: GNU tar with uid/gid 0 and zeroed timestamps, gzip without a timestamp, plus the review-standards self-check above.
- **Upstream launcher instead of s6.** The wrapper runs `nzbhydra2wrapperPy3.py --datafolder /config` as uid 1000; the launcher prepares the jar inside the data folder.
- **One port for UI and API.** Sonarr/Radarr use the same port with the API key.

## Privacy

This application runs entirely on your NAS. It does not include analytics, telemetry or advertising SDKs, and the packaging contains no code that sends data to the packager. Data is only exchanged with the services you configure yourself (for example media servers, notification endpoints or model APIs), and only from the container. Everything the application stores lives in the application data folder described above; removing the app with its data deletes it.

## Third-party components

The package runs the upstream image `linuxserver/hydra2:version-v3.0.0` unmodified. Its components and their licences are those of the upstream project (https://github.com/theotherp/nzbhydra2), which is distributed under **Apache-2.0**. No upstream source code is redistributed in this repository; only the four packaging files are original work.

## Runtime file manifest

Everything the application writes on the NAS lives inside its own data
directory; the container-internal `/tmp` is discarded with the container. The
table lists what is created and how it behaves. Nothing else is written.

| Path | Purpose | Created when | Growth bound | Lifecycle |
|---|---|---|---|---|
| `/Volume1/DockerAppData/nzbhydradocker/config` | NZBHydra 2 application data (everything the container writes outside /tmp) | on first start / on demand | bounded by your own data | persistent; kept on uninstall unless you ask to delete it |

## Build

```bash
scripts/build.sh                  # -> out/nzbhydradocker.tar.gz + .sha256
scripts/build.sh 3.0.0-2   # packaging iteration bump
scripts/build.sh 3.0.0-1 aarch64
```

The build stages the four files, substitutes the version/platform placeholders,
embeds `src/entrypoint.sh` into the compose file (escaping every `$` as `$$`), removes CRLF/BOM/AppleDouble, then runs
`tools/verify.py`, a review-standards self-check (archive layout, JSON validity,
required fields, 14+ language coverage, version consistency, Docker-Hub-only
images, fixed tag, reserved/recommended host ports, non-root user, per-service
healthcheck/TZ/restart, data path below the application data root, never the
`/Volume*` wildcard, comment-free sequence blocks, `x-app-meta` position, no
literal secrets and the SVG size/element limits).

## Local verification

```bash
./TOSAppSelfTestingTool -c out/nzbhydradocker.tar.gz   # official spec check
bash test/install-and-verify.sh                  # on-device E2E (needs root)
```

> Docker applications cannot be side-loaded through the App Center's manual
> install page (it accepts `.deb` only); the official self-testing tool's `-i`
> mode or `docker compose` are the only ways to install one for testing.

## Store submission checklist

1. Public GitHub repo (code + README only).
2. Release **tag `v3.0.0-1`**, assets `nzbhydradocker.tar.gz` +
   `nzbhydradocker.tar.gz.sha256` (Docker asset naming: `<app_id>.tar.gz`, **no
   platform suffix**).
3. Developer platform → Add Application: ID `nzbhydradocker`, package type Docker,
   repository URL, architecture `x86_64`.
4. Version Management → Add Version `3.0.0-1` → automated validation → review.

## License / branding

NZBHydra 2 is distributed by its upstream authors under **Apache-2.0**. The container image is the official image from Docker Hub (`linuxserver/hydra2:version-v3.0.0`) and is used unmodified; no upstream source code is redistributed here. This packaging is an independent community submission by Moechz and is not affiliated with the upstream project or TerraMaster.

## Limitations

- Needs at least one indexer account; the package ships no indexer credentials.
- The UI is plain HTTP; use a TLS reverse proxy before exposing it to the internet.
- Java apps are memory-hungry; the container needs ~512 MB free RAM.

---

Packaged for TOS 7 by Moechz. Upstream image used unmodified from Docker Hub.
