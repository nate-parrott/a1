package main

import (
	"context"
	"net/url"
	"io/ioutil"
	"net/http"
	"google.golang.org/appengine/urlfetch"
	"google.golang.org/appengine/log"
	"encoding/json"
	"bytes"
)

type AmpServiceRequestJson struct {
	Urls []string `json:"urls"`
}

type AmpServiceResponseJson struct {
	AmpUrls []AmpUrlJson `json:"ampUrls"`
}

type AmpUrlJson struct {
	OriginalUrl string `json:"originalUrl"`
	AmpUrl string `json:"ampUrl"`
	CdnAmpUrl string `json:"cdnAmpUrl"`
}

func constructFallbackAmpUrl(pageUrl string) string {
	v := url.Values{}
	v.Set("url", pageUrl)
	return "https://mercury.postlight.com/amp?" + v.Encode()
}

func fetchAmpMulti(ctx context.Context, urls []string) map[string]string {
	results := map[string]string{}

	bodyData, _ := json.Marshal(AmpServiceRequestJson{Urls: urls})
	req, _ := http.NewRequest("POST", "https://acceleratedmobilepageurl.googleapis.com/v1/ampUrls:batchGet", bytes.NewBuffer(bodyData))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-Goog-Api-Key", secrets().GoogleKey)
	httpResp, httpErr := urlfetch.Client(ctx).Do(req)
	if httpErr != nil {
		log.Errorf(ctx, "Error fetching amp data for urls %v: %v", urls, httpErr.Error())
		return results
	}
	body, bodyErr := ioutil.ReadAll(httpResp.Body)
	if bodyErr != nil {
		log.Errorf(ctx, "Error fetching amp data for urls %v: %v", urls, bodyErr.Error())
		return results
	}
	response := AmpServiceResponseJson{}
	jsonErr := json.Unmarshal(body, &response)
	if jsonErr != nil {
		log.Errorf(ctx, "Error fetching amp data for url %v: %v", urls, jsonErr.Error())
		return results
	}
	ampUrlMap := map[string]string{}
	for _, urlStruct := range response.AmpUrls {
		ampUrlMap[urlStruct.OriginalUrl] = urlStruct.CdnAmpUrl
	}
	for _, originalUrl := range urls {
		if val, ok := ampUrlMap[originalUrl]; ok {
			results[originalUrl] = val
		} else {
			results[originalUrl] = constructFallbackAmpUrl(originalUrl)
		}
	}
	return results
}

