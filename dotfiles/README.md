# Dotfiles

Arquivos de configuração ("dotfiles") da home. São **templates com campos em
branco** — nenhuma credencial é versionada. Segredos e valores específicos da
máquina ficam em `~/.zshrc.local` (não versionado).

## Arquivos

| Arquivo | O que é |
|---|---|
| `.zshrc` | Config principal do zsh: oh-my-zsh, ativação do **mise** e do **fzf**, prompt **starship**, aliases (`vim`→nvim, `ls`→eza, `cat`→bat…), histórico, e funções `k8s-p`/`k8s-h`. Editor padrão = `nvim`. |
| `.zshrc.local.example` | Modelo do `~/.zshrc.local` (segredos/config por máquina): `AWS_*`, `GITHUB_TOKEN`, `EKS_PRD_ARN`, `EKS_HML_ARN`. Copie para `~/.zshrc.local` e preencha. |
| `.gitconfig` | Config do git: assinatura GPG, rewrite de URL para SSH, alias `clone-token`, LFS, branch padrão `main`. Nome/email/chave ficam em branco. |
| `.gitignore.global` | `.gitignore` global (referenciado por `core.excludesFile`). |
| `.aws/config` | Config do AWS CLI (apenas região; sem credenciais). |
| `.clojure/deps.edn` | Aliases globais do Clojure CLI. |
| `.opentofurc` | Config do OpenTofu (network mirror de providers via SSH). |
| `.wakatime.cfg` | Config do WakaTime (tracking de tempo). `api_key` em branco — a chave real vai na máquina, não no repo. |

## Como instalar (máquina nova)

A forma recomendada é o bootstrap do repo (ver [README raiz](../README.md)), que
symlinka os configs compartilhados e faz o *seed* dos templates com segredo
(`.gitconfig`, `.wakatime.cfg`, `~/.zshrc.local`) **só se não existirem**:

```sh
just link    # symlinka .zshrc, .gitignore.global, .opentofurc (+ starship, nvim, mise)
just seed    # copia os templates de identidade/segredo, se faltarem
# ou, de uma vez:  just bootstrap
```

Fallback manual (equivalente, sem o `just`):

```sh
ln -sfn "$(pwd)/dotfiles/.zshrc" ~/.zshrc
cp dotfiles/.zshrc.local.example ~/.zshrc.local   # depois preencha os segredos
```

> Numa máquina já configurada, `~/.zshrc` é symlink para este arquivo.
