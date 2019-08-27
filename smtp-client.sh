#!/usr/bin/env bash
### SMTP client for command line ### @RCaldas84

### Load settings from .env file or uncomment next:
source .env
# SMTP_SERVER='server.domain:587'
# SMTP_USER='smtpuser'
# SMTP_PWD='userpassword'
# SMTP_TLS=1
# DOMAIN='domain.com'
# ADMIN_MAIL='your@mail.com'

### Set /etc/mailname
sudo echo "$DOMAIN" > /etc/mailname

### /etc/mail.rc


### ~/.mailrc


### Set MAILTO in crontab, replace if exist or add at top:
grep -q 'MAILTO=' /etc/crontab && \
  sudo sed -i "/MAILTO=/c\MAILTO=$ADMIN_MAIL" /etc/crontab || \
  sudo sed -i "1iMAILTO=$ADMIN_MAIL" /etc/crontab


### With exim4
### With postfix
### With msmtp
