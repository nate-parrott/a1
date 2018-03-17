package main

import (
	"net/http"
	"html/template"
	"google.golang.org/appengine/log"
	"google.golang.org/appengine"
	"fmt"
	"encoding/json"
	"strings"
	"github.com/davecgh/go-spew/spew"
)

var tpl = template.Must(template.ParseGlob("html/*.html"))

func setupAdminDashboard() {
	http.HandleFunc("/admin", adminDashboard)
	http.HandleFunc("/admin/test_fetch_task", fetchTaskTest)
	http.HandleFunc("/admin/test_source_fetch", testSourceFetch)
	http.HandleFunc("/admin/restart_fetch_tasks", restartFetchTasks)
	http.HandleFunc("/admin/test_mercury", testMercury)
	http.HandleFunc("/admin/test_amp", testAmp)
}

func adminDashboard(w http.ResponseWriter, r *http.Request) {
	ctx := appengine.NewContext(r)
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := tpl.ExecuteTemplate(w, "admin.html", struct{}{}); err != nil {
		log.Errorf(ctx, "%v", err)
	}
}

func testSourceFetch(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	handle := r.Form.Get("handle")
	// a := Article{Url:"http://google.com", Title: "Test"}
	tweets := recentArticlesFromTwitterAccount(handle, appengine.NewContext(r))
	data, _ := json.Marshal(tweets)
	w.Write(data)
}

func fetchTaskTest(w http.ResponseWriter, r *http.Request) {
	ctx := appengine.NewContext(r)
	twitterFetchTask(ctx, 0, 0)
	fmt.Fprintf(w, "Done!")
}

func testMercury(w http.ResponseWriter, r *http.Request) {
	ctx := appengine.NewContext(r)
	r.ParseForm()
	urls := strings.Split(r.Form.Get("urls"), "\n")
	fmt.Fprintf(w, spew.Sdump(fetchMercuryMulti(ctx, urls)))
}

func testAmp(w http.ResponseWriter, r *http.Request) {
	ctx := appengine.NewContext(r)
	r.ParseForm()
	urls := strings.Split(r.Form.Get("urls"), "\n")
	fmt.Fprintf(w, spew.Sdump(fetchAmpMulti(ctx, urls)))
}

func restartFetchTasks(w http.ResponseWriter, r *http.Request) {
	// TODO
}
