---
description: Configura ESTA máquina (macOS) do zero a partir do repo — bootstrap, segredos e validação
---
Prepare ESTA máquina usando este repositório como fonte de verdade, seguindo a
skill **machine-bootstrap**. Confirme cada passo destrutivo antes de executar e
**não invente segredos** — peça os valores ao usuário.

Resumo do fluxo (a skill tem o detalhe):

1. Garanta Homebrew e `just` (`brew install just`); instale o Homebrew se faltar.
2. `just bootstrap` — instala o `@Brewfile`, symlinka os configs (com backup),
   confia e instala as toolchains do `mise` (`mise trust` + `mise install`) e faz o *seed* dos templates.
3. Identidade/segredos: git `user.name/email/signingkey`; `~/.zshrc.local`
   (ver `@dotfiles/.zshrc.local.example`); WakaTime via `:WakaTimeApiKey` no nvim.
4. `gh auth login` é interativo — peça ao usuário rodar `! gh auth login --git-protocol ssh --web`.
5. Valide com `just doctor`, abra o `nvim` pra disparar plugins/LSP e confira o starship numa shell nova.
6. Resuma o que ficou pronto e o que ainda depende do usuário.
