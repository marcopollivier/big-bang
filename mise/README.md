# mise

Configuração global do [mise](https://mise.jdx.dev/) — o gerenciador de versões
de linguagens (substitui asdf/nvm/pyenv).

O arquivo [`config.toml`](./config.toml) lista os toolchains instalados em toda
máquina. Ele é linkado para `~/.config/mise/config.toml` (pelo `just link`), e a
ativação acontece no [`../dotfiles/.zshrc`](../dotfiles/.zshrc):

```sh
command -v mise >/dev/null && eval "$(mise activate zsh)"
```

## Uso

```sh
mise install            # instala/atualiza os toolchains do config.toml (ou: just mise-install)
mise use -g go@latest   # adiciona/fixa uma ferramenta (edita o config.toml)
mise ls                 # lista o que está instalado
```

Toolchains atuais: **Go, Java (Temurin 21), Kotlin, Node (LTS), .NET**.
