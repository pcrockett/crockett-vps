## Crockett VPS

This repo contains scripts to provision and manage my own personal cloud service on an Arch VPS.

### Why not Ansible / Terraform / Kubernetes etc?

This project exists for a couple reasons:

1. I find it to be useful and fun
2. It's deepening my experience in various topics (Arch, systemd, Matrix, Podman, Bash, etc.)

If I throw yet another thing into the list of topics to learn (i.e. Terraform and Ansible), I'll never finish. This is a free time project. Some day when things are running smoothly, I may consider migrating this to Terraform.

### Features

As of 2021-02-15, this repo will automatically set up:

* HTTPS-enabled Nginx reverse proxy with a [Qualys SSL Labs test][1] A+ rating.
* [Synapse][2] (Matrix homeserver)
* [Element][3] (web-based Matrix client)
* [Coturn][4] (for VoIP calls in Matrix)
* [Sydent][5] (Matrix identity server)
* [WireGuard][6] VPN with NAT and [Quad9][7] DNS

It uses [Podman][8] instead of Docker to run unprivileged containers. It also does semi-automatic updates ("semi" because this is Arch, and manual intervention is required).

I wrote this for my own purposes, so while most of this could be useful to someone else, a few things exist that are not very applicable to other people. Feel free to use this, but you'll want to make a few changes.

### Install

You can run the following to set everything up in one step (assuming you're logged in to your server as root):

```bash
curl --silent --show-error --fail \
    https://raw.githubusercontent.com/pcrockett/crockett-vps/main/quick-start.sh > quick-start.sh
chmod u+x ./quick-start.sh
./quick-start.sh
```

... or if you want to do things manually:

1. Install git
2. Clone this repo
3. Execute `run.sh`

### Usage

After initial setup, you should see the following new scripts in `/usr/local/bin`:

* `server-cmd`: The main command that makes it easy to pull changes from the remote Git repo and apply them on the server
* `new-matrix-user`: Create a new matrix user
* `new-wireguard-peer`: Add a new device to the WireGuard VPN

Pass a `--help` parameter to any of these commands to see how they are used.

### TODO:

* [ ] Postgres container (and configure Synapse to use it)
* [ ] Auto backups
* [ ] Refactor to a Yunohost-like package system?
* [ ] Matterbridge
* [ ] Signal bridge?
* [ ] docker-mailserver or Mailcow?

[1]: https://www.ssllabs.com/ssltest/
[2]: https://github.com/matrix-org/synapse
[3]: https://github.com/vector-im/element-web
[4]: https://github.com/instrumentisto/coturn-docker-image
[5]: https://github.com/matrix-org/sydent
[6]: https://www.wireguard.com/
[7]: https://www.quad9.net/
[8]: https://podman.io/
