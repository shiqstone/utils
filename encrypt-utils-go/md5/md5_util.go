package main

import (
	"crypto/md5"
	"encoding/hex"
	"fmt"
	"io"
	"log"
	"os"
)

func md5str(s string) string {
	r := md5.Sum([]byte(s))
	return hex.EncodeToString(r[:])
}

func md5file(fileName string) string {
	f, e := os.Open(fileName)
	if e != nil {
		log.Fatal(e)
	}
	h := md5.New()
	_, e = io.Copy(h, f)
	if e != nil {
		log.Fatal(e)
	}
	return hex.EncodeToString(h.Sum(nil))
}

func main() {
	str := "sign-test0"
	fmt.Println(md5str(str))
	fmt.Println(md5file("../go.mod"))

}
