package main

import "fmt"

func greeting() string {
	return "{{NAME}}"
}

func main() {
	fmt.Println(greeting())
}
