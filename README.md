# goINPUT Terraform Infrastructure
Repo beinhaltet die Definition unserer derzeitigen Infrastruktur.

## Module
* database
* firewall
* mailserver
* networks
* saltbastion
* webservice

## Provider
* [hetznercloud/hcloud](https://github.com/hetznercloud/terraform-provider-hcloud)
* [maxlaverse/bitwarden](https://github.com/maxlaverse/terraform-provider-bitwarden)
* [cloudflare/cloudflare](https://github.com/cloudflare/terraform-provider-cloudflare)

## ToDo
* Salt Reactor anstelle von Terraform Provisioner nutzen, um u. A. states anzuwenden und Minion Keys zu akzeptieren.