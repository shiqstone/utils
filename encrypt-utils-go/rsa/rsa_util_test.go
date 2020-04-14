package main

import (
	"encoding/base64"
	"fmt"
	"testing"
)

func TestSign(t *testing.T) {
	msg := []byte("rsa sign")
	//私钥签名
	sig, _ := Sign(msg)
	sign := base64.StdEncoding.EncodeToString(sig)
	fmt.Println("sign str：", sign)
}

func TestVerify(t *testing.T) {
	msg := []byte("rsa sign")
	sig, _ := Sign(msg)
	sign := base64.StdEncoding.EncodeToString(sig)
	fmt.Println("sign str：", sign)
	//sig, _ = base64.StdEncoding.DecodeString("BpoiEjVd6I3lbYxHEWjsCppii/ujR4iiFwuAriECLiASg9kdQocNSgaHrERxdOFxzS7JoK8HVjyU+etvXRVTQqTWiz+1/WFyCBOp142w4dED6sz7OhmaEZRWqUqD/Hj4O6c+4jHqOF6dBrtzmOrmi6kcwqfGePmyTanHL2Ko8xU=")

	//验证签名
	error := Verify(msg, sig)
	if error != nil {
		t.Fail()
	} else {
		t.Log("verify sueccess")
	}
}

func TestPubEncPrivDec(t *testing.T) {
	data := "rsa pub encrypt"
	//公钥加密
	pubenc, _ := PublicEncrypt([]byte(data))
	enctypted := base64.StdEncoding.EncodeToString(pubenc)
	fmt.Println("Pub Encrypted:", enctypted)
	//私钥解密
	encrypt, _ := base64.StdEncoding.DecodeString(enctypted)
	// encrypt, _ := base64.StdEncoding.DecodeString("KMfK0yFG4kwaR5E6TNxaqxpp+rcMrKZEjpnB5kK01vcJTFPTxaqHLR+wniXjGJXs+/cn+FuEumMeglp69czgT5tTf5qLPa+Ajgfb4+nAyAl7vbEwc2mXiTmBL1sscZcqWPw17Qfa5qDJsrbKo5EO85GrsNuNxBsAPW/uhFQU818=")
	decstr, _ := PrivateDecrypt(encrypt)
	fmt.Println("Pri Decrypted:", string(decstr))
	if data != string(decstr) {
		t.Errorf("expected %s, actual %s", data, string(decstr))
	}
}

func TestPrivEncPubDec(t *testing.T) {
	data := "rsa pri encrypt"
	//私钥加密
	privenc, _ := PrivateEncrypt([]byte(data))
	enctypted := base64.StdEncoding.EncodeToString(privenc)
	fmt.Println("Pri Encrypted:", enctypted)
	//公钥解密
	privenc, _ = base64.StdEncoding.DecodeString(enctypted)
	// privenc, _ = base64.StdEncoding.DecodeString("HEVhWjOLHBnhsKG0cpOX7XTFmIteBH5GQSgJKL0Hr5iPFd9j/SvSgan+u1SDbqDwpY0DvP/ecwQ+yJr7L0tF8XSJlusYFbCNDfFBwTkPmSfW4Kl8R3hm/S/363Scj/swj8gmzFrxIOHNOvkXpO/KsBwod+eqQra2bQiBignyCicHbCCoCEC0SNEuCnLXJCdm+QSHkC83RgnP7r4FWyRoMN4eWvVH+whw273LVTWUyLpYi2hHqS0PCyYNERoObkcd5OmJQ7J8AmVdi87Y4MqRMBR9/n0gcbWTYk6ixoHyGyZmTdbuNU27tFeNpUd5+OKWnsYm+u8lYBWxHl+rAOsmGZiME68Esu7uzh0RgQfPEs49ZoDqHmkYXcljGSgnKMgHFxDWnvxMCA2m20IXmdqhqDtebJXxxqOS2wUkZxtq9jBFxstrl2ToSwOhK64wAviGGOc8MRYHHtTToqcrINm7fxpOwiE7Ij7wofI3LzIB9x1vaSVNhKU8Obyg/jwZYGfMSlsjnBBWQh7f7rx/bwvrxICQnyMmNxW/Iv6/Ee/3T0jNLNoISJLAozeWnr7NFM6cEdZRTh7O2AI5JgYGyF6bMMeSNrqWfdAqG3lpdET8N7TLRO3QYCDw/rCkbRVXfvZSKzKkcvwVxCZK6by/fQ4qwmLrKM1xOGWbh2zsvn3Av3MZeJcimFtfDDBlnKmq1Tj15+Xe45LsqVxSzmAvW9me84htVGU15sMJT/DE4RDIEz/YNqzNhouETkWVtCJTy5acz+dckOlvTn9PHOvKf0ZZuqdLvSWrLkSu/gaXyYsaUH2dWiEMtUjLSM6FhXwNiGUUwl1oS9yqdq3sAcvnNYV++DmM/lJtT1aNYJ1Mt2cEyZrAsqmPeD0gu2sRougGyC0RtTC7qjcFgpv6N8ms54/bqw+n50HzfAJFpfW3UMbkShKTQc/Ii0iU2UKQMqAOhZOqIlyjS/S4+3ZKdwelTNDWHInrWzzVBrYRLDzu3QYMp/2dGaMzCMxxRp9hJ2j3A2pP")
	decstr, _ := PublicDecrypt(privenc)
	fmt.Println("Pub Decrypted:", string(decstr))
	if data != string(decstr) {
		t.Errorf("expected %s, actual %s", data, string(decstr))
	}
}
