package main

import (
	"fmt"
	"log"
	"os"

	"github.com/speedata/hyphenation"
)

// go get github.com/speedata/hyphenation
// go mod init github.com/speedata
// go run gohyphen.go
// go build gohyphen.go
// ./gohyphen dicfile word

func main() {
	filename := os.Args[1] 
	r, err := os.Open(filename)
	if err != nil {
		log.Fatal(err)
	}
	l, err := hyphenation.New(r)
	if err != nil {
		log.Fatal(err)
	}

	//var h []int
	word := os.Args[2]
	//h = l.Hyphenate(word)
	//fmt.Println(word, h) // [3 6] and [2 5 7 9]
	str := l.DebugHyphenate(word)
	fmt.Println(str)
}
