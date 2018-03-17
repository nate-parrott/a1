package main

import (
	"cloud.google.com/go/firestore"
	"context"
	"time"
	"google.golang.org/appengine/log"
)

type ArticleStub struct {
	Url string
	Source string
}

type createArticleResult struct {
	url string
	article Article
	success bool
}

func createArticle(ctx context.Context, client *firestore.Client, url string, source string, ampUrl string, mercury MercuryResponse, results chan createArticleResult) {
	a := Article{
		Url: url,
		CanonicalUrl: mercury.Url,
		AmpUrl: ampUrl,
		Title: mercury.Title,
		Dek: mercury.Dek,
		Excerpt: mercury.Excerpt,
		LeadImageUrl: mercury.LeadImageUrl,
		FirstSource: source,
		Timestamp: time.Now().Unix(), }
		_, err := client.Collection("Articles").Doc(articleId(url)).Set(ctx, a)
		if err != nil {
			log.Errorf(ctx, "Error saving article: %v", err.Error())
			results <- createArticleResult{url: url, success: false}
			return
		}
		results <- createArticleResult{url: url, article: a, success: true}
}

func ingestNewArticles(ctx context.Context, client *firestore.Client, stubs []ArticleStub) map[string]Article {
	if len(stubs) == 0 {
		return map[string]Article{}
	}

	urls := []string{}
	for _, stub := range stubs {
		urls = append(urls, stub.Url)
	}

	mercuryChan := make(chan map[string]MercuryResponse)
	go func() {
		mercuryChan <- fetchMercuryMulti(ctx, urls)
	}()

	ampChan := make(chan map[string]string)
	go func() {
		ampChan <- fetchAmpMulti(ctx, urls)
	}()

	mercuryMap := <- mercuryChan
	ampMap := <- ampChan

	createdArticlesChan := make(chan createArticleResult)
	waitingForArticles := 0
	for _, stub := range stubs {
		mercury, hasMercury := mercuryMap[stub.Url]
		ampUrl, hasAmp := ampMap[stub.Url]
		if hasMercury && hasAmp {
			waitingForArticles += 1
			go createArticle(ctx, client, stub.Url, stub.Source, ampUrl, mercury, createdArticlesChan)
		}
	}

	articles := map[string]Article{}

	for waitingForArticles > 0 {
		result := <- createdArticlesChan
		if result.success {
			articles[result.url] = result.article
		}
		waitingForArticles--
	}

	return articles
}

// if `ignoreExisting` is set, already-ingested articles won't be returned along with the new ones
func ingestArticles(ctx context.Context, client *firestore.Client, stubs []ArticleStub, ignoreExisting bool) map[string]Article {
	urls := []string{}
	for _, stub := range stubs {
		urls = append(urls, stub.Url)
	}
	existingArticles := findArticles(ctx, client, urls)
	stubsForNewArticles := []ArticleStub{}
	for _, stub := range stubs {
		_, exists := existingArticles[stub.Url]
		if !exists {
			stubsForNewArticles = append(stubsForNewArticles, stub)
		}
	}
	newArticles := ingestNewArticles(ctx, client, stubsForNewArticles)

	if !ignoreExisting {
		// merge existing articles in:
		for k, v := range existingArticles {
			newArticles[k] = v
		}
	}

	return newArticles
}
