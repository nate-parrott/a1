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
	"google.golang.org/appengine/taskqueue"
	"time"
)

var tpl = template.Must(template.ParseGlob("html/*.html"))

func setupAdminDashboard() {
	http.HandleFunc("/admin", adminDashboard)
	http.HandleFunc("/admin/test_fetch_task", fetchTaskTest)
	http.HandleFunc("/admin/test_source_fetch", testSourceFetch)
	http.HandleFunc("/admin/restart_fetch_tasks", restartFetchTasks)
	http.HandleFunc("/admin/test_mercury", testMercury)
	http.HandleFunc("/admin/test_amp", testAmp)
	http.HandleFunc("/admin/test_ingest", testIngest)
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
	ctx := appengine.NewContext(r)
	client := createFirestoreClient(ctx)
	articles := recentArticlesFromTwitterAccount(handle, ctx, client)
	data, _ := json.Marshal(articles)
	w.Write(data)
}

func fetchTaskTest(w http.ResponseWriter, r *http.Request) {
	ctx := appengine.NewContext(r)
	updateTask(ctx, 0, 0)
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

func testIngest(w http.ResponseWriter, r *http.Request) {
	ctx := appengine.NewContext(r)
	client := createFirestoreClient(ctx)
	stubs := []ArticleStub{}
	r.ParseForm()
	for _, url := range strings.Split(r.Form.Get("urls"), "\n") {
		stubs = append(stubs, ArticleStub{Url: normalizeUrl(url), Source: "test"})
	}
	ingestArticles(ctx, client, stubs, false)
	fmt.Fprintln(w, "done")
}

func restartFetchTasks(w http.ResponseWriter, r *http.Request) {
	ctx := appengine.NewContext(r)
	taskqueue.Purge(ctx, UPDATE_TASK_QUEUE)
	time.Sleep(2 * time.Second)

	tasks := []*taskqueue.Task{}

	for userSegment := 0; userSegment < USER_SEGMENTS; userSegment++ {
		for sourceSegment := 0; sourceSegment < TWITTER_SEGMENTS; sourceSegment++ {
			tasks = append(tasks, newUpdateTask(userSegment, sourceSegment, true))
		}
	}

	_, err := taskqueue.AddMulti(ctx, tasks, UPDATE_TASK_QUEUE)
	if err != nil {
		log.Errorf(ctx, "Error enqueueing update tasks: %v", err.Error())
	}

	fmt.Fprintln(w, "done")
}

