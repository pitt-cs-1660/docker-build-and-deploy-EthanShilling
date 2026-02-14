#!/bin/bash

# usage: ./grade.sh <path-to-student-repo>

BASE_DIR="$1"
SCORE=0
TIMESTAMP=$(date +%s)
IMAGE_NAME="image_$TIMESTAMP"
CONTAINER_NAME="container_$TIMESTAMP"
DOCKERFILE="$BASE_DIR/Dockerfile"

echo "========================================="
echo "  docker assignment grading script"
echo "========================================="
echo ""

# ---- check dockerfile exists at root ----

if [ ! -f "$DOCKERFILE" ]; then
  echo "[FAIL] no Dockerfile found at root of project"
  echo ""
  echo "final score: 0/10"
  exit 1
fi

echo "[INFO] dockerfile found at project root"
echo ""

# ---- static dockerfile checks ----

# collect all FROM lines
FROM_LINES=$(grep -i '^[[:space:]]*FROM' "$DOCKERFILE")
FROM_COUNT=$(echo "$FROM_LINES" | wc -l)
FIRST_FROM=$(echo "$FROM_LINES" | head -1)
LAST_FROM=$(echo "$FROM_LINES" | tail -1)

# check 1: multi-stage build (1 pt)
echo "--- multi-stage build (1 pt) ---"
if [ "$FROM_COUNT" -ge 2 ]; then
  echo "  [PASS] multi-stage build detected ($FROM_COUNT stages)"
  SCORE=$((SCORE + 1))
else
  echo "  [FAIL] not a multi-stage build (only $FROM_COUNT FROM found)"
fi
echo ""

# check 2: first stage uses golang:1.23 (1 pt)
echo "--- build stage uses golang:1.23 (1 pt) ---"
if echo "$FIRST_FROM" | grep -qi 'golang:1\.23'; then
  echo "  [PASS] build stage uses golang:1.23"
  SCORE=$((SCORE + 1))
else
  echo "  [FAIL] build stage does not use golang:1.23"
  echo "  found: $FIRST_FROM"
fi
echo ""

# check 3: final stage uses scratch (1 pt)
echo "--- final stage uses scratch (1 pt) ---"
if echo "$LAST_FROM" | grep -qi 'scratch'; then
  echo "  [PASS] final stage is based on scratch"
  SCORE=$((SCORE + 1))
else
  echo "  [FAIL] final stage is not based on scratch"
  echo "  found: $LAST_FROM"
fi
echo ""

# ---- build and runtime checks ----

REPO_DIR=$(git -C "$(dirname "$DOCKERFILE")" rev-parse --show-toplevel 2>/dev/null || dirname "$DOCKERFILE")
cd "$REPO_DIR" || exit

# check 4: image builds successfully (3 pts)
echo "--- image builds successfully (3 pts) ---"
echo "  building image..."
if docker build -t "$IMAGE_NAME" . > /dev/null 2>&1; then
  echo "  [PASS] image built successfully"
  SCORE=$((SCORE + 3))
else
  echo "  [FAIL] image failed to build"
  echo ""
  echo "========================================="
  echo "  final score: $SCORE/10"
  echo "========================================="
  exit 1
fi
echo ""

# check 5: container runs and serves http 200 (4 pts)
echo "--- container runs and responds (4 pts) ---"
echo "  starting container..."
docker run --rm --name "$CONTAINER_NAME" -d -p 5001:8080 "$IMAGE_NAME" > /dev/null 2>&1
sleep 5

echo "  checking http response..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5001/ | grep -q "200"; then
  echo "  [PASS] received 200 response"
  SCORE=$((SCORE + 4))
else
  echo "  [FAIL] did not receive 200 response"
fi
echo ""

# ---- cleanup ----

echo "cleaning up..."
docker stop "$CONTAINER_NAME" > /dev/null 2>&1
docker rm "$CONTAINER_NAME" > /dev/null 2>&1

echo ""
echo "========================================="
echo "  final score: $SCORE/10"
echo "========================================="

if [ "$SCORE" -lt 10 ]; then
  exit 1
fi
