resource "hcloud_zone" "uhl" {
  name = "uhl.cx"
  mode = "primary"
  ttl = 86400
  delete_protection = true
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

resource "hcloud_zone_rrset" "uhl" {
  zone = hcloud_zone.uhl.name
  type = "A"
  records = [ { value = "49.12.239.37" } ]

  for_each = local.subdomains

  name = each.value
}

resource "hcloud_zone_rrset" "atproto" {
  zone = hcloud_zone.uhl.name
  type = "TXT"
  records = [ { value = "\"did=did:plc:yfhhlh7xyjvsiexi3yy3ghqg\"" } ]
  name = "_atproto"
}