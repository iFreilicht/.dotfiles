let
  mkBorgbaseRepo = id: label: {
    id = id;
    host = "${id}.repo.borgbase.com";
    path = "ssh://${id}@${id}.repo.borgbase.com/./repo";
    label = label;
  };
  rootDomain = "uhl.cx";
  mkService = subDomain: port: {
    inherit subDomain port;
    domain = "${subDomain}.${rootDomain}";
  };
  homeBaseIP = "192.168.178";
  wgBaseIP = "10.100.0";
in
{
  domain = rootDomain;
  nextcloud = (mkService "cloud" 33001) // { nginx_max_body_size = "512M"; };
  snapdrop = mkService "drop" 33002;
  kritzeln = mkService "kritzeln" 33003;
  git = mkService "git" 33004;
  home = {
    subnet = "${homeBaseIP}.0/24";
    router = "${homeBaseIP}.1";
    zone = "fritz.box";
  };
  gateway = {
    wireguard = {
      ip = "${wgBaseIP}.1";
      # Only route traffic of the wireguard subnet through the VPN, not the whole internet
      subnet = "${wgBaseIP}.0/24";
      # ON REINSTALL: Run `sudo cat /etc/wireguard/private | wg pubkey` and update this value
      publicKey = "70NDFa+EmxNDZLW3QFO3blILT3oRA5K3aIofjLPdIxg=";
      initialIP = "49.12.239.37"; # The static IP the server can be reached at
    };
  };
  junction = {
    name = "junction";
    # ON REINSTALL: Ensure the router is statically setting the IP of junction to this
    home.ip = "${homeBaseIP}.13"; # Statically set in router
    wireguard = {
      ip = "${wgBaseIP}.13";
      # ON REINSTALL: Run `sudo cat /etc/wireguard/private | wg pubkey` and update this value
      publicKey = "ocMusNfO8N6z4kc2FEJMwhFTdRV4VWbKyAhGZMDzJSE=";
    };
    borgbase = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMS3185JdDy7ffnr0nLWqVy8FaAQeVh1QYUSiNpW5ESq";
      repos = {
        files = mkBorgbaseRepo "a9518u4s" "junction.uhl.cx - files";
        databases = mkBorgbaseRepo "qhu6ppjs" "junction.uhl.cx - databases";
      };
    };
  };
  horse = {
    felix.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB9OOXhRhYgpaFLwbkfcQsSYYUTr+qsbf0WIHcUm2fFQ felix@horse";
    root.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMj4suEfNQKtFyYVlO3bgawvKuM/FWYtgu6BPMe5R8ia root@horse";
    wireguard = {
      ip = "${wgBaseIP}.8";
      publicKey = "adcMoJUfbf+RTtRt6oXCggop1XDWGfiWyGQzA9gmpB0=";
    };
  };
  uhl'siphone = {
    wireguard = {
      ip = "${wgBaseIP}.43";
      publicKey = "6fKbTyEIkY0bBG4iL5JENfJNc465UucjZoZcebx4wFc=";
    };
  };
  source.felix.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0TI3HN6e00Bv29ui7BUCYSa4FBjcWBs4fE5R1ODc9+ felix@source";
}
