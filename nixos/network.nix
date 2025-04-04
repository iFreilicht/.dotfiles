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
  nextcloud = (mkService "cloud" 33001) // {
    nginx_max_body_size = "1024M";
  };
  snapdrop = mkService "drop" 33002;
  kritzeln = mkService "kritzeln" 33003;
  git = mkService "git" 33004;
  home-assistant = mkService "home" 33005;
  pihole = mkService "pihole" 33006 // {
    dnsPort = 33353;
  };
  transmission = mkService "transmission" 33007;
  # ON REINSTALL: Make sure to set this port in jellyfin's config/network.xml
  jellyfin = mkService "media" 33008;
  audiobookshelf = mkService "audio" 33009;
  home = {
    baseIP = homeBaseIP;
    subnet = "${homeBaseIP}.0/24";
    router = "${homeBaseIP}.1";
    zone = "fritz.box";
  };
  wireguard = {
    baseIP = wgBaseIP;
    subnet = "${wgBaseIP}.0/24";
  };
  gateway = {
    # ON REINSTALL: Run `sudo cat /root/.ssh/id_ed25519.pub` and update this value
    root.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKO5US+fVZqaeWR6UjNWBU31xOOenn+Bj/zuYhme4mxL root@gateway";
    # On REINSTALL: Run `cat /etc/ssh/ssh_host_ed25519_key.pub` and update this value
    hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+y8cm1qUCUdZYJBmlcP3i/CN5xzMLhv9n+CSr5RXHm";
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
    # ON REINSTALL: Run `sudo cat /root/.ssh/id_ed25519.pub` and update this value
    root.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICzxpvz0x2hc4Fa4SPaJ7ZAxrUrNd4qfDxUyUb1/903q root@junction";
    # ON REINSTALL: Ensure the router is statically setting the IP of junction to this
    home.ip = "${homeBaseIP}.13"; # Statically set in router
    # On REINSTALL: Run `cat /etc/ssh/ssh_host_ed25519_key.pub` and update this value
    hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINb5fncMa9mndIB6+rIElTvgxHoziZWgHA6llkw2yJg/";
    wireguard = {
      ip = "${wgBaseIP}.13";
      # ON REINSTALL: Run `sudo cat /etc/wireguard/private | wg pubkey` and update this value
      publicKey = "ocMusNfO8N6z4kc2FEJMwhFTdRV4VWbKyAhGZMDzJSE=";
    };
    remoteBuilder = {
      system = "x86_64-linux";
      maxJobs = 4;
      speedFactor = 4;
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
  DESKTOP-O2898M0 = {
    wireguard = {
      ip = "${wgBaseIP}.63";
      publicKey = "i9cb+AxxoJC8vmMRBC4Sknu41j+1Tl9qICKTicxRzm0=";
    };
  };
  source = {
    name = "source";
    felix.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0TI3HN6e00Bv29ui7BUCYSa4FBjcWBs4fE5R1ODc9+ felix@source";
    # On REINSTALL: Run `cat /etc/ssh/ssh_host_ed25519_key.pub` and update this value
    hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbNR9YHoKGaj46GvJlVi6z/30YFN3mbHvVs/oXjY/4X";
    remoteBuilder = {
      system = "x86_64-linux";
      maxJobs = 4;
      speedFactor = 8;
    };
    wireguard = {
      ip = "${wgBaseIP}.33";
      # ON REINSTALL: Run `sudo cat /etc/wireguard/private | wg pubkey` and update this value
      publicKey = "T5RIZ2K07nyBcRd5dKpgL5TWsF4coLOkl6NMFIMMtkY=";
    };
  };
}
