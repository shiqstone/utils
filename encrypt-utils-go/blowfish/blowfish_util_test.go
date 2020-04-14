package main

import (
	"bytes"
	"encoding/base64"
	"fmt"
	"testing"
)

func TestCBCEncDec(t *testing.T) {
	//128
	iv := []byte("iv123456")
	key := []byte("key1234567890key")

	data := []byte("CBC-encrypt-test")
	result, err := blowfishEncrypt("CBC", data, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	encrypt := base64.StdEncoding.EncodeToString(result)
	fmt.Println(encrypt)
	origData, err := blowfishDecrypt("CBC", result, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	fmt.Println(string(origData))
	// fmt.Println(data)
	// fmt.Println(origData)
	if !bytes.Equal(data, origData) {
		t.Errorf("expected %s, actual %s", data, origData)
	}
}

func TestCFBEncDec(t *testing.T) {
	//128
	iv := []byte("iv123456")
	key := []byte("key1234567890key")

	data := []byte("CFB-encrypt-test")
	result, err := blowfishEncrypt("CFB", data, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	encrypt := base64.StdEncoding.EncodeToString(result)
	fmt.Println(encrypt)
	origData, err := blowfishDecrypt("CFB", result, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	fmt.Println(string(origData))
	// fmt.Println(data)
	// fmt.Println(origData)
	if !bytes.Equal(data, origData) {
		t.Errorf("expected %s, actual %s", data, origData)
	}
}
