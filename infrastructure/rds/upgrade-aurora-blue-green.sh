#!/bin/bash
set -e

SOURCE_CLUSTER="acme-datahub-staging"
DATESTAMP=$(date +%Y%m%d%H%M)
SNAPSHOT_NAME="acme-datahub-cluster-snapshot-before-upgrade-$DATESTAMP"
BLUE_CLUSTER="acme-datahub-staging-blue"
TARGET_ENGINE_VERSION="17.5"
ENGINE="aurora-postgresql"
ENGINE_MODE="provisioned"

echo "==> Creating snapshot: $SNAPSHOT_NAME"
aws rds create-db-cluster-snapshot \
  --db-cluster-identifier "$SOURCE_CLUSTER" \
  --db-cluster-snapshot-identifier "$SNAPSHOT_NAME"

echo "==> Waiting for snapshot to become available..."
aws rds wait db-cluster-snapshot-available \
  --db-cluster-snapshot-identifier "$SNAPSHOT_NAME"

echo "Snapshot '$SNAPSHOT_NAME' is now available."

echo "==> Restoring new upgraded cluster from snapshot..."
aws rds restore-db-cluster-from-snapshot \
  --db-cluster-identifier "$BLUE_CLUSTER" \
  --snapshot-identifier "$SNAPSHOT_NAME" \
  --engine "$ENGINE" \
  --engine-mode "$ENGINE_MODE" \
  --serverless-v2-scaling-configuration MinCapacity=0.5,MaxCapacity=128

echo "==> Waiting for cluster '$BLUE_CLUSTER' to become available..."
aws rds wait db-cluster-available \
  --db-cluster-identifier "$BLUE_CLUSTER"

echo "cluster '$BLUE_CLUSTER' is now available and running..."

echo "==> Upgrading cluster '$BLUE_CLUSTER' to PostgreSQL $TARGET_ENGINE_VERSION..."
aws rds modify-db-cluster \
  --db-cluster-identifier "$BLUE_CLUSTER" \
  --engine-version "$TARGET_ENGINE_VERSION" \
  --allow-major-version-upgrade \
  --apply-immediately


echo "Upgrade complete. Cluster '$BLUE_CLUSTER' is now running PostgreSQL $TARGET_ENGINE_VERSION"
