-- name: CreateAsset :one
INSERT INTO assets (
    hostname,
    ip_address,
    port,
    status
) VALUES (
    $1, $2, $3, $4
) RETURNING *;

-- name: GetAsset :one
SELECT * FROM assets WHERE id = $1;

-- name: ListAssets :many
SELECT * FROM assets ORDER BY created_at DESC;

-- name: UpdateAssetStatus :exec
UPDATE assets SET status = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $1;

-- name: DeleteAsset :exec
DELETE FROM assets WHERE id = $1;

-- name: CreateContainer :one
INSERT INTO containers (
    asset_id,
    docker_container_id,
    name,
    image,
    state
) VALUES (
    $1, $2, $3, $4, $5
) RETURNING *;

-- name: ListContainersByAsset :many
SELECT * FROM containers WHERE asset_id = $1 ORDER BY created_at DESC;

-- name: GetContainerByDockerID :one
SELECT * FROM containers WHERE docker_container_id = $1;

-- name: UpdateContainerState :exec
UPDATE containers SET state = $2 WHERE id = $1;

-- name: DeleteContainer :exec
DELETE FROM containers WHERE id = $1;
