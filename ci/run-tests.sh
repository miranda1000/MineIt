#!/usr/bin/env bash
set -e

MAVEN_IMAGE="maven:3.8.3-openjdk-17"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PROJECT_ROOT="$(realpath "$SCRIPT_DIR/..")"
M2_CACHE="$HOME/.m2"

cd "$PROJECT_ROOT"

run_maven() {
  docker run --rm -it \
    --network host \
    -v "$PROJECT_ROOT":/project \
    -v "$M2_CACHE":/root/.m2 \
    "$MAVEN_IMAGE" \
    mvn "$@" --file /project
}

# No args → all unit tests (standard Surefire behavior)
# If you'd like to run specific test, use the following convention:
# <class name>
# or
# <class name>#<test method>
if [ $# -eq 0 ]; then
  echo "▶ Running all unit tests"
  run_maven test
  exit 0
fi

ARG="$1"

# Single method
if [[ "$ARG" == *"#"* ]]; then
  echo "▶ Running test method: $ARG"
  run_maven test -Dtest="$ARG"
  exit 0
fi

# Whole test class (must already match Maven naming conventions)
echo "▶ Running test class: $ARG"
run_maven test -Dtest="$ARG"
