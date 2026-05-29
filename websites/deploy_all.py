#!/usr/bin/env python3
import json
import os
import re
import subprocess
import sys
from pathlib import Path

import yaml


repo_dir = Path(__file__).resolve().parents[1]
caller_dir = Path(os.environ.get("CALLER_DIR", repo_dir)).resolve()
config_file = caller_dir / "domains_deployment.yml"

front_host = os.environ.get("FRONT_HOST")
front_user = os.environ.get("FRONT_USER")
if not front_host or not front_user:
    sys.exit("FRONT_HOST et FRONT_USER doivent etre definis")

caller_repository = os.environ.get("CALLER_REPOSITORY") or f"local/{caller_dir.name}"
caller_repository_slug = re.sub(r"[^A-Za-z0-9_.-]", "_", caller_repository.replace("/", "__")).strip("._-")
if not caller_repository_slug:
    sys.exit("CALLER_REPOSITORY doit permettre de construire un slug non vide")

if not config_file.is_file():
    sys.exit(f"Config introuvable: {config_file}")

config = yaml.safe_load(config_file.read_text()) or {}
if not isinstance(config, dict):
    sys.exit(f"Config invalide: {config_file}")

websites = config.get("websites") or []
if not isinstance(websites, list) or not websites:
    sys.exit(f"Config vide: {config_file}")


def normalize_rate_limit(value, label):
    if value is False:
        return 0
    if isinstance(value, bool) or not isinstance(value, int) or value < 0:
        sys.exit(f"{label} doit etre un entier >= 0 ou false")
    return value


def caddy_token_slug(value):
    slug = re.sub(r"[^A-Za-z0-9_]", "_", value).strip("_")
    return slug or "site"


def fragment_filename(primary_domain):
    name = re.sub(r"[^A-Za-z0-9_.-]", "_", primary_domain).strip("._-")
    if not name:
        sys.exit(f"Impossible de construire un nom de fichier pour {primary_domain}")
    return f"{name}.caddy"


global_rate_limit = normalize_rate_limit(config.get("rate_limit", 0), "rate_limit global")
normalized_websites = []
used_domains = {}

for index, website in enumerate(websites, start=1):
    if not isinstance(website, dict):
        sys.exit(f"website #{index} doit etre un objet")

    source_path = website.get("path")
    site_type = website.get("type")
    domains = website.get("domains")
    referenced = website.get("referenced", True)
    rate_limit = normalize_rate_limit(
        website.get("rate_limit", global_rate_limit),
        f"rate_limit pour {source_path}",
    )

    if site_type not in {"html", "vite"}:
        sys.exit(f"type invalide pour {source_path}: {site_type}")
    if not isinstance(source_path, str) or not source_path.strip():
        sys.exit("path doit etre defini")
    source_path = source_path.strip()
    if not isinstance(domains, list) or not domains:
        sys.exit(f"domains doit etre une liste non vide pour {source_path}")
    if not isinstance(referenced, bool):
        sys.exit(f"referenced doit etre true ou false pour {source_path}")

    domains = [domain.strip() for domain in domains if isinstance(domain, str) and domain.strip()]
    if not domains:
        sys.exit(f"domains doit etre une liste non vide pour {source_path}")

    for domain in domains:
        if "://" in domain or "/" in domain or any(char.isspace() for char in domain):
            sys.exit(f"domaine invalide pour {source_path}: {domain}")
        domain_key = domain.lower()
        if domain_key in used_domains:
            sys.exit(f"domaine declare plusieurs fois: {domain} ({used_domains[domain_key]} et {source_path})")
        used_domains[domain_key] = source_path

    source_dir = (caller_dir / source_path).resolve()
    if caller_dir not in (source_dir, *source_dir.parents):
        sys.exit(f"path doit rester dans le depot appelant: {source_path}")
    if not source_dir.is_dir():
        sys.exit(f"Sources introuvables: {source_dir}")

    primary_domain = domains[0]
    normalized_websites.append(
        {
            "path": source_path,
            "source_dir": str(source_dir),
            "type": site_type,
            "referenced": referenced,
            "domains": domains,
            "primary_domain": primary_domain,
            "rate_limit": rate_limit,
            "rate_limit_zone": caddy_token_slug(primary_domain),
            "caddy_fragment": fragment_filename(primary_domain),
        }
    )

    portal_status = "avec portail" if referenced else "sans portail"
    print(f"déploiement de {domains[0]} ({site_type}, {portal_status})", flush=True)

extra_vars = {
    "infra_dir": str(repo_dir),
    "caller_repository": caller_repository,
    "caller_repository_slug": caller_repository_slug,
    "websites": normalized_websites,
}

subprocess.run(
    [
        "ansible-playbook",
        "-u",
        front_user,
        "-i",
        f"{front_host},",
        str(repo_dir / "ansible/playbooks/deploy-websites.yml"),
        "--extra-vars",
        json.dumps(extra_vars),
    ],
    check=True,
)
