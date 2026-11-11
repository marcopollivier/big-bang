---
name: adr
description: Escreve um Architecture Decision Record (ADR) — contexto, decisão, alternativas consideradas e consequências — em docs/adr/. Use quando o usuário pedir para registrar/documentar uma decisão de arquitetura ou técnica, comparar abordagens para deixar registrado, ou criar um ADR.
---

# ADR — Architecture Decision Record

Registra **uma** decisão técnica com o porquê, para quem chegar depois entender o
que foi escolhido, o que foi descartado e o custo disso.

## Onde e com que nome
1. Use o diretório de ADRs que o projeto já tiver (`docs/adr/`, `docs/decisions/`,
   `adr/`…). Se não houver, crie `docs/adr/`.
2. Numere em sequência a partir do maior existente: `NNNN-titulo-em-kebab-case.md`
   (ex.: `0007-usar-outbox-para-eventos.md`). Primeiro ADR do repo = `0001`.
3. Se o projeto já tem um template de ADR, siga-o em vez do modelo abaixo.

## Antes de escrever
Junte o contexto real: o que motivou a decisão, restrições (prazo, time, custo,
compliance), o que foi avaliado. Se faltar algo essencial (a decisão em si, ou as
alternativas), **pergunte** — não invente justificativa.

## Modelo

```markdown
# NNNN. Título curto da decisão

- Status: proposto | aceito | substituído por [NNNN](NNNN-....md) | descontinuado
- Data: AAAA-MM-DD
- Decisores: (papéis, não nomes, se o repo for público)

## Contexto
O problema e as forças em jogo (requisitos, restrições, riscos). Neutro: ainda
não defende nenhuma opção.

## Decisão
"Vamos ..." — a escolha, em uma ou duas frases, e o escopo dela.

## Alternativas consideradas
### Opção A — ...
Prós / contras / por que não.
### Opção B — ...
...

## Consequências
- Positivas: ...
- Negativas / custos aceitos: ...
- O que precisa acontecer agora (migração, docs, monitoramento).
```

## Regras
- Um ADR por decisão; curto (cabe numa tela ou duas).
- ADR aceito não é reescrito: uma mudança de rumo vira um **novo** ADR que marca o
  antigo como `substituído por`.
- Linke o ADR no PR/issue que motivou a decisão, se houver.
- Escreva no idioma das docs do projeto.
