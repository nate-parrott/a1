package main

import (
	"github.com/huichen/murmur"
)

const TWITTER_SEGMENTS = 1
const USER_SEGMENTS = 1

func computeSegment(s string, segments uint32) uint32 {
	x := murmur.Murmur3([]byte(s)) % segments
	if x < 0 {
		x += segments
	}
	return x
}
