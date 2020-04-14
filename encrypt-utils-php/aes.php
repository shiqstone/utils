<?php
/**
* openssl 实现的 AES 加密类，支持各种 PHP 版本
*/
class AES
{
    /**
     * @var string $method 加解密方法，可通过 openssl_get_cipher_methods() 获得
     */
    protected $method;

    /**
     * @var string $key 加解密的密钥
     */
    protected $key;

    /**
     * @var string $output 输出格式 无、base64、hex
     */
    protected $output;

    /**
     * @var string $iv 加解密的向量
     */
    protected $iv;

    /**
     * @var string $options
     */
    protected $options;

    // output 的类型
    const OUTPUT_NULL = '';
    const OUTPUT_BASE64 = 'base64';
    const OUTPUT_HEX = 'hex';


    /**
     * AES constructor.
     * @param string $key
     * @param string $method
     *      (mode key-len iv-len)
     *      aes-128-cbc 16 16
     *      aes-128-cbc-hmac-sha1 16 16
     *      aes-128-cbc-hmac-sha256 16 16
     *      aes-128-ccm 16 12
     *      aes-128-cfb 16 16
     *      aes-128-cfb1 16 16
     *      aes-128-cfb8 16 16
     *      aes-128-ctr 16 16
     *      aes-128-ecb 16 0
     *      aes-128-gcm 16 12
     *      aes-128-ofb 16 16
     *      aes-128-xts 16 16
     *      aes-192-cbc 24 16
     *      aes-192-ccm 24 12
     *      aes-192-cfb 24 16
     *      aes-192-cfb1 24 16
     *      aes-192-cfb8 24 16
     *      aes-192-ctr 24 16
     *      aes-192-ecb 24 0
     *      aes-192-gcm 24 12
     *      aes-192-ofb 24 16
     *      aes-256-cbc 32 16
     *      aes-256-cbc-hmac-sha1 32 16
     *      aes-256-cbc-hmac-sha256 32 16
     *      aes-256-ccm 32 12
     *      aes-256-cfb 32 16
     *      aes-256-cfb1 32 16
     *      aes-256-cfb8 32 16
     *      aes-256-ctr 32 16
     *      aes-256-ecb 32 0
     *      aes-256-gcm 32 12
     *      aes-256-ofb 32 16
     *      aes-256-xts 32 16
     *      id-aes128-CCM 32 12
     *      id-aes128-GCM 32 12
     *      id-aes128-wrap 32 8
     *      id-aes192-CCM 32 12
     *      id-aes192-GCM 32 12
     *      id-aes192-wrap 32 8
     *      id-aes256-CCM 32 12
     *      id-aes256-GCM 32 12
     *      id-aes256-wrap 32 8
     *
     * @param string $output
     *      base64、hex
     *
     * @param string $iv
     * @param int $options
     */
    public function __construct($key, $method = 'aes-192-cbc', $output = '', $iv = '', $options = OPENSSL_RAW_DATA)
    {
        $this->key = $key;
        $this->method = $method;
        $this->output = $output;
        $this->iv = $iv;
        $this->options = $options;
    }

    /**
     * 加密
     *
     * @param $str
     * @return string
     */
    public function encrypt($str)
    {
        $sign = openssl_encrypt($str, $this->method, $this->key, $this->options, $this->iv);

        if ($this->output == self::OUTPUT_BASE64) {
            $sign = base64_encode($sign);
        } else if ($this->output == self::OUTPUT_HEX) {
            $sign = bin2hex($sign);
        }

        return $sign;
    }

    /**
     * 解密
     *
     * @param $encrypted
     * @return string
     */
    public function decrypt($encrypted)
    {
        if ($this->output == self::OUTPUT_BASE64) {
            $encrypted = base64_decode($encrypted);
        } else if ($this->output == self::OUTPUT_HEX) {
            $encrypted = hex2bin($encrypted);
        }

        $sign = @openssl_decrypt($encrypted, $this->method, $this->key, $this->options, $this->iv);
        $sign = rtrim($sign);
        return $sign;
    }

}
