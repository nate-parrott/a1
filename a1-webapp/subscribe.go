package main

import (
	"fmt"
	"net/http"
	"google.golang.org/appengine"
)

func setupSubscribe() {
	http.HandleFunc("/subscribe", subscribe)
}

func subscribe(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	handle := string(r.Form.Get("handle"))
	// userId := string(r.Form.Get("user_id"))

	subscribeOnTwitter(appengine.NewContext(r), handle)

	fmt.Fprintln(w, "ok")
}
