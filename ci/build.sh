#!/usr/bin/env bash
set -e

# -------------------------
# Configuration
# -------------------------
MAVEN_IMAGE="maven:3.8.3-openjdk-17"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PROJECT_ROOT="$(realpath "$SCRIPT_DIR/..")"
M2_CACHE="$HOME/.m2"

run_maven() {
  docker run --rm -it \
    -v "$PROJECT_ROOT":/project \
    -v "$M2_CACHE":/root/.m2 \
    "$MAVEN_IMAGE" \
    mvn "$@" --file /project
}

# -------------------------
# Argument parsing
# -------------------------
preclean=0
test=0

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --preclean) preclean=1 ;;
    --test) test=1 ;;
    *)
      echo "[e] Unknown parameter: $1"
      exit 1
      ;;
  esac
  shift
done

# -------------------------
# Clean
# -------------------------
if [ $preclean -eq 1 ]; then
  echo "[v] Cleaning project"
  run_maven clean
fi

# -------------------------
# Build (+ tests)
# -------------------------
if [ $test -eq 1 ]; then
  echo "[v] Packaging project (includes tests)"
  run_maven package
else
  echo "[v] Packaging project (skipping tests)"
  run_maven package -DskipTests
fi

echo "[i] Build completed successfully"