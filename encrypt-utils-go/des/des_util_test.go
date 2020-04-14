package main

import (
	"bytes"
	"encoding/base64"
	"fmt"
	"testing"
)

func TestECBEncDec(t *testing.T) {
	key := []byte("key12345")
	iv := []byte("iv123456")

	data := []byte("ecb-encrypt-test")
	result, err := DesEncrypt("ECB", data, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	encrypt := base64.StdEncoding.EncodeToString(result)
	fmt.Println(encrypt)
	origData, err := DesDecrypt("ECB", result, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	fmt.Println(string(origData))
	if !bytes.Equal(data, origData) {
		t.Errorf("expected %s, actual %s", data, origData)
	}
}

func TestCBCEncDec(t *testing.T) {
	key := []byte("key12345")
	iv := []byte("iv123456")

	data := []byte("cbc-encrypt-test")
	result, err := DesEncrypt("CBC", data, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	encrypt := base64.StdEncoding.EncodeToString(result)
	fmt.Println(encrypt)
	origData, err := DesDecrypt("CBC", result, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	fmt.Println(string(origData))
	if !bytes.Equal(data, origData) {
		t.Errorf("expected %s, actual %s", data, origData)
	}
}

func TestCFBEncDec(t *testing.T) {
	key := []byte("key12345")
	iv := []byte("iv123456")

	data := []byte("cfb-encrypt-test")
	result, err := DesEncrypt("CFB", data, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	encrypt := base64.StdEncoding.EncodeToString(result)
	fmt.Println(encrypt)
	origData, err := DesDecrypt("CFB", result, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	fmt.Println(string(origData))
	if !bytes.Equal(data, origData) {
		t.Errorf("expected %s, actual %s", data, origData)
	}
}
