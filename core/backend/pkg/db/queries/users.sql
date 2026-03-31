-- name: GetUser :one
SELECT * FROM users
WHERE id = $1 LIMIT 1;

-- name: GetUserByUsername :one
SELECT * FROM users
WHERE username = $1 LIMIT 1;

-- name: CreateUser :one
INSERT INTO users (
  username, password_hash, role
) VALUES (
  $1, $2, $3
)
RETURNING *;

-- name: ListUsers :many
SELECT * FROM users
ORDER BY id;

-- name: UpdateUserRole :exec
UPDATE users
set role = $2,
    updated_at = CURRENT_TIMESTAMP
WHERE id = $1;

-- name: DeleteUser :exec
DELETE FROM users
WHERE id = $1;
