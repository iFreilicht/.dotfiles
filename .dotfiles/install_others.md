# Joplin

GUI:
- Go to `https://joplinapp.org/#desktop-applications`
- Click "Get it on Linux"
- Download AppImage to `~/programs`
- Rename it to `joplin-desktop`

Terminal:
- Install nvm first: https://github.com/nvm-sh/nvm#installing-and-updating
- You may have to manually `source .nvm/nvm.sh`
- Check if `command -v nvm` returns `nvm`
- Then, run `nvm install v13.12.0` or whatever the most current version is
- Install joplin: `NPM_CONFIG_PREFIX=~/programs/joplin npm install -g joplin`
