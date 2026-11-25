#!/usr/bin/env python3
"""Valida cmux/cmux.json (JSONC) contra o schema oficial do cmux.

O `cmux config validate` só confere a sintaxe; este script pega chave errada,
enum inválido e nome de atalho inexistente antes do merge.

Uso: python3 cmux/validate.py cmux/cmux.json [schema.json]
  - sem o 2º argumento, baixa o schema apontado em "$schema" dentro do arquivo.
  - com GITHUB_TOKEN no ambiente (o CI passa), o download do raw.githubusercontent.com
    vai autenticado: anônimo, o IP compartilhado dos runners leva HTTP 429.
Depende de: jsonschema (pip install jsonschema | uv run --with jsonschema ...).
"""
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

# O token só vai para estes hosts: a URL vem do arquivo, e não pode virar um jeito
# de mandar o token para um servidor qualquer.
TOKEN_HOSTS = {"raw.githubusercontent.com"}
RETRY_STATUS = {429, 500, 502, 503, 504}


def fetch_schema(url: str, attempts: int = 4) -> dict:
    """Baixa o schema; 429/5xx/erro de rede ganham nova tentativa com espera crescente."""
    req = urllib.request.Request(url)
    parts = urllib.parse.urlsplit(url)
    token = os.environ.get("GITHUB_TOKEN")
    if token and parts.scheme == "https" and parts.hostname in TOKEN_HOSTS:
        req.add_header("Authorization", f"Bearer {token}")
    for attempt in range(1, attempts + 1):
        try:
            with urllib.request.urlopen(req, timeout=30) as r:  # noqa: S310 (URL vem do próprio arquivo)
                return json.load(r)
        except urllib.error.HTTPError as e:
            if e.code not in RETRY_STATUS or attempt == attempts:
                raise
            ra = (e.headers.get("Retry-After") or "").strip()
            wait = min(int(ra), 60) if ra.isdigit() else 2**attempt
            why = f"HTTP {e.code}"
        except urllib.error.URLError as e:
            if attempt == attempts:
                raise
            wait, why = 2**attempt, str(e.reason)
        print(f"warn schema: tentativa {attempt}/{attempts} falhou ({why}); nova em {wait}s", file=sys.stderr)
        time.sleep(wait)
    raise AssertionError("unreachable")


def strip_jsonc(text: str) -> str:
    """Remove comentários // e /* */ fora de strings (URLs dentro de strings ficam)."""
    out, i, n = [], 0, len(text)
    in_str = False
    while i < n:
        c = text[i]
        if in_str:
            out.append(c)
            if c == "\\" and i + 1 < n:
                out.append(text[i + 1])
                i += 1
            elif c == '"':
                in_str = False
        elif c == '"':
            in_str = True
            out.append(c)
        elif text.startswith("//", i):
            while i < n and text[i] != "\n":
                i += 1
            continue
        elif text.startswith("/*", i):
            end = text.find("*/", i + 2)
            i = n if end == -1 else end + 2
            continue
        else:
            out.append(c)
        i += 1
    return "".join(out)


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    path = sys.argv[1]
    with open(path, encoding="utf-8") as f:
        raw = f.read()
    try:
        data = json.loads(strip_jsonc(raw))
    except json.JSONDecodeError as e:
        print(f"FAIL {path}: JSON inválido após remover comentários: {e}")
        return 1

    if len(sys.argv) > 2:
        with open(sys.argv[2], encoding="utf-8") as f:
            schema = json.load(f)
    else:
        url = data.get("$schema")
        if not url:
            print(f"FAIL {path}: sem \"$schema\" e nenhum schema local informado")
            return 1
        try:
            schema = fetch_schema(url)
        except (urllib.error.URLError, json.JSONDecodeError) as e:
            print(f"FAIL {path}: não consegui baixar o schema {url}: {e}")
            return 1

    try:
        import jsonschema
    except ImportError:
        print("FAIL: módulo jsonschema ausente (pip install jsonschema)")
        return 2

    validator = jsonschema.Draft202012Validator(schema)
    errors = sorted(validator.iter_errors(data), key=lambda e: list(e.absolute_path))
    if errors:
        for e in errors:
            where = "/".join(str(p) for p in e.absolute_path) or "<raiz>"
            msg = e.message if len(e.message) <= 300 else e.message[:300] + " …"
            print(f"FAIL {path} @ {where}: {msg}")
        return 1
    print(f"ok   {path} válido contra o schema ({len(data)} chaves de topo)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
