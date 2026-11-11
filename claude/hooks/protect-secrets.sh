#!/usr/bin/env bash
# PreToolUse (Read|Edit|Write|MultiEdit|NotebookEdit) — impede que arquivos de
# segredo entrem no contexto do Claude ou sejam alterados por ele.
#
# exit 2 = bloqueia (o stderr volta para o Claude como motivo). Modelos/exemplos
# (.env.example, *.pub, *.example) passam. Testes: claude/hooks/test.sh
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0
input="$(cat)"
path="$(jq -r '.tool_input.file_path // .tool_input.notebook_path // .tool_input.path // empty' <<<"$input")"
cwd="$(jq -r '.cwd // empty' <<<"$input")"
[[ -z "$path" ]] && exit 0

path="${path/#\~/$HOME}"
[[ "$path" != /* ]] && path="${cwd:-$PWD}/$path"
base="${path##*/}"

block() {
  printf 'BLOQUEADO pelo hook protect-secrets: %s é arquivo de segredo (%s).\n' "$path" "$1" >&2
  printf 'Trabalhe no modelo versionado (ex.: .env.example, dotfiles/*.example) ou peça ao usuário o valor que precisa — sem colar o segredo.\n' >&2
  exit 2
}

# Modelos e chaves públicas são liberados
case "$base" in
*.example | *.sample | *.template | *.dist | *.pub) exit 0 ;;
esac

# Caminhos exatos / diretórios da home
H="$HOME"
case "$path" in
"$H/.ssh/"*) block "diretório ~/.ssh" ;;
"$H/.gnupg/"*) block "chaves GPG" ;;
"$H/.aws/credentials") block "credenciais da AWS" ;;
"$H/.zshrc.local") block "segredos do shell (~/.zshrc.local)" ;;
"$H/.npmrc") block "token do npm" ;;
"$H/.netrc" | "$H/.git-credentials") block "credenciais de HTTP/git" ;;
"$H/.wakatime.cfg") block "API key do WakaTime" ;;
"$H/.docker/config.json" | "$H/.kube/config" | "$H/.kube/"*.yaml) block "credenciais de container/cluster" ;;
esac

# Por nome de arquivo, em qualquer lugar
case "$base" in
.env | .env.*) block "variáveis de ambiente (.env)" ;;
*.pem | *.key | *.p12 | *.pfx | *.jks | *.keystore) block "chave/certificado privado" ;;
id_rsa | id_dsa | id_ecdsa | id_ed25519 | id_ecdsa_sk | id_ed25519_sk) block "chave privada SSH" ;;
.pgpass | .my.cnf | credentials.json | service-account*.json) block "credenciais" ;;
esac

exit 0
