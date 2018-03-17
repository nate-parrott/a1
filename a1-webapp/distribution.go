package main

import (
	"context"
	"cloud.google.com/go/firestore"
	"google.golang.org/appengine/log"
)

func distributeArticleToUser(ctx context.Context, client *firestore.Client, userId string, article Article, results chan bool) {
	_, err := client.Collection("Users").Doc(userId).Collection("feed").Doc(article.Id()).Set(ctx, article)
	if err != nil {
		log.Errorf(ctx, "distribution error: %v", err.Error())
	}
	results <- err == nil
}

func readSuccessFromChannel(channel chan bool, count int) bool {
	success := true
	for i := 0; i < count; i++ {
		success = success && (<- channel)
	}
	return success
}

func distributeArticle(ctx context.Context, client *firestore.Client, article Article, userSegment uint32, results chan bool) {
	subscribers := getSubscribers(ctx, client, article.FirstSource, userSegment)
	userDistResults := make(chan bool)
	for _, uid := range subscribers {
		go distributeArticleToUser(ctx, client, uid, article, userDistResults)
	}
	results <- readSuccessFromChannel(userDistResults, len(subscribers))
}

func distributeArticles(ctx context.Context, client *firestore.Client, articles map[string]Article, userSegment uint32) {
	articleDistResults := make(chan bool)
	for _, article := range articles {
		go distributeArticle(ctx, client, article, userSegment, articleDistResults)
	}
	if !readSuccessFromChannel(articleDistResults, len(articles)) {
		log.Errorf(ctx, "Failed to distribute all articles")
	}
}
