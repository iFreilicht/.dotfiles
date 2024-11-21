{ ... }:
{
  home.shellAliases = {
    # Make aliases work with sudo, see https://unix.stackexchange.com/a/349290/67771
    sudo = "sudo ";

    # Colorize command output
    ls = "ls --color=auto -vF";
    dir = "dir --color=auto";
    vdir = "vdir --color=auto";
    grep = "grep --color=auto";
    fgrep = "fgrep --color=auto";
    egrep = "egrep --color=auto";

    # Default ls aliases
    ll = "grc --colour=auto ls --color=always -alhvF"; # Because ls outputs not directly to stdout, we need to use always
    la = "ls -AF";
    l = "ls -CF";

    # Trivial git aliases
    add = "git add";
    amend-edit = "git commit --amend";
    amend = "git commit --amend --no-edit";
    branch = "git branch";
    checkout = "git checkout";
    cherry-pick = "git cherry-pick";
    clone = "git clone";
    commit = "git commit";
    fetch = "git fetch";
    log-adog = "git log --all --decorate --oneline --graph";
    log-dog = "git log --decorate --oneline --graph";
    merge = "git merge";
    pop = "git stash pop --index";
    pull = "git pull";
    push-u = "git push -u origin HEAD";
    push = "git push";
    rebase = "git rebase";
    reflog = "git reflog";
    restore = "git restore";
    staged = "git diff --staged";
    stash = "git stash push --keep-index --include-untracked";
    status = "git status";
    switch = "git switch";
    # Non-trivial git aliases
    absorb = "git stash push --keep-index && git absorb --and-rebase --base=$(main-branch) && git stash pop"; # Only works if git-absorb is installed
    main = "git switch $(main-branch)";
    main-branch = "git rev-parse --verify main >/dev/null 2>&1 && echo 'main' || echo 'master'";
    # See https://stackoverflow.com/a/6127884/2533467
    del-merged = "git branch --merged | egrep -v '(^*|master|main|develop)' | xargs git branch -d";

    # Better alternative to cp using rsync
    # Shows progress, no need for -r
    # -a: Archive, preserve ownership, permissions, so behaves like cp
    # -x: Single filesystem, don't descend into mounted partitions
    # -h: Make progress human-readable
    # -W: Copy whole files, skips complicated algorithm and saves CPU
    # --info: Show overall progress
    # --no-i-r: Build file list first, makes percentage work properly
    # --no-compress: Skips compression, saves CPU
    "cp+" = "rsync -axhW --info=progress2 --no-inc-recursive --no-compress";

    # Never forget to get progress
    rsync = "rsync --info=progress2";

    # terraform aliases
    tf = "terraform";
    tfswitch = "terraform workspace select";

    # Activate python venv
    activate = "source .venv/bin/activate";
  };

  programs.zsh.initExtra = ''
    # Make sure remote clients aren't confused by kitty
    if [ $TERM = 'xterm-kitty' ]; then
        alias ssh='TERM=xterm-color ssh'
    fi

    mkcd(){
      mkdir $1 && cd $1
    }
  '';

}
