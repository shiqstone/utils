<?php

require __DIR__ . "/../des.php";
                
$algorithm = "des";

$key = 'key123456';
$iv = 'iv123456';

$src = "cbc-encrytp-test";
$des = new DES($key, 'DES-CBC', DES::OUTPUT_BASE64, $iv);
$start = microtime(true);
for($i=0; $i<10000; $i++){
    //$res = openssl_encrypt ($data, 'des-cbc', $key);
    $res = $des->encrypt($src);
}
$end = microtime(true);
echo $algorithm." cbc-encrypt cost:".($end-$start)."\n";

$ddata = $res;
$start = microtime(true);
for($i=0; $i<10000; $i++){
    //$res = openssl_decrypt ($ddata, 'des-cbc', $key);
    $res = $des->decrypt($ddata);
}
echo $res."\n";
$end = microtime(true);
echo $algorithm." cbc-decrypt cost:".($end-$start)."\n";



// DES ECB 加解密
$src = "ecb-encrytp-test";
$des = new DES($key, 'DES-ECB', DES::OUTPUT_HEX);
$start = microtime(true);
for($i=0; $i<10000; $i++){
    //$res = openssl_encrypt ($data, 'des-ecb', $key, 0, $iv);
    $res = $des->encrypt($src);
}
$end = microtime(true);
echo $algorithm." ecb-encrypt cost:".($end-$start)."\n";

$ddata = $res;
$start = microtime(true);
for($i=0; $i<10000; $i++){
    //$res = openssl_decrypt ($ddata, 'des-ecb', $key, 0, $iv);
    $res = $des->decrypt($ddata);
}
echo $res."\n";
$end = microtime(true);
echo $algorithm." ecb-decrypt cost:".($end-$start)."\n";


// DES CFB 加解密
$src = "cfb-encrytp-test";
$des = new DES($key, 'DES-CFB', DES::OUTPUT_BASE64, $iv);
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $des->encrypt($src);
}
$end = microtime(true);
echo $algorithm." cfb-encrypt cost:".($end-$start)."\n";

$ddata = $res;
$start = microtime(true);
for($i=0; $i<10000; $i++){
    $res = $des->decrypt($ddata);
}
echo $res."\n";
$end = microtime(true);
echo $algorithm." cfb-decrypt cost:".($end-$start)."\n";
