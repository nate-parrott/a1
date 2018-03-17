package main

import "net/url"

func normalizeUrl(original string) string {
	url, err := url.Parse(original)
	if err != nil {
		return original
	}
	url.RawQuery = ""
	url.Fragment = ""
	url.ForceQuery = false
	return url.String()
}
