#!/bin/sh
# Fargate Task 의 entrypoint. ECS secrets 로 주입된 DB 컴포넌트를 받아
# DATABASE_URL 을 조립하고 golang-migrate 를 호출한다.
#
# 사용:
#   docker run ... run-migrate.sh up
#   docker run ... run-migrate.sh version
#   ECS Task command 로 override 가능 ([] 면 Dockerfile CMD = "up" 사용)
set -eu

: "${DB_USER:?DB_USER missing}"
: "${DB_PASSWORD:?DB_PASSWORD missing}"
: "${DB_HOST:?DB_HOST missing}"
: "${DB_PORT:?DB_PORT missing}"
: "${DB_NAME:?DB_NAME missing}"

# 비밀번호 특수문자 대응을 위한 URL-encode (jq @uri)
ENC_PASS=$(printf '%s' "$DB_PASSWORD" | jq -sRr @uri)

DATABASE_URL="postgres://${DB_USER}:${ENC_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=require"

echo "▶ migrate $* (db=$DB_NAME host=$DB_HOST)"
echo "=== version BEFORE ==="
migrate -path /migrations -database "$DATABASE_URL" version 2>&1 || true

exec migrate -path /migrations -database "$DATABASE_URL" "$@"
