package main

import (
	"bytes"
	"crypto/cipher"
	"encoding/binary"

	"golang.org/x/crypto/blowfish"
)

/**
 * @param method string blowfish模式
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
func blowfishEncrypt(method string, origData, key, iv []byte, option string) ([]byte, error) {
	block, err := blowfish.NewCipher(key)
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
	if method == "CBC" {
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
 * @param method string blowfish模式
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
func blowfishDecrypt(method string, crypted, key, iv []byte, option string) ([]byte, error) {
	block, err := blowfish.NewCipher(key)
	if err != nil {
		return nil, err
	}
	// bs := block.BlockSize()

	origData := make([]byte, len(crypted))
	if method == "CBC" {
		blockMode := cipher.NewCBCDecrypter(block, iv)
		// origData := crypted
		blockMode.CryptBlocks(origData, crypted)
	} else if method == "CFB" {
		// crypted = crypted[blowfish.BlockSize:]
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
	padding := blowfish.BlockSize - len(ciphertext)%blowfish.BlockSize
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

func convertEndian(in []byte) ([]byte, error) {
	//Read byte array as uint32 (little-endian)
	var v1, v2 uint32
	buf := bytes.NewReader(in)
	if err := binary.Read(buf, binary.LittleEndian, &v1); err != nil {
		return nil, err
	}
	if err := binary.Read(buf, binary.LittleEndian, &v2); err != nil {
		return nil, err
	}

	//convert uint32 to byte array
	out := make([]byte, 8)
	binary.BigEndian.PutUint32(out, v1)
	binary.BigEndian.PutUint32(out[4:], v2)

	return out, nil
}
