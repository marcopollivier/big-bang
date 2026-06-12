# Big Bang

<!--
Badges generator https://badgesgenerator.com/
Simple Icons https://simpleicons.org/?q=ubuntu
-->

![macOS](https://img.shields.io/badge/macOS-first-green?labelColor=gray&style=flat&logo=apple&logoColor=white)

![Big Bang Cover](https://p2.trrsf.com/image/fget/cf/460/0/images.terra.com/2018/03/06/o-que-existia-antes-do-big-bang-stephen-hawking-responde.jpg "Big Bang Project Cover")

## Motivation

The **Big Bang** project is my single source of truth for machine configuration:
dotfiles, editor, terminal and prompt. The goal is **convenience** — when I set
up a new machine or reinstall a tool, I come here to remember how my environment
is put together and to copy/symlink the configs back into place.

> This is a curated reference / dotfiles repository, **not** an automated
> provisioning script. Setup is done manually (and intentionally so).

## Target Audience

This project is designed for everyone. Whether for personal or professional use,
you are welcome to fork and adapt it as needed.

## Repository structure

| Folder | What lives here |
|---|---|
| [`dotfiles/`](./dotfiles) | Home dotfiles (`.zshrc`, `.gitconfig`, `.wakatime.cfg`, AWS/Clojure/OpenTofu configs…). Templates with **no secrets** committed. |
| [`nvim/`](./nvim) | Neovim configured as an IDE for **Go, .NET/C# and Kotlin** (lazy.nvim, LSP via Mason, Claude Code + WakaTime). See its [`SETUP.md`](./nvim/SETUP.md). |
| [`wezterm/`](./wezterm) | [WezTerm](https://wezfurlong.org/wezterm/) terminal configuration. |
| [`starship/`](./starship) | [Starship](https://starship.rs/) shell prompt configuration. |
| [`defaultdots/`](./defaultdots) | Pristine/original dotfiles, kept as a reset reference. |

Each folder has its own `README.md` explaining the details.

## Tooling / stack

- **Version manager:** [mise](https://mise.jdx.dev/) — manages Go, Java, Kotlin,
  Node, .NET, Python, etc. (replaced asdf/nvm/pyenv).
- **Packages:** [Homebrew](https://brew.sh/).
- **Shell:** zsh + oh-my-zsh, **Starship** prompt.
- **Editor:** Neovim (see [`nvim/`](./nvim)).
- **Day-to-day CLIs:** lazygit, lazydocker, fzf, bat, eza, awscli, kubectl, opentofu.

## Setup (new machine)

Install Homebrew + mise, install the toolchains/CLIs, then symlink the configs.
Each folder's README has the exact steps. In short:

```sh
# With Homebrew + mise already installed:
ln -sfn "$(pwd)/dotfiles/.zshrc" ~/.zshrc
ln -sfn "$(pwd)/starship/starship.toml" ~/.config/starship.toml
ln -sfn "$(pwd)/nvim" ~/.config/nvim
cp dotfiles/.zshrc.local.example ~/.zshrc.local   # then fill in your secrets
```

## Secrets

**No credentials are committed.** Machine-specific values and secrets
(`AWS_*`, `GITHUB_TOKEN`, EKS cluster ARNs, WakaTime API key, …) live in
`~/.zshrc.local`, which is git-ignored. Use
[`dotfiles/.zshrc.local.example`](./dotfiles/.zshrc.local.example) as a template.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
