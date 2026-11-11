---
description: Propõe uma mensagem Conventional Commit a partir do diff staged (não commita)
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Bash(git branch:*)
---
Proponha uma mensagem de commit para o que está **staged** — não rode `git commit`.

1. Veja o que entra: `git diff --staged --stat` e `git diff --staged`. Se não houver
   nada staged, diga isso e pare (sugira `git add -p`).
2. Olhe o estilo do repo em `git log --oneline -15` (idioma, escopos usados, se usa
   corpo) e siga-o.
3. Escreva no formato [Conventional Commits](https://www.conventionalcommits.org/):
   - `tipo(escopo): resumo` — tipo entre `feat`, `fix`, `docs`, `refactor`, `test`,
     `perf`, `build`, `ci`, `chore`; resumo no imperativo, ≤ 72 caracteres, sem ponto.
   - Corpo (opcional) explicando o **porquê** e efeitos colaterais, quebrado em 72 colunas.
   - `BREAKING CHANGE:` no rodapé se mudar contrato público.
4. Se o diff mistura assuntos diferentes, diga e proponha como dividir em commits
   menores (quais arquivos/hunks em cada um).

Entregue só a mensagem num bloco de código, pronta para `git commit -F -`, e no
máximo uma linha de observação.

$ARGUMENTS
