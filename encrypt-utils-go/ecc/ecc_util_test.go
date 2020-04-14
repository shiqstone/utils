package main

import (
	"encoding/base64"
	"fmt"
	"log"
	"testing"
)

func TestGenerateKey(t *testing.T) {
	//生成密钥对文件
	GenerateKey()
}

func TestGetPrivateKey(t *testing.T) {
	priv := GetPrivateKey("./data/ecc_256.priv.pem")
	if priv == nil {
		t.Fatal("get Private key failed'")
	}
	t.Log(priv)
}

func TestGetPublicKey(t *testing.T) {
	pub := GetPublicKey("./data/ecc_256.pub.pem")
	if pub == nil {
		t.Fatal("get pub key failed'")
	}
	t.Log(pub)
}

func TestSign(t *testing.T) {
	msg := []byte("I am writing today...")
	//生成数字签名
	// rtext, stext := Sign(msg, "eccprivate.pem")
	rtext, stext := Sign(msg, "data/ecc_256.priv.pem")
	fmt.Println("sign: ", base64.StdEncoding.EncodeToString(rtext), base64.StdEncoding.EncodeToString(stext))
}

func TestVerifySign(t *testing.T) {
	msg := []byte("I am writing today...")
	rtext, stext := Sign(msg, "data/ecc_256.priv.pem")

	//验证签名
	verifySign := VerifySign(msg, rtext, stext, "data/ecc_256.pub.pem")
	log.Println(verifySign)
	if verifySign {
		t.Log("verify sueccess")
	} else {
		t.Fail()
	}
}
