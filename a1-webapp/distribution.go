package main

import (
	"context"
	"cloud.google.com/go/firestore"
)

func distributeArticleToUser(ctx context.Context, client *firestore.Client, userId string, article Article, results chan bool) {
	_, err := client.Collection("Users").Doc(userId).Collection("feed").Doc(article.Id()).Set(ctx, article)
	results <- err != nil
}
