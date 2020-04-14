package main

import (
	"bytes"
	"encoding/base64"
	"fmt"
	"testing"
)

func Test256ECBEncDec(t *testing.T) {
	//256
	iv := []byte("iv123456iv123456")
	key := []byte("key12345678901234567890k12345678")

	data := []byte("ECB-encrypt-test")
	result, err := aesEncrypt("ECB", data, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	encrypt := base64.StdEncoding.EncodeToString(result)
	fmt.Println(encrypt)
	origData, err := aesDecrypt("ECB", result, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	fmt.Println(string(origData))
	if !bytes.Equal(data, origData) {
		t.Errorf("expected %s, actual %s", data, origData)
	}
}

func Test192ECBEncDec(t *testing.T) {
	//192
	iv := []byte("iv123456iv123456")
	key := []byte("key12345678901234567890k")

	data := []byte("ECB-encrypt-test")
	result, err := aesEncrypt("ECB", data, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	encrypt := base64.StdEncoding.EncodeToString(result)
	fmt.Println(encrypt)
	origData, err := aesDecrypt("ECB", result, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	fmt.Println(string(origData))
	if !bytes.Equal(data, origData) {
		t.Errorf("expected %s, actual %s", data, origData)
	}
}

func Test128ECBEncDec(t *testing.T) {
	//128
	iv := []byte("iv123456iv123456")
	key := []byte("key1234567890key")

	data := []byte("ECB-encrypt-test")
	result, err := aesEncrypt("ECB", data, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	encrypt := base64.StdEncoding.EncodeToString(result)
	fmt.Println(encrypt)
	origData, err := aesDecrypt("ECB", result, key, iv, "PKCS5Padding")
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

func Test256CBCEncDec(t *testing.T) {
	//256
	iv := []byte("iv123456iv123456")
	key := []byte("key12345678901234567890k12345678")

	data := []byte("cbc-encrypt-test")
	result, err := aesEncrypt("CBC", data, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	encrypt := base64.StdEncoding.EncodeToString(result)
	fmt.Println(encrypt)
	origData, err := aesDecrypt("CBC", result, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	fmt.Println(string(origData))
	if !bytes.Equal(data, origData) {
		t.Errorf("expected %s, actual %s", data, origData)
	}
}

func Test192CBCEncDec(t *testing.T) {
	//192
	iv := []byte("iv123456iv123456")
	key := []byte("key12345678901234567890k")

	data := []byte("cbc-encrypt-test")
	result, err := aesEncrypt("CBC", data, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	encrypt := base64.StdEncoding.EncodeToString(result)
	fmt.Println(encrypt)
	origData, err := aesDecrypt("CBC", result, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	fmt.Println(string(origData))
	if !bytes.Equal(data, origData) {
		t.Errorf("expected %s, actual %s", data, origData)
	}
}

func Test128CBCEncDec(t *testing.T) {
	//128
	iv := []byte("iv123456iv123456")
	key := []byte("key1234567890key")

	data := []byte("cbc-encrypt-test")
	result, err := aesEncrypt("CBC", data, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	encrypt := base64.StdEncoding.EncodeToString(result)
	fmt.Println(encrypt)
	origData, err := aesDecrypt("CBC", result, key, iv, "PKCS5Padding")
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

func Test256CFBEncDec(t *testing.T) {
	//256
	iv := []byte("iv123456iv123456")
	key := []byte("key12345678901234567890k12345678")

	data := []byte("CFB-encrypt-test")
	result, err := aesEncrypt("CFB", data, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	encrypt := base64.StdEncoding.EncodeToString(result)
	fmt.Println(encrypt)
	origData, err := aesDecrypt("CFB", result, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	fmt.Println(string(origData))
	if !bytes.Equal(data, origData) {
		t.Errorf("expected %s, actual %s", data, origData)
	}
}

func Test192CFBEncDec(t *testing.T) {
	//192
	iv := []byte("iv123456iv123456")
	key := []byte("key12345678901234567890k")

	data := []byte("CFB-encrypt-test")
	result, err := aesEncrypt("CFB", data, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	encrypt := base64.StdEncoding.EncodeToString(result)
	fmt.Println(encrypt)
	origData, err := aesDecrypt("CFB", result, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	fmt.Println(string(origData))
	if !bytes.Equal(data, origData) {
		t.Errorf("expected %s, actual %s", data, origData)
	}
}

func Test128CFBEncDec(t *testing.T) {
	//128
	iv := []byte("iv123456iv123456")
	key := []byte("key1234567890key")

	data := []byte("CFB-encrypt-test")
	result, err := aesEncrypt("CFB", data, key, iv, "PKCS5Padding")
	if err != nil {
		panic(err)
	}
	encrypt := base64.StdEncoding.EncodeToString(result)
	fmt.Println(encrypt)
	origData, err := aesDecrypt("CFB", result, key, iv, "PKCS5Padding")
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
