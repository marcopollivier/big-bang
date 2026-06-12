---
description: Re-sincroniza a máquina com o repo (symlinks + Brewfile) e reporta divergências
---
Sincronize ESTA máquina com o repositório:

1. `just link` — reaplica os symlinks (idempotente; faz backup do que for arquivo real).
2. `just doctor` — confira ferramentas no PATH e symlinks resolvidos.
3. `brew bundle check --file=Brewfile` — veja se falta instalar algo do `@Brewfile`.
   Se o usuário instalou algo novo que deveria ser versionado, sugira `just brew-dump`.
4. Reporte qualquer divergência entre a home e o repo (ex.: arquivos que deixaram de
   ser symlink, ou configs editados só localmente).
