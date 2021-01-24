## de.crockett.network

This repo contains scripts to automatically provision a brand-new Arch server. You can run the following to set everything up in one step (assuming you're logged in as root):

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

As of 2021-01-24, this repo will set up HTTPS-enabled Nginx with an A+ rating according to the [Qualys SSL Labs test][1].

[1]: https://www.ssllabs.com/ssltest/
