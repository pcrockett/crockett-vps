## de.crockett.network

This repo contains scripts to automatically provision my own personal cloud service on an Arch VPS. It's one part documentation for myself, one part experimentation, one part learning project, and one part fun.

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

As of 2021-01-30, this repo will set up:

* HTTPS-enabled Nginx reverse proxy with an A+ rating according to the [Qualys SSL Labs test][1].
* Synapse (Matrix homeserver)
* Element (web-based Matrix client)
* A TURN server (for VoIP calls in Matrix)

It uses Podman instead of Docker to run unprivileged containers running as different users.

### TODO:

* [ ] Jitsi
* [ ] WireGuard VPN
* [ ] Auto updates

[1]: https://www.ssllabs.com/ssltest/
