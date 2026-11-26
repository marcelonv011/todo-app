#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

ARCHIVE="${1:?Falta ruta del backup}"

if [[ ! -s "$ARCHIVE" ]]; then
  echo "ERROR: backup inexistente o vacio"
  exit 1
fi

gzip -t "$ARCHIVE"

echo "Restaurando en base de prueba..."

docker exec -i todo-mongo sh -eu -c '
  umask 077
  CONF=$(mktemp)
  trap "rm -f \"$CONF\"" EXIT

  printf "password: \"%s\"\n" \
    "$MONGO_INITDB_ROOT_PASSWORD" > "$CONF"

  mongorestore \
    --host 127.0.0.1 \
    --username "$MONGO_INITDB_ROOT_USERNAME" \
    --authenticationDatabase admin \
    --config "$CONF" \
    --archive \
    --gzip \
    --nsFrom "todo-app.*" \
    --nsTo "todo-app-restore-test.*" \
    --stopOnError
' < "$ARCHIVE"

docker exec todo-mongo mongosh --quiet --eval '
  const auth = db.getSiblingDB("admin").auth(
    process.env.MONGO_INITDB_ROOT_USERNAME,
    process.env.MONGO_INITDB_ROOT_PASSWORD
  );

  if (!auth || auth.ok !== 1) {
    print("ERROR: autenticacion");
    quit(2);
  }

  const total = db.getSiblingDB("todo-app-restore-test")
    .getCollection("todos").countDocuments({});

  if (total < 1) {
    print("ERROR: no se restauraron documentos");
    quit(3);
  }

  print("PM04_RESTORE_TEST_OK documentos=" + total);
'
