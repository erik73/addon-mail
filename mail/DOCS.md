# Home Assistant Add-on: Mailserver

Postfix/Dovecot mailserver with Postfixadmin web interface...

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield]
![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

Important: This addon requires that the MariaDB add-on is installed and running!

This addon is experimental, and provides a mailserver for your domain.
It is also possible to configure additional email domains and accounts in the Postfixadmin
web interface.

The following ports are used by this addon:

smtp: port 25, 465 and 587
imap(s): 993

If you are brave, and want to expose the mail server to Internet:

To recieve mail from the Internet, the SMTP ports have to be added for redirection
in your router. The necessary MX and A records will have to be registered in DNS.
If you want to be able to check emails from outside of your network the IMAPS port
will also have to be forwarded.

The default setup will use self signed certificates created by Dovecot during
the initial setup. It is OK for testing, but "real" certificates should be used.

The config option "letsencrypt_certs" will, is set to "true", use the
fullchain.pem and privkey.pem in the /ssl directory in Home Assistant.

## Installation

Follow these steps to get the add-on installed on your system:

Add the repository `https://github.com/erik73/hassio-addons`.
Find the "Mailserver" add-on and click it.
Click on the "INSTALL" button.

## How to use

### Starting the add-on

After installation you are presented with a default and example configuration.

Adjust the add-on configuration to match your requirements.
Save the add-on configuration by clicking the "SAVE" button.
Start the add-on.

## Configuration

Example configuration:

```yaml
my_hostname: mydomain.no-ip.com
domain_name: mydomain.no-ip.com
admin_user: admin
admin_password: admin
letsencrypt_certs: false
enable_mailfilter: false
```

Please note: During the startup of the add-on, a database is created in the
MariaDB add-on. There is currently not possible to change user credentials or
domain_name after the database is created.
The only way to change these options is to drop the postfixadmin datbase and
restart the add-on. Use the phpMyadmin add-on to drop the database.

### Option: `my_hostname` (required)

The hostname of your mailserver. It should correspond to the A-record you
have in your DNS.

#### Option: `domain_name` (required)

This is the name of the domain you want to recieve mail from. Additional domain
can be added in the postfixadmin-interface.

#### Option: `admin_user` (required)

The name of the admin user in postfixadmin. To log in to the web interface
you have to use FQDN. For example: admin@mydomain.no-ip.com.
In the current version of the add-on, this can not be changed once the database
is created.

#### Option: `admin_password` (required)

The password for the admin_user.
In the current version of the add-on, this can not be changed once the
database is created.

#### Option: `letsencrypt_certs` (required)

If you use the Let´s Encrypt add-on, and have certs installed in the /ssl
folder of your HA instance.
Yhis option will use those certificates for the SMTP and IMAP services.

#### Option: `enable_mailfilter` (required)

This enables communication with the optional Mailfilter add-on in this repository.
It will enable Postfix to scan emails for SPAM and viruses. Please note that
the virus scanning requires a lot of memory, and 4-8 GB mommory is recommended.
Virus scanning is disabled by default in the Mailfilter add-on.

#### Option: `smtp_relayhost` (optional)

Use this optional setting to use a realy server for outgoing emails. ISP:s often
block outgoing emails from your network. In that case, you can often use your
ISP:s SMTP relay host to bypass this limitation.

## Support

Got questions?

You could [open an issue here][issue] GitHub.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[conf]: http://developer.telldus.com/wiki/TellStick_conf
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[issue]: https://github.com/erik73/addon-tellsticklive/issues
[repository]: https://github.com/erik73/hassio-addons
