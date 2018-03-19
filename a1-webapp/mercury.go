package main

import (
	"google.golang.org/appengine/urlfetch"
	"context"
	"net/http"
	"net/url"
	"google.golang.org/appengine/log"
	"encoding/json"
	"io/ioutil"
)

type MercuryResponse struct {
	Title string `json:"title" firestore:"title"`
	Content string `json:"content" firestore:"content"`
	LeadImageUrl string `json:"lead_image_url" firestore:"lead_image_url"`
	Date string `json:"date_published"`
	Dek string `json:"dek" firestore:"dek"`
	Url string `json:"url" firestore:"url"`
	Domain string `json:"domain" firestore:"domain"`
	Excerpt string `json:"excerpt" firestore:"excerpt"`
	NextPageUrl string `json:"next_page_url"`
}

type mercuryFetchResult struct {
	url string
	success bool
	response MercuryResponse
}

func mercuryUrl(pageUrl string) string {
	v := url.Values{}
	v.Set("url", pageUrl)
	return "https://mercury.postlight.com/parser?" + v.Encode()
}

func fetchMercury(ctx context.Context, url string, c chan mercuryFetchResult) {
	req, _ := http.NewRequest("GET", mercuryUrl(url), nil)
	req.Header.Set("x-api-key", secrets().MercuryKey)
	httpResp, httpErr := urlfetch.Client(ctx).Do(req)
	if httpErr != nil {
		log.Errorf(ctx, "Error fetching mercury data for url %v: %v", url, httpErr.Error())
		c <- mercuryFetchResult{url: url, success: false}
		return
	}
	body, bodyErr := ioutil.ReadAll(httpResp.Body)
	if bodyErr != nil {
		log.Errorf(ctx, "Error fetching mercury data for url %v: %v", url, bodyErr.Error())
		c <- mercuryFetchResult{url: url, success: false}
		return
	}
	response := MercuryResponse{}
	jsonErr := json.Unmarshal(body, &response)
	if jsonErr != nil {
		log.Errorf(ctx, "Error fetching mercury data for url %v: %v", url, jsonErr.Error())
		c <- mercuryFetchResult{url: url, success: false}
		return
	}
	c <- mercuryFetchResult{url: url, success: true, response: response}
}

func fetchMercuryMulti(ctx context.Context, urls []string) map[string]MercuryResponse {
	results := make(chan mercuryFetchResult)
	for _, url := range urls {
		go fetchMercury(ctx, url, results)
	}
	responsesByUrl := map[string]MercuryResponse{}
	for i := 0; i < len(urls); i++ {
		result := <- results
		if result.success {
			responsesByUrl[result.url] = result.response
		}
	}
	return responsesByUrl
}

