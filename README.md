# Big Bang

<!--
Badges generator https://badgesgenerator.com/
Simple Icons https://simpleicons.org/?q=ubuntu
-->

<!-- Supported -->
![macOS](https://img.shields.io/badge/macOS-first-green?labelColor=gray&style=flat&logo=apple&logoColor=white)
![Linux](https://img.shields.io/badge/linux-allowed-green?labelColor=yellow&style=flat&logo=linux&logoColor=white)

<!-- Not supported yet -->
<!-- ![Ububtu](https://img.shields.io/badge/ububtu-not%20supported-red?labelColor=E95420&style=flat&logo=ubuntu&logoColor=white) -->
![Debian](https://img.shields.io/badge/Debian-not%20supported-red?labelColor=A81D33&style=flat&logo=ubuntu&logoColor=white)
![Arch](https://img.shields.io/badge/Arch-not%20supported-red?labelColor=1793D1&style=flat&logo=archLinux&logoColor=white)
![Fedora](https://img.shields.io/badge/Fedora-not%20supported-red?labelColor=51A2DA&style=flat&logo=fedora&logoColor=white)
![OpenSuse](https://img.shields.io/badge/OpenSuse-not%20supported-red?labelColor=73BA25&style=flat&logo=openSuse&logoColor=white)
![Alpine](https://img.shields.io/badge/Alpine-not%20supported-red?labelColor=0D597F&style=flat&logo=alpineLinux&logoColor=white)

![Big Bang Cover](https://p2.trrsf.com/image/fget/cf/460/0/images.terra.com/2018/03/06/o-que-existia-antes-do-big-bang-stephen-hawking-responde.jpg "Big Bang Project Cover")

## Motivation

The **Big Bang** project aims to simplify the setup of development environments.
It is the single source of truth for my machine configuration: dotfiles, editor,
terminal, prompt and provisioning — so a new machine (or a reinstalled tool) can
be brought back to a known state quickly.

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
| [`ansible/`](./ansible) | Provisioning for **Linux** (Ubuntu/Manjaro/Fedora). Entry point is the `Makefile`. |
| [`defaultdots/`](./defaultdots) | Pristine/original dotfiles, kept as a reset reference. |
| [`.legacy/`](./.legacy) | Configs of tools no longer used (e.g. Kitty, iTerm), kept for reference. |

Each folder has its own `README.md` explaining the details.

## Tooling / stack

- **Version manager:** [mise](https://mise.jdx.dev/) — manages Go, Java, Kotlin,
  Node, .NET, Python, etc. (replaced asdf/nvm/pyenv).
- **Packages (macOS):** [Homebrew](https://brew.sh/).
- **Shell:** zsh + oh-my-zsh, **Starship** prompt.
- **Editor:** Neovim (see [`nvim/`](./nvim)).
- **Day-to-day CLIs:** lazygit, lazydocker, fzf, bat, eza, awscli, kubectl,
  opentofu, ansible.

## Configuration and Usage

### macOS (primary)

The environment is assembled manually: install Homebrew + mise, install the
toolchains/CLIs, and symlink the dotfiles. Each folder's README has the exact
steps. In short:

```sh
# Homebrew + mise already installed, then:
ln -sfn "$(pwd)/dotfiles/.zshrc" ~/.zshrc
ln -sfn "$(pwd)/starship/starship.toml" ~/.config/starship.toml
ln -sfn "$(pwd)/nvim" ~/.config/nvim
cp dotfiles/.zshrc.local.example ~/.zshrc.local   # then fill in your secrets
```

> Ansible support for macOS is **not implemented yet**; the steps above are manual.

### Linux

Provisioning is automated with Ansible. A `Makefile` is the entry point:

```sh
make osuser=john.doe gitname=john gitemail=john.doe@email-provider.com
```

See [`ansible/`](./ansible) for details and supported distros.

## Secrets

**No credentials are committed.** Machine-specific values and secrets
(`AWS_*`, `GITHUB_TOKEN`, EKS cluster ARNs, WakaTime API key, …) live in
`~/.zshrc.local`, which is git-ignored. Use
[`dotfiles/.zshrc.local.example`](./dotfiles/.zshrc.local.example) as a template.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
