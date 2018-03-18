package main

import (
	"context"
	"google.golang.org/appengine/log"
)

func updateTask(ctx context.Context, userSegment uint32, sourceSegment uint32) {
	client := createFirestoreClient(ctx)
	articles := fetchNewArticles(ctx, client, sourceSegment)
	log.Infof(ctx, "Ingested %v articles", len(articles))
	if len(articles) > 0 {
		distributeArticles(ctx, client, articles, userSegment)

		newAmpUrls := []string{}
		for _, article := range articles {
			newAmpUrls = append(newAmpUrls, article.AmpUrl)
		}
		enqueueWarmUrlTasks(ctx, newAmpUrls)
	}
}
