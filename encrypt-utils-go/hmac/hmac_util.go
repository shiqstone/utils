package main

import (
	"crypto/hmac"
	"crypto/sha1"
	"fmt"
)

func main() {
	//hmac ,use sha1
	key := []byte("seckey12345678901234567890seckey")
	mac := hmac.New(sha1.New, key)
	mac.Write([]byte("sign-test0"))
	fmt.Printf("%x\n", mac.Sum(nil))
}
