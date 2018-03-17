package main

import (
	"fmt"
	"net/http"
	"google.golang.org/appengine"
	"google.golang.org/appengine/log"
	"context"
	"cloud.google.com/go/firestore"
)

func setupSubscribe() {
	http.HandleFunc("/subscribe", subscribe)
}

type Subscription struct {
	UserId string `firestore:"user_id"`
	Source string `firestore:"source"`
	SegmentId uint32 `firestore:"segment_id"`
}

func (s Subscription) Id() string {
	return s.UserId + " " + s.Source
}

func subscribe(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	handle := string(r.Form.Get("handle"))
	userId := string(r.Form.Get("user_id"))

	ctx := appengine.NewContext(r)
	client := createFirestoreClient(ctx)

	sub := Subscription{UserId:userId, Source:handle, SegmentId: computeSegment(userId, USER_SEGMENTS)}
	_, err := client.Collection("Subscriptions").Doc(sub.Id()).Set(ctx, sub)
	if err != nil {
		log.Errorf(ctx, "Unable to create subscription for %v to %v", userId, handle)
	}

	subscribeOnTwitter(appengine.NewContext(r), handle)

	// put some recent articles from this source into the user's feed:
	articles := recentArticlesFromTwitterAccount(handle, ctx, client)
	distributionChan := make(chan bool)
	for _, article := range articles {
		go distributeArticleToUser(ctx, client, userId, article, distributionChan)
	}
	for i := 0; i < len(articles); i++ {
		success := <- distributionChan
		if !success {
			log.Errorf(ctx, "Failed to distribute one or more articles")
		}
	}

	fmt.Fprintln(w, "ok")
}

func getSubscribers(ctx context.Context, client *firestore.Client, source string, segment uint32) []string {
	 query := client.Collection("Subscriptions").Query.Where("source", "==", source).Where("segment_id", "==", segment)
	 docs, err := query.Documents(ctx).GetAll()
	 if err != nil {
	 	log.Errorf(ctx, "Error finding subscribers for %v", source)
	 	return []string{}
	 }
	 userIds := []string{}
	 for _, doc := range docs {
	 	sub := Subscription{}
	 	err := doc.DataTo(&sub)
	 	if err == nil {
	 		userIds = append(userIds, sub.UserId)
		}
	 }
	 return userIds
	 }
