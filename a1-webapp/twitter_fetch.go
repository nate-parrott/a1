package main

import (
	"github.com/ChimeraCoder/anaconda"
	"google.golang.org/appengine/urlfetch"
	"context"
	"net/url"
	"google.golang.org/appengine/log"
	"cloud.google.com/go/firestore"
)

func (t TwitterToken) Api(ctx context.Context) *anaconda.TwitterApi  {
	api := anaconda.NewTwitterApiWithCredentials(t.AccessToken, t.AccessTokenSecret, t.ConsumerKey, t.ConsumerSecret)
	api.HttpClient.Transport = &urlfetch.Transport{Context: ctx}
	return api
}


func subscribeOnTwitter(ctx context.Context, handle string) {
	segment := computeSegment(handle, TWITTER_SEGMENTS)

	api := secrets().TwitterTokens[segment].Api(ctx)
	defer api.Close()

	api.FollowUser(handle)
}

func twitterFetchTask(ctx context.Context, userSegment int, sourceSegment int) {
	// TODO
}

func recentArticlesFromTwitterAccount(handle string, ctx context.Context, client *firestore.Client) map[string]Article {
	api := secrets().TwitterTokens[0].Api(ctx)
	defer api.Close()

	log.Errorf(ctx, "handle: %v", handle)
	v := url.Values{}
	v.Set("count", "5")
	v.Set("screen_name", handle)
	tweets, err := api.GetUserTimeline(v)
	if err != nil {
		log.Errorf(ctx, "Error fetching tweets: %v", err.Error())
		return map[string]Article{}
	}
	articles := ingestArticles(ctx, client, articleStubsFromTweets(handle, tweets))
	return articles
}
func articleStubsFromTweets(handle string, tweets []anaconda.Tweet) []ArticleStub {
	stubs := []ArticleStub{}
	for _, tweet := range tweets {
		if !tweet.Retweeted {
			articleUrl := urlFromTweet(tweet)
			if len(articleUrl) > 0 {
				stubs = append(stubs, ArticleStub{Url: normalizeUrl(articleUrl), Source: handle})
			}
		}
	}
	return stubs
}

func urlFromTweet(tweet anaconda.Tweet) string {
	for _, entity := range tweet.Entities.Urls {
		return entity.Expanded_url
	}
	return ""
}
