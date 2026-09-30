#!/usr/bin/env bash
# Runs tests/*.lua in LandSandBoat's xi_test (a map server with simulated players), against an image.
#
#   tools/test.sh [image]        default ghcr.io/tagban/moghouse-lsb:latest
#
# Needs Docker, and the meshes in volumes (once: docker run --rm -v navmeshes:/navmeshes
# -v ximeshes:/ximeshes ghcr.io/landsandboat/ximeshes:latest). A throwaway database is made for the run
# and removed after it. MogHouse's Lua commands are mounted from this checkout, so a change to one is
# tested without building an image; the C++ modules (knockback) are the image's.
#
# XI_TEST_ARGS adds xi_test's own arguments, e.g. XI_TEST_ARGS="--filter jinx".
set -euo pipefail

here=$(cd "$(dirname "$0")/.." && pwd)
image=${1:-ghcr.io/tagban/moghouse-lsb:latest}
net=moghouse-test-$$
db=moghouse-test-db-$$

cleanup() { docker rm -f "$db" > /dev/null 2>&1 || true; docker network rm "$net" > /dev/null 2>&1 || true; }
trap cleanup EXIT

docker network create "$net" > /dev/null
docker run -d --name "$db" --network "$net" \
    -e MARIADB_DATABASE=xidb -e MARIADB_USER=xiadmin -e MARIADB_PASSWORD=test -e MARIADB_ROOT_PASSWORD=test \
    mariadb:lts --log_bin_trust_function_creators=1 > /dev/null

run() {
    docker run --rm --network "$net" \
        -e XI_NETWORK_SQL_HOST="$db" -e XI_NETWORK_SQL_PORT=3306 -e XI_NETWORK_SQL_DATABASE=xidb \
        -e XI_NETWORK_SQL_LOGIN=xiadmin -e XI_NETWORK_SQL_PASSWORD=test \
        -v navmeshes:/server/navmeshes -v ximeshes:/server/ximeshes \
        -v "$here/modules/moghouse/commands:/server/modules/moghouse/commands:ro" \
        -v "$here/tests:/server/scripts/tests/moghouse:ro" \
        -w /server "$image" "$@"
}

echo "waiting for the database"
for _ in $(seq 1 60); do
    docker exec "$db" mariadb -uxiadmin -ptest xidb -e 'select 1' > /dev/null 2>&1 && break
    sleep 2
done

echo "importing the database (dbtool)"
run python /server/tools/dbtool.py update > /dev/null

echo "testing"
# shellcheck disable=SC2086
run /server/xi_test --keep-going --file moghouse ${XI_TEST_ARGS:-} 2>&1 \
    | grep -E '^\[|^  |Error|lua_print' | grep -vE 'LoadZones|Loading|async tasks|Waiting for async'
