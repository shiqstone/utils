<?php
class RsaUtil
{
    public $algo;
    public $pubKeyPath;
    public $priKeyPath;
    public $pubKey;
    public $priKey;
    public $padding;

    /**
     * @param algo
     *      OPENSSL_ALGO_DSS1 (integer)
     *      OPENSSL_ALGO_SHA1 (integer)
     *      OPENSSL_ALGO_SHA224 (integer)
     *      OPENSSL_ALGO_SHA256 (integer)
     *      OPENSSL_ALGO_SHA384 (integer)
     *      OPENSSL_ALGO_SHA512 (integer)
     *      OPENSSL_ALGO_RMD160 (integer)
     *      OPENSSL_ALGO_MD5 (integer)
     * @param padding 
     *      OPENSSL_PKCS1_PADDING
     *      OPENSSL_SSLV23_PADDING
     *      OPENSSL_PKCS1_OAEP_PADDING
     *      OPENSSL_NO_PADDING
     */
    public function __construct($algo=OPENSSL_ALGO_SHA256, $padding=OPENSSL_PKCS1_PADDING )
    {
        $this->algo = $algo;
        $this->padding = $padding;
    }

    public function __destruct()
    {
        // free the key from memory
        if($this->priKey){
            openssl_free_key($this->priKey);
        }
        if($this->pubKey){
            openssl_free_key($this->pubKey);
        }
    }

    public function sign($data)
    {
        openssl_sign($data, $sign, $this->priKey, $this->algo);
        return $sign;
    }

    public function verify($data, $sign)
    {
        $res = openssl_verify($data, $sign, $this->pubKey, $this->algo);
        return $res;
    }

    /*
     * encrypt data by pubkey
     * encrypted data can by decrypted via privateDecrypt()
     */
    public function publicEncrypt($data)
    {
        $crypt = '';
        $chunks = str_split($data, 117); // 1024 bit && OPENSSL_PKCS1_PADDING  不大于117即可
        foreach($chunks as $chunk){
            openssl_public_encrypt($chunk, $encrypted, $this->pubKey, $this->padding);
            $crypt .= $encrypted;
        }
        return base64_encode($crypt);
    }

    /*
     * decrypt data by prikey
     * decrypt data which encrypted via publicEncrypt()
     */
    public function privateDecrypt($crypt)
    {
        $chunks = str_split(base64_decode($crypt), 128); // 1024 bit  固定172
        $decrypt = '';
        foreach($chunks as $chunk){
            $res = openssl_private_decrypt($chunk, $decrypted, $this->priKey, $this->padding);
            if(!$res){
                return false;
            }
            $decrypt .= $decrypted;
        }
        return $decrypt;
    }

    /*
     * encrypt data by prikey
     * encrypted data can by decrypted via publicDecrypt()
     */
    public function privateEncrypt($data)
    {
        $crypt = '';
        $chunks = str_split($data, 117); // 1024 bit && OPENSSL_PKCS1_PADDING  不大于117即可
        foreach($chunks as $chunk){
            openssl_private_encrypt($chunk, $encrypted, $this->priKey, $this->padding);
            $crypt .= $encrypted;
        }
        return base64_encode($crypt);
    }

    /*
     * decrypt data by pubkey
     * decrypt data which encrypted via privateEncrypt()
     */
    public function publicDecrypt($crypt)
    {
        $chunks = str_split(base64_decode($crypt), 128); // 1024 bit  固定172
        $decrypt = '';
        foreach($chunks as $chunk){
            $res = openssl_public_decrypt($chunk, $decrypted, $this->pubKey, $this->padding);
            if(!$res){
                return false;
            }
            $decrypt .= $decrypted;
        }
        return $decrypt;
    }

    public function setPubKeyByPath($keyPath)
    {
        $this->pubKeyPath = $keyPath;
        $this->pubKey = $this->getPubKey($keyPath);
    }

    private function getPubKey($keyPath)
    {
        //$pubkeyid = openssl_pkey_get_public("file://src/openssl-0.9.6/demos/sign/cert.pem");
        //$keyPath = "file://".$keyPath;
        $keyContent = file_get_contents($keyPath);
        $pubKey = openssl_pkey_get_public($keyContent);
        return $pubKey;
    }

    public function setPriKeyByPath($keyPath)
    {
        $this->priKeyPath = $keyPath;
        $this->priKey = $this->getPriKey($keyPath);
    }

    private function getPriKey($keyPath)
    {
        //$keyPath = "file://".$keyPath;
        $keyContent = file_get_contents($keyPath);
        $priKey = openssl_pkey_get_private($keyContent);
        return $priKey;
    }
}

