# Starship

Configuração do [Starship](https://starship.rs/), o prompt do shell.

O arquivo `starship.toml` desta pasta é lido pelo Starship a partir de
`~/.config/starship.toml`. A ativação acontece no `~/.zshrc` (no fim do arquivo):

```sh
command -v starship >/dev/null && eval "$(starship init zsh)"
```

Com o Starship ativo, o tema do oh-my-zsh fica desligado (`ZSH_THEME=""`).

## Instalação (máquina nova)

```sh
brew install starship
ln -sfn "$(pwd)/starship/starship.toml" ~/.config/starship.toml
```
