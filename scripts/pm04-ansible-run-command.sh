#!/usr/bin/env bash
set -Eeuo pipefail

TARGET_SHA="$1"
DEMO_TAG="$2"
EXTRA_PACKAGE="$3"
UPDATE_OS="$4"

[[ "$TARGET_SHA" =~ ^[0-9a-f]{40}$ ]] || { echo "SHA invalido"; exit 2; }
[[ "$DEMO_TAG" == "alpine" || "$DEMO_TAG" == "stable-alpine" ]] || { echo "Tag invalida"; exit 2; }
[[ "$EXTRA_PACKAGE" == "jq" || "$EXTRA_PACKAGE" == "unzip" || "$EXTRA_PACKAGE" == "git" ]] || { echo "Pacote invalido"; exit 2; }
[[ "$UPDATE_OS" == "true" || "$UPDATE_OS" == "false" ]] || { echo "Parametro SO invalido"; exit 2; }

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "Instalando Ansible no host..."
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ansible
fi

TMP="$(mktemp -d /tmp/pm04-integrado.XXXXXXXX)"
trap 'rm -rf "$TMP"' EXIT
git clone -q --depth 1 --branch main https://github.com/marcelonv011/todo-app.git "$TMP/repo"
CURRENT_SHA="$(git -C "$TMP/repo" rev-parse HEAD)"
if [[ "$CURRENT_SHA" != "$TARGET_SHA" ]]; then
  echo "O commit remoto mudou durante a execucao. Cancelando por seguranca."
  exit 3
fi

cd "$TMP/repo/ansible"
ansible-playbook -i 'localhost,' -c local maintenance.yml \
  -e "maintenance_tag=$DEMO_TAG" \
  -e "maintenance_package=$EXTRA_PACKAGE" \
  -e "update_os=$UPDATE_OS"

echo "PM04_ANSIBLE_OK $CURRENT_SHA"
