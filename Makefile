# sert à centraliser les commandes récurrentes et définir une convention courante (qu'on utilise de notre côté ou en CI)
TF_DIR := terraform/environments/production
ANSIBLE_INVENTORIES := ansible/inventories

ANSIBLE_INVENTORY := ansible/inventories/inventory.yml
VAULT_MOUNT ?= secret
VAULT_PATH ?= settings.yml
VAULT_KEY ?= RANDOMVAL

# qq exemples : 
# make tf TF_LAYER=core ACTION=plan
# make tf-apply TF_LAYER=bootstrap
# make tf-apply # en defaut il fera sur la couche terraform core
# make deploy-compose SERVICE=monitoring

lint-checkov: 
	docker run --rm -v "$${PWD}:/repo" bridgecrew/checkov:2 -d /repo --quiet

lint-tflint:
	docker run --rm -v "$${PWD}:/repo" -w /repo ghcr.io/terraform-linters/tflint:latest --recursive


# défaut
TF_LAYER ?=core
tf: 
	cd $(TF_DIR)/$(TF_LAYER) && \
	. ./remote-backend-init.sh && \
	terraform $(ACTION)

tf-init: 
	$(MAKE) tf $(TF_LAYER) ACTION=init

tf-plan: 
	$(MAKE) tf $(TF_LAYER) ACTION=plan

tf-apply: 
	$(MAKE) tf $(TF_LAYER) ACTION=apply

tf-destroy: 
	$(MAKE) tf $(TF_LAYER) ACTION=destroy

deploy-compose-ci:
	ANSIBLE_STRICT_HOST_KEY_CHECKING=false \
	ansible-playbook ansible/playbooks/deploy_any_compose.yml \
	-e '{"host":"$(SERVICE)","target_service":"$(SERVICE)","ansible_become_flags":"-H -S -n","ansible_become_password":null}' \
	-i $(ANSIBLE_INVENTORY) $(EXTRA_ARGS)

deploy-compose:
	$(MAKE) deploy-compose-ci


deploy-alloy:
	ANSIBLE_STRICT_HOST_KEY_CHECKING=false ansible-playbook ansible/playbooks/install_alloy.yml -i $(ANSIBLE_INVENTORY) $(EXTRA_ARGS)

deploy-lxc: 
	ANSIBLE_STRICT_HOST_KEY_CHECKING=false ansible-playbook ansible/playbooks/bootstrap.yml -i $(ANSIBLE_INVENTORIES)/lxc_inventory.yml $(EXTRA_ARGS)

input-vault:
	@if bao kv get -mount=$(VAULT_MOUNT) $(VAULT_PATH) >/dev/null 2>&1; then \
		bao kv patch -mount=$(VAULT_MOUNT) $(VAULT_PATH) $(VAULT_KEY)="$(VAULT_VALUE)"; \
	else \
		bao kv put -mount=$(VAULT_MOUNT) $(VAULT_PATH) $(VAULT_KEY)="$(VAULT_VALUE)"; \
	fi

input-random-vault:
	$(MAKE) input-vault VAULT_MOUNT="$(VAULT_MOUNT)" VAULT_PATH="$(VAULT_PATH)" VAULT_KEY="$(VAULT_KEY)" VAULT_VALUE="$$(openssl rand -hex 32)"

read-vault:
	bao kv get -mount=$(VAULT_MOUNT) $(VAULT_PATH)
