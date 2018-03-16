package main

import (
	"github.com/ChimeraCoder/anaconda"
	"google.golang.org/appengine/urlfetch"
	"context"
)

func (t TwitterToken) Api(ctx context.Context) *anaconda.TwitterApi  {
	api := anaconda.NewTwitterApiWithCredentials(t.AccessToken, t.AccessTokenSecret, t.ConsumerKey, t.ConsumerSecret)
	api.HttpClient.Transport = &urlfetch.Transport{Context: ctx}
	return api
}


func subscribeOnTwitter(ctx context.Context, handle string) {
	segment := computeSegment(handle, TWITTER_SEGMENTS)
	api := secrets().TwitterTokens[segment].Api(ctx)
	api.FollowUser(handle)
}
