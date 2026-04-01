
package main
import (
    "database/sql"
    "fmt"
    _ "github.com/lib/pq"
)
func main() {
    db, err := sql.Open("postgres", "postgres://re_user:re_password@127.0.0.1:5432/re_db?sslmode=disable")
    if err != nil { fmt.Println("Open err:", err); return }
    err = db.Ping()
    if err != nil { fmt.Println("Ping err:", err); return }
    fmt.Println("Success!")
}
