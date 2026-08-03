# Treino de Neovim — esquentando os motores 🔥

Guia **passo a passo e prático** pra pegar o dia a dia do Neovim com a config
deste repo. Não é teoria: cada lição tem um **objetivo**, os **passos exatos** e
uma **✅ missão** pra você fazer acontecer antes de avançar.

> `<leader>` = **Espaço**. Atalhos completos em [`README.md`](./README.md);
> racional do setup em [`SETUP.md`](./SETUP.md).

## Como treinar
1. Abra um terminal novo e rode **`nvim` dentro de um projeto** (Go sobe o LSP mais rápido — ótimo pra treinar).
2. **Sem mouse e sem setas.** Mão foi pro mouse? Respira e volta pro `hjkl`.
3. Faça **uma lição por sessão**, repita a missão até sair sem pensar. Marque o `[ ]` quando dominar.
4. Meta não é velocidade — é **não precisar pensar**. Devagar e certo.

---

## 🌅 Aquecimento (5 min, todo dia, antes de tudo)
Sempre os mesmos movimentos pra criar memória muscular:
- Mover: `h j k l` · palavra `w b e` · início/fim de linha `0 ^ $` · topo/fim do arquivo `gg G`
- Pular na linha: `f<char>` (vai até o char) · `;` repete · `,` repete pro outro lado
- Desfazer/refazer: `u` / `<C-r>`

✅ **Missão:** numa função real, vá do topo (`gg`) até o fim (`G`) e volte, mexendo só com `hjkl`/`w`/`b`. Use `f(` pra pular pro primeiro parêntese de cada linha.

---

## Lição 1 — Abrir e fechar arquivos
**Objetivo:** entrar e sair de arquivos sem o mouse.

| Ação | Como |
|---|---|
| Buscar e abrir arquivo | `<leader>ff` (ou `<leader><leader>`), digita parte do nome, `<Enter>` |
| Salvar | `<leader>w` |
| Fechar a janela atual | `<leader>q` |
| Sair de tudo | `:qa` (`:qa!` descarta alterações) |

✅ **Missão:** abra 3 arquivos diferentes com `<leader>ff`, salve um com `<leader>w` e feche-o com `<leader>q` — tudo sem tocar no mouse.

---

## Lição 2 — Árvore de arquivos (abrir, fechar, navegar)
**Objetivo:** usar o **neo-tree** como barra lateral de arquivos.

- `<leader>n` → **abre/fecha** a árvore (toggle).
- Dentro da árvore (modo normal):
  - `j`/`k` sobe/desce · `<Enter>` abre o arquivo/pasta
  - `<C-l>` pula pro painel de código · `<C-h>` volta pra árvore
- Pra criar/renomear arquivos pela árvore, veja a **Lição 6**.

✅ **Missão:** abra a árvore com `<leader>n`, navegue até um arquivo em outra pasta, abra-o com `<Enter>`, pule pro código com `<C-l>` e feche a árvore com `<leader>n`.

---

## Lição 3 — Procurar arquivos e texto (Telescope)
**Objetivo:** achar qualquer coisa no projeto em segundos.

| Quero… | Atalho |
|---|---|
| Achar arquivo por nome | `<leader>ff` |
| Procurar um **texto** no projeto (grep) | `<leader>fg` |
| Voltar pra um arquivo já aberto (buffer) | `<leader>fb` |
| Arquivos recentes | `<leader>fr` |
| Procurar a **palavra sob o cursor** | `<leader>fw` |

Dentro do Telescope: `<C-j>`/`<C-k>` desce/sobe na lista, `<Enter>` abre, `<Esc>` fecha.

✅ **Missão:** com `<leader>fg`, procure o texto `func ` (ou `class `), pule pra um resultado, e de lá use `<leader>fw` pra encontrar onde aquela palavra aparece no projeto.

---

## Lição 4 — Dois arquivos lado a lado (splits)
**Objetivo:** trabalhar com painéis um do lado do outro.

| Ação | Como |
|---|---|
| Dividir na vertical (lado a lado) | `:vsplit` (ou `<C-w>v`) |
| Dividir na horizontal (em cima/embaixo) | `:split` (ou `<C-w>s`) |
| Pular entre painéis | `<C-h>` `<C-j>` `<C-k>` `<C-l>` |
| Fechar o painel atual | `<leader>q` |

Truque: abra a árvore (`<leader>n`), posicione o cursor num arquivo e tecle `s` (split vertical no neo-tree) pra abrir já ao lado.

✅ **Missão:** abra um arquivo, faça `:vsplit`, abra **outro** arquivo no painel da direita com `<leader>ff`, e fique pulando entre os dois só com `<C-h>`/`<C-l>`.

---

## Lição 5 — Editar de verdade (o coração do Vim)
**Objetivo:** editar com **verbo + objeto** em vez de apagar caractere por caractere.

