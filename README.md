# Aurora PostgreSQL Blue-Green Upgrade Script

This script performs a blue-green upgrade of the `acme-datahub-staging` Aurora PostgreSQL cluster from its current version to `17.5`.

## Steps
1. Takes a snapshot of the current cluster
2. Restores a new cluster (`acme-datahub-staging-blue`) from the snapshot
3. Upgrades the engine version after restore
4. Waits for the new cluster to be available

## Requirements
- AWS CLI configured with correct permissions
- IAM roles with access to RDS snapshot and restore APIs

## Usage

```bash
./upgrade-aurora-blue-green.sh

