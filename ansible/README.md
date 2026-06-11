# Ansible

Motor de provisionamento do projeto para **Linux** (instalação de pacotes e
configuração de ambiente). O entry point é o [`Makefile`](../Makefile) na raiz.

> ⚠️ **Estado atual:** os roles cobrem **Ubuntu / Manjaro / Fedora**. **macOS
> ainda não é suportado pelo Ansible** — no Mac o ambiente é montado manualmente
> com Homebrew + mise + symlinks dos dotfiles (ver README raiz).

## Estrutura

```
ansible/
├── install.yml              # playbook principal (roda o role "environment")
├── vars/
│   └── commons.yml          # flags de instalação + plugins/tema do zsh
└── roles/environment/
    ├── tasks/
    │   ├── main.yml         # orquestra: dirs → cache → basic → tools → dev → science
    │   ├── common/main.yml  # criação de diretórios (workspace, opt, app)
    │   ├── Ubuntu/*.yml      # tasks específicas do Ubuntu
    │   └── ManjaroLinux/*.yml# tasks específicas do Manjaro
    └── templates/
        └── .zshrc.j2        # template do .zshrc gerado no Linux (separado de ../../dotfiles)
```

## Como rodar (Linux)

```sh
make osuser=john.doe gitname=john gitemail=john.doe@email.com
```

O `Makefile` detecta a distro, instala o Ansible (se preciso) e executa o
`install.yml`. As flags em `vars/commons.yml` ligam/desligam grupos de pacotes
(tools, dev, science, etc.).
