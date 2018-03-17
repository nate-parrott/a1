package main

type Source struct {
	TwitterHandle string `firestore:"twitter_handle"`
}

type Article struct {
	Url string `firestore:"url"`
	AmpUrl string `firestore:"amp_url"`
	Title string `firestore:"title"`
	Source Source `firestore:"source"`
	Timestamp int64 `firestore:"timestamp"`
}
