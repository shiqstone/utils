<?php
require __DIR__ . "/../aes.php";

$algorithm = "aes";

//$ciphers             = openssl_get_cipher_methods();
//foreach($ciphers as $cipher){
//    $ivlen = openssl_cipher_iv_length($cipher);
//    echo $cipher." ".$ivlen."\n";
//}
//exit;
//$ciphers_and_aliases = openssl_get_cipher_methods(true);
//var_dump($ciphers, $ciphers_and_aliases);
/*
 * aes-192-cbc 16
 * aes-192-ccm 12
 * aes-192-cfb 16
 * aes-192-cfb1 16
 * aes-192-cfb8 16
 * aes-192-ctr 16
 * aes-192-ecb 0
 * aes-192-gcm 12
 * aes-192-ofb 16
 */
 

$key = 'key1234567890key';
$iv  = 'iv123456iv123456';

//$plaintext = "message to be encrypted";
//$cipher="AES-192-CBC";
////$ivlen = openssl_cipher_iv_length($cipher="AES-192-CBC");
////$iv = openssl_random_pseudo_bytes($ivlen);
//$ciphertext_raw = openssl_encrypt($plaintext, $cipher, $key, $options=OPENSSL_RAW_DATA, $iv);
//var_dump($plaintext, $cipher, $key, $options=OPENSSL_RAW_DATA, $iv, $ciphertext_raw);
//$original_plaintext = openssl_decrypt($ciphertext_raw, $cipher, $key, $options=OPENSSL_RAW_DATA, $iv);
//var_dump($original_plaintext);
//exit;


$src = "cbc-192-encrytp-test";
$aes = new AES($key, 'aes-192-cbc', '', $iv);
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->encrypt($src);
}
$end = microtime(true);
echo $algorithm." cbc-192 encrypt cost:".($end-$start)."\n";

$ddata = $res;
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->decrypt($ddata);
}
echo $res."\n";
$end = microtime(true);
echo $algorithm." cbc-192 decrypt cost:".($end-$start)."\n\n\n";


// AES CBC 256 加解密
$src = "cbc-256-encrytp-test";
$aes = new AES($key, 'aes-256-cbc', AES::OUTPUT_BASE64, $iv);
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->encrypt($src);
}
$end = microtime(true);
echo $algorithm." cbc-256-encrypt cost:".($end-$start)."\n";

$ddata = $res;
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->decrypt($ddata);
}
echo $res."\n";
$end = microtime(true);
echo $algorithm." cbc-256-decrypt cost:".($end-$start)."\n\n\n";


$src = "cfb-192-encrytp-test";
$aes = new AES($key, 'aes-192-cfb', '', $iv);
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->encrypt($src);
}
$end = microtime(true);
echo $algorithm." cfb-192 encrypt cost:".($end-$start)."\n";

$ddata = $res;
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->decrypt($ddata);
}
echo $res."\n";
$end = microtime(true);
echo $algorithm." cfb-192 decrypt cost:".($end-$start)."\n\n\n";


// AES CBC 256 加解密
$src = "cfb-256-encrytp-test";
$aes = new AES($key, 'aes-256-cfb', AES::OUTPUT_BASE64, $iv);
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->encrypt($src);
}
$end = microtime(true);
echo $algorithm." cfb-256-encrypt cost:".($end-$start)."\n";

$ddata = $res;
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->decrypt($ddata);
}
echo $res."\n";
$end = microtime(true);
echo $algorithm." cfb-256-decrypt cost:".($end-$start)."\n\n\n";


$src = "ctr-192-encrytp-test";
$aes = new AES($key, 'aes-192-ctr', '', $iv);
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->encrypt($src);
}
$end = microtime(true);
echo $algorithm." ctr-192 encrypt cost:".($end-$start)."\n";

$ddata = $res;
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->decrypt($ddata);
}
echo $res."\n";
$end = microtime(true);
echo $algorithm." ctr-192 decrypt cost:".($end-$start)."\n\n\n";


// AES CBC 256 加解密
$src = "ctr-256-encrytp-test";
$aes = new AES($key, 'aes-256-ctr', AES::OUTPUT_BASE64, $iv);
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->encrypt($src);
}
$end = microtime(true);
echo $algorithm." ctr-256-encrypt cost:".($end-$start)."\n";

$ddata = $res;
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->decrypt($ddata);
}
echo $res."\n";
$end = microtime(true);
echo $algorithm." ctr-256-decrypt cost:".($end-$start)."\n\n\n";

$iv  = 'iv1234iv1234';

$src = "ccm-192-encrytp-test";
$aes = new AES($key, 'aes-192-ccm', '', $iv);
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->encrypt($src);
}
$end = microtime(true);
echo $algorithm." ccm-192 encrypt cost:".($end-$start)."\n";

$ddata = $res;
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->decrypt($ddata);
}
echo $res."\n";
$end = microtime(true);
echo $algorithm." ccm-192 decrypt cost:".($end-$start)."\n\n\n";


// AES CBC 256 加解密
$src = "ccm-256-encrytp-test";
$aes = new AES($key, 'aes-256-ccm', AES::OUTPUT_BASE64, $iv);
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->encrypt($src);
}
$end = microtime(true);
echo $algorithm." ccm-256-encrypt cost:".($end-$start)."\n";

$ddata = $res;
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->decrypt($ddata);
}
echo $res."\n";
$end = microtime(true);
echo $algorithm." ccm-256-decrypt cost:".($end-$start)."\n\n\n";


$src = "gcm-192-encrytp-test";
$aes = new AES($key, 'aes-192-gcm', '', $iv);
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->encrypt($src);
}
$end = microtime(true);
echo $algorithm." gcm-192 encrypt cost:".($end-$start)."\n";

$ddata = $res;
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->decrypt($ddata);
}
echo $res."\n";
$end = microtime(true);
echo $algorithm." gcm-192 decrypt cost:".($end-$start)."\n\n\n";


// AES CBC 256 加解密
$src = "gcm-256-encrytp-test";
$aes = new AES($key, 'aes-256-gcm', AES::OUTPUT_BASE64, $iv);
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->encrypt($src);
}
$end = microtime(true);
echo $algorithm." gcm-256-encrypt cost:".($end-$start)."\n";

$ddata = $res;
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $aes->decrypt($ddata);
}
echo $res."\n";
$end = microtime(true);
echo $algorithm." gcm-256-decrypt cost:".($end-$start)."\n\n\n";
