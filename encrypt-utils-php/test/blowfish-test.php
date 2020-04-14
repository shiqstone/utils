<?php

require __DIR__ . "/../blowfish.php";
$algorithm = "blowfish";
//
//$ciphers             = openssl_get_cipher_methods();
//foreach($ciphers as $cipher){
//    $ivlen = openssl_cipher_iv_length($cipher);
//    echo $cipher." ".$ivlen."\n";
//}
//exit;
/*
    BF-CBC 8
    BF-CFB 8
    BF-ECB 0
    BF-OFB 8
 */
 

$key = 'key1234567890key';
$iv  = 'iv123456';


$src = "ECB-encrypt-test";
$blowfish = new Blowfish($key, 'bf-ecb', Blowfish::OUTPUT_BASE64, '', OPENSSL_RAW_DATA | OPENSSL_NO_PADDING);
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $blowfish->encrypt($src);
}
$end = microtime(true);
echo $algorithm." ecb encrypt cost:".($end-$start)."\n";
echo $res."\n";

$ddata = $res;
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $blowfish->decrypt($ddata);
}
echo $res."\n";
$end = microtime(true);
echo $algorithm." ecb decrypt cost:".($end-$start)."\n\n\n";


$src = "CBC-encrypt-test";
$blowfish = new Blowfish($key, 'bf-cbc', Blowfish::OUTPUT_BASE64, $iv, OPENSSL_RAW_DATA | OPENSSL_NO_PADDING);
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $blowfish->encrypt($src);
}
$end = microtime(true);
echo $algorithm." cbc encrypt cost:".($end-$start)."\n";
echo $res."\n";

$ddata = $res;
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $blowfish->decrypt($ddata);
}
echo $res."\n";
$end = microtime(true);
echo $algorithm." cbc decrypt cost:".($end-$start)."\n\n\n";


$src = "CFB-encrypt-test";
$blowfish = new Blowfish($key, 'bf-cfb', Blowfish::OUTPUT_BASE64, $iv, OPENSSL_RAW_DATA | OPENSSL_NO_PADDING);
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $blowfish->encrypt($src);
}
$end = microtime(true);
echo $algorithm." cfb encrypt cost:".($end-$start)."\n";
echo $res."\n";

$ddata = $res;
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $blowfish->decrypt($ddata);
}
echo $res."\n";
$end = microtime(true);
echo $algorithm." cfb decrypt cost:".($end-$start)."\n\n\n";


