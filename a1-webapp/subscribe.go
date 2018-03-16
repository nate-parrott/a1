package main

import (
	"fmt"
	"net/http"
)

func subscribe(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "subscribed??")
}