- Entrar em insert: `i` (antes) · `a` (depois) · `o` (linha abaixo) · `O` (linha acima) · `<Esc>` sai.
- **Verbo + objeto de texto** (o que mais economiza tempo):
  - `ciw` troca a **palavra** sob o cursor
  - `ci"` / `ci(` / `ci{` troca o que está **dentro** de aspas/parênteses/chaves
  - `diw`, `dd` (linha), `dt,` (apaga até a vírgula)
  - `.` **repete** a última edição (poderosíssimo)
- Mover linhas selecionadas: no **visual** (`V`), use `J`/`K` (atalho deste setup).

✅ **Missão:** pegue uma função, renomeie 3 variáveis com `ciw` (e repita com `.`), troque o conteúdo de uma string com `ci"`, e reordene 2 linhas com `V` + `J`/`K`.

---

## Lição 6 — Criar (e renomear) arquivos
**Objetivo:** criar um arquivo novo do zero, com a mão.

**Pela árvore (neo-tree) — recomendado:**
1. `<leader>n` abre a árvore.
2. Navegue até a pasta onde quer criar.
3. Tecle `a` → digite o nome (ex.: `treino.go`) → `<Enter>`. (`a` com `/` no fim cria pasta.)
4. Outros: `r` renomeia, `d` apaga, `c` copia.

**Pela linha de comando (alternativa):**
- `:e caminho/novo.go` abre/cria o buffer; escreva algo e `<leader>w` salva no disco.

✅ **Missão:** crie `sandbox/treino.go` pela árvore, escreva um `package main` + `func main()` com um `fmt.Println`, e salve com `<leader>w`. (Não precisa commitar — é rascunho.)

---

## Lição 7 — Trabalhar com código (LSP) — vira IDE aqui
**Objetivo:** navegar e corrigir código como numa IDE. Abra um `.go`.

| Ação | Atalho |
|---|---|
| Ir pra definição | `gd` (volta com `<C-o>`) |
| Ver referências / implementações | `gr` / `gI` |
| Documentação (hover) | `K` |
| Renomear símbolo no projeto todo | `<leader>rn` |
| Code action (deixa o LSP corrigir) | `<leader>ca` |
| Formatar (também roda ao salvar) | `<leader>cf` |
| Pular entre erros | `[d` / `]d` · ver o erro: `<leader>e` |
| Símbolos do arquivo (funções) | `<leader>ds` |

✅ **Missão:** apague um import de propósito → pule até o erro com `]d` → veja-o com `<leader>e` → conserte com `<leader>ca`. Depois renomeie uma função com `<leader>rn` e confira com `gr` que mudou em todo lugar.

---

## Lição 8 — Depurar (nvim-dap)
**Objetivo:** rodar passo a passo. Comece num `main.go` simples.

| Ação | Atalho |
|---|---|
| Pôr/tirar breakpoint na linha | `<leader>db` |
| Iniciar / continuar | `<leader>dc` |
| Step over / into / out | `<leader>do` / `<leader>di` / `<leader>dO` |
| Abrir/fechar a UI de debug | `<leader>dt` |

> **C#:** no `<leader>dc` informe a DLL (ex.: `bin/Debug/net10.0/App.dll`) — rode `dotnet build` antes.
> **Kotlin:** informe a `mainClass` (ex.: `MainKt`). Requer projeto Gradle/Maven.

✅ **Missão:** num `main.go`, ponha um breakpoint com `<leader>db` numa linha dentro de um loop, inicie com `<leader>dc`, avance com `<leader>do` e veja as variáveis na UI (`<leader>dt`).

---

## 📅 Progressão sugerida (2 semanas)
- **Dias 1–3:** rode `vimtutor` (25 min, no terminal) + Aquecimento + Lições 1–2.
- **Dias 4–6:** Lições 3–4 (buscar + splits) num projeto real.
- **Dias 7–9:** Lição 5 (editar) — e aqui **passe a usar o nvim no dia a dia**, mesmo lento.
- **Dias 10–12:** Lições 6–7 (criar + LSP).
- **Dias 13–14:** Lição 8 (debug) + revisão geral.

## 🏁 Checklist "já domino"
- [ ] Abro/fecho/salvo arquivos sem mouse (Lição 1)
- [ ] Abro e navego na árvore (Lição 2)
- [ ] Acho arquivo e texto com Telescope (Lição 3)
- [ ] Trabalho com dois painéis lado a lado (Lição 4)
- [ ] Edito com `ciw`/`ci"`/`.` e movo linhas com `J`/`K` (Lição 5)
- [ ] Crio arquivos pela árvore (Lição 6)
- [ ] Navego e corrijo com LSP: `gd`/`gr`/`<leader>rn`/`<leader>ca` (Lição 7)
- [ ] Coloco breakpoint e dou step no debug (Lição 8)
