package main

import (
	"bytes"
	"encoding/base64"
	"fmt"
	"testing"
)

func TestDes3ECBEncDec(t *testing.T) {
	key := []byte("key123456789012345678901")
	iv := []byte("iv123456")

	data := []byte("ecb-encrypt-test")
	result, err := TripleDesEncrypt("ECB", data, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	encrypt := base64.StdEncoding.EncodeToString(result)
	fmt.Println(encrypt)
	origData, err := TripleDesDecrypt("ECB", result, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	fmt.Println(string(origData))
	if !bytes.Equal(data, origData) {
		t.Errorf("expected %s, actual %s", data, origData)
	}
}

func TestDes3CBCEncDec(t *testing.T) {
	key := []byte("key123456789012345678901")
	iv := []byte("iv123456")

	data := []byte("cbc-encrypt-test")
	result, err := TripleDesEncrypt("CBC", data, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	encrypt := base64.StdEncoding.EncodeToString(result)
	fmt.Println(encrypt)
	origData, err := TripleDesDecrypt("CBC", result, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	fmt.Println(string(origData))
	if !bytes.Equal(data, origData) {
		t.Errorf("expected %s, actual %s", data, origData)
	}
}

func TestDes3CFBEncDec(t *testing.T) {
	key := []byte("key123456789012345678901")
	iv := []byte("iv123456")

	data := []byte("cfb-encrypt-test")
	result, err := TripleDesEncrypt("CFB", data, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	encrypt := base64.StdEncoding.EncodeToString(result)
	fmt.Println(encrypt)
	origData, err := TripleDesDecrypt("CFB", result, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	fmt.Println(string(origData))
	if !bytes.Equal(data, origData) {
		t.Errorf("expected %s, actual %s", data, origData)
	}
}
