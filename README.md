# A script for notifying users about the expiration of their AD password by mail from a Linux server

## Principle of operation

Every day, on a cron on a Linux machine, a script starts that logs into a domain controller and checks user passwords for their expiration date. Only active users with expiring passwords are checked. If the password expires in less than 15 days inclusive, then a letter is sent to this user's mailbox specified in AD. Emails will be sent every time until the password is changed or expires. When the password has expired, an overdue letter is sent by the same principle.

## Dependencies

The `ldapsearch` utility from the `ldap-utils` toolkit for collecting information from an AD server, a `bc` calculator for arithmetic calculations, and a console mail client `mutt`:

```
apt install ldap-utils bc mutt
```

## Usage

* Place the `.muttrc_pass_exp` file to the user's home directory from which the script will run. For example `/root/.muttrc_pass_exp`. And replace `smtp_pass`, `from` and `smtp_url` parameters with the ones you want.

* Add cron job script `user_pass_expire.sh` to execute


[Detailed description](https://notessysadmin.com/notify-users-of-ad-password-expiration-by-mail-from-linux) in Russian
