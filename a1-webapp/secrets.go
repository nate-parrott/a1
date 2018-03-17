package main

import (
	"encoding/json"
	"io/ioutil"
)

type Secrets struct {
	Test string `json:"test"`
	TwitterTokens []TwitterToken `json:"twitter_tokens"`
	MercuryKey string `json:"mercury_key"`
	GoogleKey string `json:"google_key"`
}

type TwitterToken struct {
	ConsumerKey string `json:"consumer_key"`
	ConsumerSecret string `json:"consumer_secret"`
	AccessToken string `json:"access_token"`
	AccessTokenSecret string `json:"access_token_secret"`
}

func secrets() Secrets {
	raw, _ := ioutil.ReadFile("./secrets.json")
	var s Secrets
	json.Unmarshal(raw, &s)
	return s
}
