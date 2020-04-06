<?php
require __DIR__ . "/../rsa.php";

$algorithm = "rsa";
$lcnt = 1000;

$data = "rsa sign";
$rsa = new RsaUtil();
$rsa->setPriKeyByPath(__DIR__."/../data/rsa_private_key.pem");
$start = microtime(true);
for($i=0; $i<$lcnt; $i++){
    $sign = $rsa->sign($data);
}
$end = microtime(true);
echo $algorithm." sign cost:".($end-$start)."\n";
//echo "sign: ".$sign."\n";

$rsa = new RsaUtil();
$rsa->setPubKeyByPath(__DIR__."/../data/rsa_public_key.pem");
$start = microtime(true);
for($i=0; $i<$lcnt; $i++){
    $res = $rsa->verify($data, $sign);
}
echo $res."\n";
$end = microtime(true);
echo "verify sign res: ".$res."\n";
echo $algorithm." veirfy sign cost:".($end-$start)."\n\n";

$data = "rsa pub encrypt";
$rsa = new RsaUtil();
$rsa->setPubKeyByPath(__DIR__."/../data/rsa_public_key.pem");
$start = microtime(true);
for($i=0; $i<$lcnt; $i++){
    $crypt = $rsa->publicEncrypt($data);
}
$end = microtime(true);
echo $algorithm." pubenc cost:".($end-$start)."\n";
echo "encrypt: ".base64_encode($crypt)."\n";

$rsa = new RsaUtil();
$rsa->setPriKeyByPath(__DIR__."/../data/rsa_private_key.pem");
$start = microtime(true);
for($i=0; $i<$lcnt; $i++){
    $res = $rsa->privateDecrypt($crypt);
}
$end = microtime(true);
echo "decrypt: ".$res."\n";
echo $algorithm." pridec cost:".($end-$start)."\n\n";

$data = "rsa pri encrypt";
$rsa = new RsaUtil();
$rsa->setPriKeyByPath(__DIR__."/../data/rsa_private_key.pem");
$start = microtime(true);
for($i=0; $i<$lcnt; $i++){
    $crypt = $rsa->privateEncrypt($data);
}
$end = microtime(true);
echo $algorithm." prienc cost:".($end-$start)."\n";
echo "encrypt: ".base64_encode($crypt)."\n";

$rsa = new RsaUtil();
$rsa->setPubKeyByPath(__DIR__."/../data/rsa_public_key.pem");
$start = microtime(true);
for($i=0; $i<$lcnt; $i++){
    $res = $rsa->publicDecrypt($crypt);
}
$end = microtime(true);
echo "decrypt: ".$res."\n";
echo $algorithm." pubdec cost:".($end-$start)."\n\n";
