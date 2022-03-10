#resource "betteruptime_status_page" "this" {
#  company_name = "Example, Inc"
#  company_url  = "https://goinput.de"
#  timezone     = "UTC"
#  subdomain    = "status-test"
#}

#resource "betteruptime_monitor" "this" {
#  url          = "https://status2.goinput.de"
#  monitor_type = "status"
#}

#resource "betteruptime_status_page_resource" "monitor" {
#    status_page_id = betteruptime_status_page.this.id
#    resource_id    = betteruptime_monitor.this.id
#    resource_type  = "Monitor"
#    public_name    = "goINPUT IT Solutions"
#}