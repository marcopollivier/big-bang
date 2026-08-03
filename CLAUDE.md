# Big Bang — guia para o Claude

Repositório de **dotfiles / configuração de máquina (macOS)**. É a fonte de verdade
do ambiente; o setup é feito com [`just`](./justfile) (sem provisionador pesado).

**Escopo do projeto:** serve para **qualquer ambiente — uso pessoal ou
profissional** — e foi pensado para ser forkado e adaptado. O foco é **macOS**
(*macOS-first*): outros sistemas operacionais podem entrar no futuro, mas **não
são escopo agora** — não adicione suporte a Linux/Windows sem pedido explícito.

## Estrutura
- `dotfiles/` — dotfiles da home (templates, **sem segredos**)
- `nvim/` — Neovim como IDE (Go/.NET/Kotlin); atalhos em `nvim/README.md`,
  histórico/racional em `nvim/SETUP.md`, treino guiado em `nvim/PRACTICE.md`
- `wezterm/`, `starship/`, `mise/` — terminal, prompt e toolchains
- `cmux/` — orquestrador de agentes de IA (terminal via Ghostty embutido); em teste como alternativa ao WezTerm. Detalhes em `cmux/README.md`
- `claude/` — config do Claude Code + acompanhamento de consumo de tokens (statusline + status do mês no WezTerm); detalhes em `claude/README.md`
- `defaultdots/` — dotfiles de fábrica, referência de reset (não são os do dia a dia)
- `.claude/` — skills e slash commands deste repo: `/setup-machine` (configura a
  máquina do zero), `/sync` (re-sincroniza symlinks/Brewfile e reporta divergências)
  e a skill `machine-bootstrap`
- `Brewfile` — pacotes Homebrew · `justfile` — bootstrap/manutenção
- `.github/workflows/ci.yml` — CI (lint + gitleaks)

## Convenções (importante)
- **Nunca commitar segredos.** Credenciais/identidade vivem em `~/.zshrc.local`
  (gitignored); template em `dotfiles/.zshrc.local.example`.
- Configs são **symlinkados** para a home com `just link` (faz backup do que for
  arquivo real). Editar no repo reflete na máquina, e vice-versa.
- Templates com identidade/segredo (`.gitconfig`, `.wakatime.cfg`) são copiados
  **só se não existirem** via `just seed` — nunca sobrescreva-os.
- **Docs bilíngues:** toda mudança em `README.md` deve ser espelhada em
  `README-en.md` (e vice-versa) — mesma estrutura de seções, mesmo conteúdo.
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
→ validar com `just doctor`. Para re-sincronizar uma máquina existente, use **`/sync`**.
