#!/usr/bin/env bash
# JVM (Gradle/Maven/Kotlin): daemons que ficam vivos depois do build, segurando RAM.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=SCRIPTDIR/_common.sh
. "$here/_common.sh"
root="${1:-.}"
has_file "$root" 'build.gradle' 'build.gradle.kts' 'settings.gradle*' 'pom.xml' || exit 0

p="$(pids 'org.gradle.launcher.daemon')"
if [[ -n "$p" ]]; then
  # o --stop do wrapper só para daemons da MESMA versão do Gradle; pkill pega todos
  if [[ -x "$root/gradlew" ]]; then cmd="(cd $root && ./gradlew --stop)"; else cmd="pkill -f org.gradle.launcher.daemon"; fi
  row jvm gradle-daemon "GradleDaemon rodando (pid $p; pode ser de outro projeto)" "$cmd"
fi
p="$(pids 'KotlinCompileDaemon')"
[[ -n "$p" ]] && row jvm kotlin-daemon "KotlinCompileDaemon rodando (pid $p)" "pkill -f KotlinCompileDaemon"
p="$(pids 'MavenDaemon|mvnd')"
[[ -n "$p" ]] && row jvm mvnd "Maven daemon (mvnd) rodando (pid $p)" "mvnd --stop"
exit 0
