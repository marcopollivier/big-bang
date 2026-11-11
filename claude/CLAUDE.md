# Instruções globais (todas as sessões, todos os projetos)

Versionado em `big-bang/claude/CLAUDE.md` e symlinkado para `~/.claude/CLAUDE.md` pelo
`just link`. Vale para **qualquer** projeto: regra específica de um repo vai no
`CLAUDE.md` dele, que tem prioridade sobre este. Genérico de propósito — sem nada de
empresa, cliente ou identidade (o repo é feito para fork).

## Comunicação
- Responda no idioma em que eu escrevi (normalmente pt-BR). Código, identificadores,
  nomes de commit e mensagens de log seguem a convenção do projeto (em geral, inglês).
- Direto ao ponto: o que mudou, onde (`arquivo:linha`) e o próximo passo. Sem
  resumo repetido do que eu acabei de pedir.
- Se algo falhou ou foi pulado, diga — com o output. Não declare "pronto" sem ter
  rodado o que prova que está pronto.

## Git
- **Uma branch por escopo**, a partir da branch principal atualizada. Nunca commite
  direto na `main`/`master` nem dê push nela; nada de `push --force` (no máximo
  `--force-with-lease` na minha própria branch, e só se eu pedir).
- Commits em [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`), pequenos e coesos.
- Só commite / abra PR quando eu pedir. Não reescreva histórico já publicado.
- **Nunca** commite segredo (token, chave, `.env`, credencial). Se encontrar um
  exposto, pare e me avise para rotacionar.

## Código
- Mudança mínima que resolve o problema; siga os padrões, libs e estilo que o
  projeto já usa antes de introduzir algo novo. Reaproveite antes de reescrever.
- Rode formatter, lint e testes do projeto antes de dar a tarefa por concluída.
  Bug corrigido ganha teste que falhava antes.
- Segurança básica (OWASP): valide input, use queries parametrizadas, menor
  privilégio, nada de segredo hardcoded — use variável de ambiente / secret manager.
- Erros: trate ou propague com contexto; não engula exceção/erro em silêncio.
- Comentário explica o **porquê**, não o quê.

## Stack e ferramentas
- Linguagens principais: **Go**, **.NET/C#** e **Kotlin**. Siga o idioma de cada uma
  (Go: `gofmt`/`goimports`, erros com `%w`, `context` propagado; .NET: async até o fim,
  nullable habilitado; Kotlin: coroutines estruturadas, `ktlint`).
- Toolchains via [`mise`](https://mise.jdx.dev); não instale runtime global com
  brew/sdkman/nvm por fora.
- Containers: **podman** ou **docker**, conforme a máquina — cheque qual existe
  antes de assumir.
- GitHub via `gh`. Prefira o `justfile`/`Makefile` do projeto, quando existir, a
  comandos soltos.
