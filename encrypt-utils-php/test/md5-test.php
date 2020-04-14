<?php
$algorithm = "md5";
$start = microtime(true);
$src = "sign-test";
for($i=0; $i<10000; $i++){
    $src = "sign-test".$i;
    $res = md5($src);
    if($i==0){
        echo $res."\n";
    }
}
$end = microtime(true);
echo $algorithm." cost:".($end-$start)."\n";
