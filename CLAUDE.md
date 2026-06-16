# Big Bang — guia para o Claude

Repositório de **dotfiles / configuração de máquina (macOS)**. É a fonte de verdade
do meu ambiente; o setup é feito com [`just`](./justfile) (sem provisionador pesado).

## Estrutura
- `dotfiles/` — dotfiles da home (templates, **sem segredos**)
- `nvim/` — Neovim como IDE (Go/.NET/Kotlin); detalhes em `nvim/SETUP.md`
- `wezterm/`, `starship/`, `mise/` — terminal, prompt e toolchains
- `Brewfile` — pacotes Homebrew · `justfile` — bootstrap/manutenção
- `.github/workflows/ci.yml` — CI (lint + gitleaks)

## Convenções (importante)
- **Nunca commitar segredos.** Credenciais/identidade vivem em `~/.zshrc.local`
  (gitignored); template em `dotfiles/.zshrc.local.example`.
- Configs são **symlinkados** para a home com `just link` (faz backup do que for
  arquivo real). Editar no repo reflete na máquina, e vice-versa.
- Templates com identidade/segredo (`.gitconfig`, `.wakatime.cfg`) são copiados
  **só se não existirem** via `just seed` — nunca sobrescreva-os.
- O Lua de `nvim/` é formatado com `stylua` (o CI checa). Rode `stylua nvim/` antes de commitar.
- **Não dê push direto na `main`.** Trabalhe em branch e abra PR com `just pr` (usa o `gh`).
- **Uma branch por escopo.** Antes de começar qualquer trabalho cujo assunto seja
  diferente do escopo da branch atual, abra uma branch nova a partir da `main`
  atualizada (`git checkout main && git pull && git checkout -b <tipo>/<assunto>`).
  Nunca itere uma tarefa nova numa branch já mergeada ou de outro assunto — se
  perceber que está na branch errada, pare e crie a branch certa antes de editar.

## Setup de máquina nova
Use o comando **`/setup-machine`** (ou deixe a skill *machine-bootstrap* guiar). Em resumo:
`brew install just` → `just bootstrap` → preencher segredos/identidade → `gh auth login`
→ validar com `just doctor`.
