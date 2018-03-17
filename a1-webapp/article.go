package main

import (
	"context"
	"cloud.google.com/go/firestore"
	"crypto/sha256"
	"encoding/base64"
	"strings"
)

type Article struct {
	Url string `firestore:"url"`
	CanonicalUrl string `firestore:"canonical_url"`
	AmpUrl string `firestore:"amp_url"`
	Title string `firestore:"title"`
	Dek string `firestore:"dek"`
	Excerpt string `firestore:"excerpt"`
	LeadImageUrl string `firestore:"lead_image_url"`
	FirstSource string `firestore:"first_source"`
	Timestamp int64 `firestore:"timestamp"`
}

func (a Article) Id() string {
	return articleId(a.Url)
}

func articleId(url string) string {
	urlData := ([]byte)(normalizeUrl(url))
	hash := sha256.Sum256(urlData)
	b64 := base64.StdEncoding.EncodeToString(hash[:])
	return strings.Replace(b64, "/", "_", -1)
}

type articleFetchResult struct {
	success bool
	article Article
	url string
}

func findArticle(ctx context.Context, client *firestore.Client, url string, results chan articleFetchResult) {
	snapshot, err := client.Collection("Articles").Doc(articleId(url)).Get(ctx)
	if err != nil {
		results <- articleFetchResult{success: false, url: url}
		return
	}
	article := Article{}
	unpackErr := snapshot.DataTo(&article)
	if unpackErr != nil {
		results <- articleFetchResult{success: false, url: url}
		return
	}
	results <- articleFetchResult{success: true, url: url, article: article}
}

// callers should normalize URLs before calling
func findArticles(ctx context.Context, client *firestore.Client, urls[] string) map[string]Article {
	results := make(chan articleFetchResult)
	for _, url := range urls {
		go findArticle(ctx, client, url, results)
	}
	resultsMap := map[string]Article{}
	for i := 0; i < len(urls); i++ {
		result := <- results
		if result.success {
			resultsMap[result.url] = result.article
		}
	}
	return resultsMap
}

