{ ... }:
{
  programs.git = {
    enable = true;

    userName = "Felix Uhl";
    userEmail = "github@mail.felix-uhl.de";

    ignores = [
      "*.swp"
    ];

    iniContent = {
      rerere.enabled = false;

      # Load custom configuration for specific sets of repositories
      includeIf."gitdir:~/repos/Elli/**".path = "~/repos/Elli/.gitconfig-Elli";
      includeIf."gitdir:~/repos/Netlight/**".path = "~/repos/Netlight/.gitconfig-Netlight";
    };
  };
}
