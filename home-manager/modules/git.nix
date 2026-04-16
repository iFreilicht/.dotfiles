{ ... }:
{
  programs.git = {
    enable = true;

    settings.user.name = "Felix Uhl";
    settings.user.email = "github@mail.felix-uhl.de";

    ignores = [
      "*.swp"
    ];

    # Use the new default, I don't sign my commits yet anyway
    signing.format = null;

    iniContent = {
      rerere.enabled = false;

      # Load custom configuration for specific sets of repositories
      includeIf."gitdir:~/repos/Elli/**".path = "~/repos/Elli/.gitconfig-Elli";
      includeIf."gitdir:~/repos/Netlight/**".path = "~/repos/Netlight/.gitconfig-Netlight";
    };
  };
}
