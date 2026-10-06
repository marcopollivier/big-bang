#!/usr/bin/env python3
"""Valida cmux/cmux.json (JSONC) contra o schema oficial do cmux.

O `cmux config validate` só confere a sintaxe; este script pega chave errada,
enum inválido e nome de atalho inexistente antes do merge.

Uso: python3 cmux/validate.py cmux/cmux.json [schema.json]
  - sem o 2º argumento, baixa o schema apontado em "$schema" dentro do arquivo.
Depende de: jsonschema (pip install jsonschema | uv run --with jsonschema ...).
"""
import json
import sys
import urllib.request


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
        with urllib.request.urlopen(url, timeout=30) as r:  # noqa: S310 (URL vem do próprio arquivo)
            schema = json.load(r)

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
