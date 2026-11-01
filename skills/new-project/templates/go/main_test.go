package main

import "testing"

func TestGreeting(t *testing.T) {
	want := "{{NAME}}"
	if got := greeting(); got != want {
		t.Errorf("greeting() = %q, want %q", got, want)
	}
}
