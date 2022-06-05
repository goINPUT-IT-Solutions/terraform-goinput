# Staging environment
Used later.

Powered by Terraform and SaltStack

---

## Module

### - database
Beinhaltet alle notwendigen Resourcen um unsere Datenbank-Server aufzubauen.
### - firewall
Definiert alle von dem Servern verwendete Firewalls in der Hetzner Infrastruktur.
### - mailserver
Beinhaltet alle notwendigen Resourcen um unsere Mail-Server aufzubauen.
### - networks
Definiert alle von dem Servern verwendete Firewalls in der Hetzner Infrastruktur.
### - salt
Herzstück der Infrastruktur: Modul um unseren Salt-Master zu bauen.
### - webservice
Modul baut alle Webservices auf.

---

## Provider
* [hetznercloud/hcloud](https://github.com/hetznercloud/terraform-provider-hcloud)
* [maxlaverse/bitwarden](https://github.com/maxlaverse/terraform-provider-bitwarden)
* [cloudflare/cloudflare](https://github.com/cloudflare/terraform-provider-cloudflare)

## ToDo
- Minion Auto Acception absichern.
- [github.com/salt-hetzner](https://github.com/goINPUT-IT-Solutions/salt-hetzner) Repo bei Commit automatisch pullen