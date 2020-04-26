<?php
$algorithm = "sha1";
$start = microtime(true);
$seckey = "seckey12345678901234567890seckey";
for($i=0; $i<10000; $i++){
    $str = "sign-test".$i;
    $res = hash_hmac('sha1', $str, $seckey);
    if($i==0){
        echo $res."\n";
    }
}
$end = microtime(true);
echo $algorithm." cost:".($end-$start)."\n";