#!/usr/bin/env bash
set -Eeuo pipefail

TARGET_SHA="${1:-}"

if [[ ! "$TARGET_SHA" =~ ^[0-9a-f]{40}$ ]]; then
  echo "ERROR: identificador de commit invalido"
  exit 2
fi

cd /opt/todo-app

PREVIOUS_SHA="$(git rev-parse HEAD)"
LOG="/var/log/pm04-cd.log"
: > "$LOG"

rollback() {
  trap - ERR
  echo "PM04_CD_ERROR: intentando recuperar $PREVIOUS_SHA"

  git reset --hard "$PREVIOUS_SHA" >> "$LOG" 2>&1 || true

  docker compose -f docker-compose.azure.yaml up -d --build \
    >> "$LOG" 2>&1 || true

  tail -n 15 "$LOG" || true
  exit 1
}

trap rollback ERR

echo "Actualizando repositorio..."
git fetch origin main >> "$LOG" 2>&1
git cat-file -e "${TARGET_SHA}^{commit}"
git merge-base --is-ancestor "$TARGET_SHA" origin/main
git reset --hard "$TARGET_SHA" >> "$LOG" 2>&1

echo "Construyendo y desplegando contenedores..."
docker compose -f docker-compose.azure.yaml up -d --build \
  >> "$LOG" 2>&1

echo "Verificando HTTPS y API..."

HEALTHY=false

for i in {1..18}; do
  if curl -fsS --max-time 8 \
    https://20-226-46-100.sslip.io/todos \
    > /dev/null 2>&1; then
    HEALTHY=true
    break
  fi

  sleep 5
done

if [[ "$HEALTHY" != "true" ]]; then
  echo "ERROR: la API no responde correctamente"
  false
fi

echo "PM04_CD_OK $TARGET_SHA"
