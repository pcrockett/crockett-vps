## de.crockett.network

This repo contains scripts to automatically provision a brand-new Arch server.

### Install

You can run the following to set everything up in one step (assuming you're logged in as root):

```bash
curl --proto '=https' \
    --tlsv1.2 \
    --silent \
    --show-error \
    --fail \
    https://raw.githubusercontent.com/pcrockett/de.crockett.network/main/quick-start.sh > quick-start.sh
chmod u+x ./quick-start.sh
./quick-start.sh
```

... or if you want to do things manually:

1. Install git
2. Clone this repo
3. Execute `run.sh`

### Features

As of 2021-01-28, this repo will set up:

* HTTPS-enabled Nginx reverse proxy with an A+ rating according to the [Qualys SSL Labs test][1].
* Synapse (Matrix homeserver)
* Element (web-based Matrix client)

It uses Podman instead of Docker to run unprivileged containers.

### TODO:

* [ ] Jitsi
* [ ] Auto updates

[1]: https://www.ssllabs.com/ssltest/
