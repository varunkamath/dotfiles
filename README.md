Run:

fish_add_path /opt/homebrew/bin
chsh -s /opt/homebrew/bin/fish

echo "/opt/homebrew/bin/fish" | sudo tee -a /etc/shells
fish_config and set theme to base16 default dark

iTerm2 theme is SleepyHollow
mkdir -p ~/.config/fish/completions
cp docker.fish ~/.config/fish/completions

fish_update_completions

![alt text](https://i.imgur.com/nhuKLPg.png)
