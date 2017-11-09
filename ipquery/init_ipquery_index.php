<?php
$start = time();
echo "start...\n";

if(isset($argv[1])){
    $ipstard_path = $argv[1];
}else{
    $ipstard_path = dirname(__FILE__)."/ip_standard.txt";
}
if(isset($argv[2])){
    $ipindex_path = $argv[2];
}else{
    $ipindex_path = dirname(__FILE__)."/ip_index.dat";
}
$handle = fopen($ipstard_path, 'r');
$fp = fopen($ipindex_path, 'w');

$offset = 0;
while(!feof($handle)){
    $line = fgets($handle);
    $length = strlen($line);
    $data = explode("\t", $line);
    if(count($data)==8 && !empty($data[1])){
        $start_ip = $data[0];
        $end_ip = $data[1];
        $index = pack('L',$start_ip).pack('L',$end_ip).pack('L',$offset).pack('S',$length);
        fwrite($fp, $index);
        $offset += $length;
    }
}
fclose($handle);
fclose($fp);
$end = time();
echo "import done\n";
echo "cost ".($end-$start)." s\n";
