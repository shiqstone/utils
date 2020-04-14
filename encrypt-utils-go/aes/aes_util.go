package main

import (
	"bytes"
	"crypto/aes"
	"crypto/cipher"
)

/**
 * @param method string aes模式
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
func aesEncrypt(method string, origData, key, iv []byte, option string) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	bs := block.BlockSize()
	if option == "ZeroPadding" {
		origData = ZeroPadding(origData, bs)
	} else {
		origData = PKCS5Padding(origData, bs)
		// origData = PKCS7Padding(origData)
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
 * @param method string aes模式
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
func aesDecrypt(method string, crypted, key, iv []byte, option string) ([]byte, error) {
	block, err := aes.NewCipher(key)
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
		// crypted = crypted[aes.BlockSize:]
		blockMode := cipher.NewCFBDecrypter(block, iv)
		blockMode.XORKeyStream(origData, crypted)
		// origData = crypted
	}

	if option == "ZeroPadding" {
		origData = ZeroUnPadding(origData)
	} else {
		origData = PKCS5UnPadding(origData)
		// origData = PKCS7UnPadding(origData)
	}
	return origData, nil
}

func ZeroPadding(ciphertext []byte, blockSize int) []byte {
	padding := blockSize - len(ciphertext)%blockSize
	padtext := bytes.Repeat([]byte{0}, padding)
	return append(ciphertext, padtext...)
}

func ZeroUnPadding(origData []byte) []byte {
	return bytes.TrimRightFunc(origData, func(r rune) bool {
		return r == rune(0)
	})
}

func PKCS5Padding(ciphertext []byte, blockSize int) []byte {
	padding := blockSize - len(ciphertext)%blockSize
	if padding < 0 {
		padding = 0
	}
	padtext := bytes.Repeat([]byte{byte(padding)}, padding)
	return append(ciphertext, padtext...)
}

func PKCS5UnPadding(origData []byte) []byte {
	length := len(origData)
	if length <= 0 {
		return nil
	}
	// 去掉最后一个字节 unpadding 次
	unpadding := int(origData[length-1])
	if length-unpadding < 0 {
		return nil
	}
	return origData[:(length - unpadding)]
}

func PKCS7Padding(ciphertext []byte) []byte {
	padding := aes.BlockSize - len(ciphertext)%aes.BlockSize
	if padding < 0 {
		padding = 0
	}
	padtext := bytes.Repeat([]byte{byte(padding)}, padding)
	return append(ciphertext, padtext...)
}

func PKCS7UnPadding(plantText []byte) []byte {
	length := len(plantText)
	if length <= 0 {
		return nil
	}
	unpadding := int(plantText[length-1])
	if length-unpadding < 0 {
		return nil
	}
	return plantText[:(length - unpadding)]
}
