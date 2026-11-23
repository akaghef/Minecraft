"""Thin client for the upstream AutoJS Streamable HTTP endpoint."""
import json
import os
import urllib.request


def call(name, arguments=None, url=None):
    endpoint = url or os.environ.get("AUTOJS_URL", "http://127.0.0.1:25585/mcp")
    headers = {"Content-Type": "application/json"}
    if os.environ.get("AUTOJS_TOKEN"):
        headers["Authorization"] = "Bearer " + os.environ["AUTOJS_TOKEN"]
    request = urllib.request.Request(endpoint, json.dumps({
        "jsonrpc": "2.0", "id": 1, "method": "tools/call",
        "params": {"name": name, "arguments": arguments or {}},
    }).encode(), headers=headers)
    with urllib.request.urlopen(request, timeout=30) as response:
        result = json.load(response)
    if "error" in result:
        raise RuntimeError(result["error"])
    envelope = result["result"]
    payload = json.loads(next(c["text"] for c in envelope["content"] if c["type"] == "text"))
    if envelope.get("isError") or payload.get("ok") is False:
        raise RuntimeError(payload)
    if any("ERROR" in str(line) for line in payload.get("diagnostics", [])):
        raise RuntimeError(payload["diagnostics"])
    return payload


def evaluate(code, side="server", url=None):
    return call("eval_js", {"side": side, "code": code}, url)


if __name__ == "__main__":
    import argparse
    from pathlib import Path
    parser = argparse.ArgumentParser(description=__doc__)
    source = parser.add_mutually_exclusive_group()
    source.add_argument("code", nargs="?")
    source.add_argument("--script", type=Path)
    parser.add_argument("--side", default="server", choices=["client", "server"])
    parser.add_argument("--url")
    args = parser.parse_args()
    code = args.script.read_text() if args.script else args.code
    result = evaluate(code, args.side, args.url) if code else call("status", url=args.url)
    print(json.dumps(result, ensure_ascii=False, indent=2))
