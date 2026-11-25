---
name: wrap-up
description: Fecha o trabalho no repo atual depois do merge — remove worktrees e branches locais já mergeados (inclusive por squash), volta o checkout principal para a main e aponta o lixo da stack (processos órfãos, daemons do Gradle/Kotlin/.NET, emulador/simulador, containers e imagens). Só apaga o que está provado como mergeado e sempre pede OK antes. Use quando o usuário disser que terminou, que o PR foi mergeado, pedir para limpar worktrees/branches, "wrap up", "fechar o trabalho", ou quando o aviso do SessionStart do wrap-up aparecer.
---

# wrap-up — fechar o trabalho

Limpa o que sobra quando um trabalho termina, **no repo atual**. O trabalho pesado
(e perigoso) é dos scripts testados em `~/.claude/skills/wrap-up/scripts/`; esta
skill orquestra: inventaria, mostra, pergunta e executa item a item.

## 1. Inventário
Rode **do checkout principal** se der (de dentro de um worktree, o próprio worktree
aparece com o processo do Claude rodando nele, e por isso fica em "atenção"):

```bash
git fetch --prune && ~/.claude/skills/wrap-up/scripts/inventory.sh
```

Saída em TSV: `kind  target  status  reason  action`.
- `status`: `ready` (pode limpar), `attention` (não apaga, explique o motivo), `keep`
  (em andamento), `info` (só listar).
- `kind`: `checkout`, `worktree`, `branch`, `remote`, `stash`, `meta`, `stack:<nome>`.
- Uma linha `meta gh` significa que o gh não respondeu: o squash merge não foi
  verificado. Diga isso ao usuário (`gh auth status`); não é motivo para forçar nada.

## 2. Mostrar (curto, em 3 blocos)
1. **Pronto para limpar**: os `ready` de `checkout`/`worktree`/`branch`, com a prova
   (contida na main ou PR #N por squash).
2. **Precisa de atenção**: os `attention`, com o motivo. Depois, numa linha só,
   "N em andamento" (`keep`), sem listar um por um, a menos que o usuário peça.
3. **Stack e máquina**: as linhas `stack:*`, `remote` e `stash`, com o comando sugerido.
   Deixe claro que daemons, emuladores e imagens são da **máquina toda** e podem
   estar em uso por outro projeto.

Se não houver nada `ready` nem `stack:*`, diga que está tudo limpo e pare.

## 3. Perguntar
Uma única `AskUserQuestion` com `multiSelect: true`: os itens `ready` primeiro,
marcados como "(Recommended)", e depois os `stack:*`. No máximo 4 opções, então
agrupe se precisar (ex.: "Todos os N prontos" / "Gradle + Kotlin daemons"). Itens
`attention`, `keep`, `remote` e `stash` **não** viram opção: são só informação.

## 4. Executar, item a item, reportando o output
- `checkout`, `worktree` e `branch`: rode
  `~/.claude/skills/wrap-up/scripts/apply.sh <kind> <target>` (o script revalida
  antes de agir e recusa o que deixou de estar pronto: reporte a recusa, não
  contorne). A ordem é checkout → worktrees → branches.
- `stack:*`: rode o comando da coluna `action`, só os aprovados.
- No fim: `git worktree list` e `git branch -vv`, para mostrar o estado final.

## Regras (não negocie)
- **Nunca** `git worktree remove --force`, `git branch -D` digitado por você,
  `git push --delete`, `git reset`/`git clean` para "destravar" um item. Se algo
  está em `attention`, quem resolve é o usuário.
- Branch remota e stash: **só listar**, com o comando para o usuário rodar (`! …`).
- Nunca mate processo nem pare daemon/emulador/container sem o OK daquele item.
- Não rode `just` nem scripts que gravam na home **de dentro de um worktree**: eles
  usam o caminho do clone atual (`__REPO__`) e apontariam para uma pasta que vai sumir.
- Por que o `apply.sh` pode usar `git branch -D` quando o hook `block-dangerous`
  bloqueia: o bloqueio existe porque o `-D` apaga **sem checar o merge**. O script
  só chega no `-D` depois de **provar** o merge com uma regra mais precisa que a do
  `-d` (ancestral de `origin/<default>`, ou PR mergeado com o mesmo SHA, que é o
  caso do squash). E o `test.sh` cobre "branch não mergeada → nunca apaga".
