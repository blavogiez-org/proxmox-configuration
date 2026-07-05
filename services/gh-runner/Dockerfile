# checkov:skip=CKV_DOCKER_3:The entrypoint must start as root to launch the nested Docker daemon.
FROM myoung34/github-runner:ubuntu-noble

RUN python3 -m venv /opt/ansible-venv \
    && /opt/ansible-venv/bin/pip install --no-cache-dir \
        "ansible-core==2.20.7" \
        "hvac==2.4.0"

ENV PATH="/opt/ansible-venv/bin:${PATH}"

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD docker info >/dev/null 2>&1 || exit 1
