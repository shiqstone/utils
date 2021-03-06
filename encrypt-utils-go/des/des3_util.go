package main

import (
	"crypto/cipher"
	"crypto/des"
)

/**
 * 3DES加密
 	@param method string des模式
		ECB 安全性不高，不推荐
		CBC
		CFB
	@param origData
	@param key
	@param iv
	@param option stirng 填充类型
		PKCS5Padding
		ZeroPadding
*/
func TripleDesEncrypt(method string, origData, key, iv []byte, option string) ([]byte, error) {
	block, err := des.NewTripleDESCipher(key)
	if err != nil {
		return nil, err
	}
	bs := block.BlockSize()
	if option == "ZeroPadding" {
		origData = ZeroPadding(origData, bs)
	} else {
		origData = PKCS5Padding(origData, bs)
	}

	var crypted []byte
	if method == "ECB" {
		crypted = make([]byte, len(origData))
		dst := crypted
		for len(origData) > 0 {
			block.Encrypt(dst, origData[:bs])
			origData = origData[bs:]
			dst = dst[bs:]
		}
	} else if method == "CBC" {
		blockMode := cipher.NewCBCEncrypter(block, iv)
		crypted = make([]byte, len(origData))
		// 根据CryptBlocks方法的说明，如下方式初始化crypted也可以
		// crypted := origData
		blockMode.CryptBlocks(crypted, origData)
	} else if method == "CFB" {
		blockMode := cipher.NewCFBEncrypter(block, iv)
		crypted = make([]byte, len(origData))
		// 根据CryptBlocks方法的说明，如下方式初始化crypted也可以
		// crypted := origData
		blockMode.XORKeyStream(crypted, origData)
	}
	return crypted, nil
}

/**
 * 3DES解密
 * @param method string des模式
		ECB 安全性不高，不推荐
		CBC
		CFB
	@param crypted 密文
	@param key
	@param iv
	@param option stirng 填充类型
		PKCS5Padding
		ZeroPadding
*/
func TripleDesDecrypt(method string, crypted, key, iv []byte, option string) ([]byte, error) {
	block, err := des.NewTripleDESCipher(key)
	if err != nil {
		return nil, err
	}
	bs := block.BlockSize()

	origData := make([]byte, len(crypted))
	if method == "ECB" {
		dst := origData
		for len(crypted) > 0 {
			block.Decrypt(dst, crypted[:bs])
			crypted = crypted[bs:]
			dst = dst[bs:]
		}
	} else if method == "CBC" {
		blockMode := cipher.NewCBCDecrypter(block, iv)
		// origData := crypted
		blockMode.CryptBlocks(origData, crypted)
	} else if method == "CFB" {
		blockMode := cipher.NewCFBDecrypter(block, iv)
		// origData := crypted
		blockMode.XORKeyStream(origData, crypted)
	}

	if option == "ZeroPadding" {
		origData = ZeroUnPadding(origData)
	} else {
		origData = PKCS5UnPadding(origData)
	}
	return origData, nil
}

// func test3Des() {
// 	key := []byte("key123456789012345678901")
// 	iv := []byte("iv123456")
// 	data := []byte("cbc-encrypt-test")
// 	result, err := TripleDesEncrypt("CBC", data, key, iv, "PKCS5Padding")
// 	if err != nil {
// 		panic(err)
// 	}
// 	encrypt := base64.StdEncoding.EncodeToString(result)
// 	fmt.Println(encrypt)
// 	origData, err := TripleDesDecrypt("CBC", result, key, iv, "PKCS5Padding")
// 	if err != nil {
// 		panic(err)
// 	}
// 	fmt.Println(string(origData))

// 	data = []byte("ecb-encrypt-test")
// 	result, err = TripleDesEncrypt("ECB", data, key, iv, "PKCS5Padding")
// 	if err != nil {
// 		panic(err)
// 	}
// 	fmt.Println(base64.StdEncoding.EncodeToString(result))
// 	origData, err = TripleDesDecrypt("ECB", result, key, iv, "PKCS5Padding")
// 	if err != nil {
// 		panic(err)
// 	}
// 	fmt.Println(string(origData))

// 	data = []byte("cfb-encrypt-test")
// 	result, err = TripleDesEncrypt("CFB", data, key, iv, "PKCS5Padding")
// 	if err != nil {
// 		panic(err)
// 	}
// 	fmt.Println(base64.StdEncoding.EncodeToString(result))
// 	origData, err = TripleDesDecrypt("CFB", result, key, iv, "PKCS5Padding")
// 	if err != nil {
// 		panic(err)
// 	}
// 	fmt.Println(string(origData))

// }
