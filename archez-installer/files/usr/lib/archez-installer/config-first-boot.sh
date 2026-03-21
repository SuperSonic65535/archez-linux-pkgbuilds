#!/bin/sh
## Delete live user
userdel -rf live; rm -rf /home/live

## Set user UID and GID to 1000 (default)
UserName="$(ls -I live /home | xargs | cut -d ' ' -f 1)"
sed -i "/:\/home\/$UserName:/c$UserName:x:1000:1000::\/home\/$UserName:\/usr\/bin\/bash" /etc/passwd
sed -i "/^$UserName:x:/c\\$UserName:x:1000:" /etc/group
chown -R 1000:1000 /home/$UserName

## Delete first boot service
rm -f /etc/systemd/system/config-first-boot.service \
/etc/systemd/system/multi-user.target.wants/config-first-boot.service \
/config-first-boot.sh
