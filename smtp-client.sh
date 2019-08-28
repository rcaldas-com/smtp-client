#!/usr/bin/env bash
### SMTP client for command line ### @RCaldas84

### Get current script dir
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

### Load settings from .env file or uncomment next:
source $DIR/.env
# SMTP_SERVER='server.domain'
# SMTP_PORT=587
# SMTP_USER='user@mail.com'
# SMTP_PWD='userpassword'
# DOMAIN='domain.com'
# ADMIN_MAIL='your@mail.com'

### Set /etc/mailname
echo "$DOMAIN" | sudo tee /etc/mailname >/dev/null

### Check fot postfix package
if ! dpkg -s postfix &> /dev/null; then
  sudo apt update
  sudo apt install -y postfix
fi

### Set sasl_passwd file
echo "[$SMTP_SERVER]:$SMTP_PORT $SMTP_USER:$SMTP_PWD" | \
  sudo tee /etc/postfix/sasl_passwd >/dev/null
sudo chmod 600 /etc/postfix/sasl_passwd
sudo postmap /etc/postfix/sasl_passwd

### Set main.cf file
[ ! -e /etc/postfix/main.cf.bkp ] && \
  sudo cp /etc/postfix/main.cf /etc/postfix/main.cf.bkp
cat <<EOF | sudo tee /etc/postfix/main.cf >/dev/null
myhostname = $DOMAIN
inet_interfaces = loopback-only
relayhost = [$SMTP_SERVER]:$SMTP_PORT
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_use_tls = yes
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
mynetworks_style = host
EOF

### Set MAILTO in crontab, replace if exist or add at top:
grep -q 'MAILTO=' /etc/crontab && \
  sudo sed -i "/MAILTO=/c\MAILTO=$ADMIN_MAIL" /etc/crontab || \
  sudo sed -i "1iMAILTO=$ADMIN_MAIL" /etc/crontab

### Restart postfix
sudo systemctl restart postfix
