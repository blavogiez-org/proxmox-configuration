#!/usr/bin/env python3
import os
import subprocess
import sys
from pathlib import Path

import yaml


repo_dir = Path(__file__).resolve().parents[1]
caller_dir = Path(os.environ.get("CALLER_DIR", repo_dir)).resolve()
config_file = caller_dir / "front_deployment.yml"

front_host = os.environ.get("FRONT_HOST")
front_user = os.environ.get("FRONT_USER")
if not front_host or not front_user:
    sys.exit("FRONT_HOST et FRONT_USER doivent etre definis")

if not config_file.is_file():
    sys.exit(f"Config introuvable: {config_file}")

config = yaml.safe_load(config_file.read_text()) or {}
websites = config.get("websites") or []
if not websites:
    sys.exit(f"Config vide: {config_file}")

for website in websites:
    source_path = website.get("path")
    site_type = website.get("type")
    domains = website.get("domains")
    referenced = website.get("referenced", True)

    if site_type not in {"html", "vite"}:
        sys.exit(f"type invalide pour {source_path}: {site_type}")
    if not source_path:
        sys.exit("path doit etre defini")
    if not isinstance(domains, list) or not domains:
        sys.exit(f"domains doit etre une liste non vide pour {source_path}")
    if not isinstance(referenced, bool):
        sys.exit(f"referenced doit etre true ou false pour {source_path}")

    domains = [domain.strip() for domain in domains if isinstance(domain, str) and domain.strip()]
    if not domains:
        sys.exit(f"domains doit etre une liste non vide pour {source_path}")

    source_dir = caller_dir / source_path
    if not source_dir.is_dir():
        sys.exit(f"Sources introuvables: {source_dir}")

    env = os.environ.copy()
    env["WEBSITE_SOURCE_DIR"] = str(source_dir)
    env["WEBSITE_PRIMARY_DOMAIN"] = domains[0]
    env["WEBSITE_DOMAINS"] = ",".join(domains)
    env["WEBSITE_REFERENCED"] = "true" if referenced else "false"

    portal_status = "avec portail" if referenced else "sans portail"
    print(f"déploiement de {domains[0]} ({site_type}, {portal_status})", flush=True)
    subprocess.run(
        [
            "ansible-playbook",
            "-u",
            front_user,
            "-i",
            f"{front_host},",
            str(repo_dir / f"ansible/playbooks/deploy-{site_type}-website.yml"),
        ],
        check=True,
        env=env,
    )
