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
    "home",
    "pihole",
    "transmission",
    "media",
    "audio",
  ])
}

resource "hetznerdns_record" "uhl" {
  zone_id = hetznerdns_zone.uhl.id
  type = "A"
  value = "49.12.239.37"

  for_each = local.subdomains

  name = each.value
}

resource "hetznerdns_record" "atproto" {
  zone_id = hetznerdns_zone.uhl.id
  type = "TXT"
  value = "did=did:plc:yfhhlh7xyjvsiexi3yy3ghqg"
  name = "_atproto"
}