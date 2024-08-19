resource "hetznerdns_zone" "uhl" {
  name = "uhl.cx"
  ttl = 86400
}

locals {
  subdomains = toset([
    "@",
    "cloud",
    "drop",
    "kritzeln",
    "git",
    "transmission",
    "cloud2",
  ])
}

resource "hetznerdns_record" "uhl" {
  zone_id = hetznerdns_zone.uhl.id
  type = "A"
  value = "49.12.239.37"

  for_each = local.subdomains

  name = each.value
}