#!/usr/bin/env bash
# .NET: build servers (Roslyn/VBCSCompiler, MSBuild node reuse, Razor) ficam vivos
# depois do build.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=SCRIPTDIR/_common.sh
. "$here/_common.sh"
root="${1:-.}"
has_file "$root" '*.sln' '*.slnx' '*.csproj' '*.fsproj' || exit 0

p="$(pids 'VBCSCompiler|MSBuild.dll.*nodeReuse|rzc.dll')"
[[ -n "$p" ]] && row dotnet build-servers "build servers do .NET rodando (pid $p)" "dotnet build-server shutdown"
exit 0
