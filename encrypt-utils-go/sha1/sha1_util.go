package main

import (
	"crypto/sha1"
	"encoding/hex"
	"fmt"
	"io"
	"log"
	"os"
)

func sha1str(s string) string {
	r := sha1.Sum([]byte(s))
	return hex.EncodeToString(r[:])
}

func sha1file(fName string) string {
	f, e := os.Open(fName)
	if e != nil {
		log.Fatal(e)
	}
	h := sha1.New()
	_, e = io.Copy(h, f)
	if e != nil {
		log.Fatal(e)
	}
	return hex.EncodeToString(h.Sum(nil))
}

func main() {
	str := "sign-test0"
	fmt.Println(sha1str(str))
	fmt.Println(sha1file("../go.mod"))
}
