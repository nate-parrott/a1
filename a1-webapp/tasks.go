package main

import (
	"net/http"
	"fmt"
	"net/url"
	"strconv"
	"google.golang.org/appengine/taskqueue"
	"google.golang.org/appengine"
	"time"
	"google.golang.org/appengine/log"
)

const UPDATE_TASK_QUEUE = "update"
const UPDATE_INTERVAL = time.Minute * 10

func setupTasks() {
	http.HandleFunc("/admin/tasks/update", updateTaskHandler)
}

func updateTaskHandler(w http.ResponseWriter, r *http.Request) {
	ctx := appengine.NewContext(r)

	r.ParseForm()
	userSegment, _ := strconv.Atoi(r.Form.Get("userSegment"))
	sourceSegment, _ := strconv.Atoi(r.Form.Get("sourceSegment"))

	log.Infof(ctx, "Starting update task for source segment %v and user segment %v", sourceSegment, userSegment)

	updateTask(ctx, uint32(userSegment), uint32(sourceSegment))

	// queue it again:
	taskqueue.Add(ctx, newUpdateTask(userSegment, sourceSegment, false), UPDATE_TASK_QUEUE)
	log.Infof(ctx, "Finished update task for source segment %v and user segment %v", sourceSegment, userSegment)

	fmt.Fprintln(w, "ok!")
}

func newUpdateTask(userSegment int, sourceSegment int, immediate bool) *taskqueue.Task {
	params := url.Values{}
	params.Set("userSegment", strconv.FormatInt(int64(userSegment), 10))
	params.Set("sourceSegment", strconv.FormatInt(int64(sourceSegment), 10))
	task := taskqueue.NewPOSTTask("/admin/tasks/update", params)
	if !immediate {
		task.Delay = UPDATE_INTERVAL
	}
	return task
}
