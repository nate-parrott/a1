package main

import (
	"fmt"
	"net/http"
	"google.golang.org/appengine"
)

func subscribe(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	if r.Method == "GET" {
		w.Header().Set("Content-Type", "text/html")
		fmt.Fprintln(w, "<form method='POST'>Subscribe to: <input name='handle' placeholder='twitter handle' /> <input type='submit' /></form>")
	} else if r.Method == "POST" {
		handle := string(r.Form.Get("handle"))
		subscribeOnTwitter(appengine.NewContext(r), handle)
		fmt.Fprintln(w, "subscribed to " + handle)
	}
}
