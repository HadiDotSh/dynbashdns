# DynBashDns
#### Dynamic DNS for Cloudflare written in bash, allows to change a record when your IP change, easy to use and with telegram notification on record changes.

### Install :
<p>Simply past this line in your shell :</p>

```bash
git clone https://github.com/hadrienaka/dynbashdns && cd dynbashdns && bash install.sh
```
<p>Then, add an alias to your bashrc/zshrc file, and a crontab</p>

### Arguments :
```bash
help            Show brief help
add             Add a new record or telegram notifications
remove          Remove a record or telegram notifications
list            List all current records
list detail     List records with name,zoneID,recordID and proxy status
```

### More informations
<p>You can found more informations on the wiki page available here : https://dynbashdns.what-the-shell.me
