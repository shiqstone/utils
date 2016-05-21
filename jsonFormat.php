<?php
if(array_search('-f', $argv)){
    $path = $argv[$argc-1];
    $instr = file_get_contents($path);
}else{
    $instr = $argv[$argc-1];
}

$res = json_decode($instr);
if($res){
    //trim space
    $instr = str_replace("\n", "", $instr);
    //unicode to utf
    //$instr=preg_replace("#\\\u([0-9a-f]{4})#ie", "iconv('UCS-2BE', 'UTF-8', pack('H4', '\\1'))", $instr);
    function uni2utf($matches){
        return iconv('UCS-2BE', 'UTF-8', pack('H4', $matches[1]));
    }
    $instr=preg_replace_callback("#\\\u([0-9a-f]{4})#i", "uni2utf", $instr);
    $len = strlen($instr);
    $flag = 0;
    $str = '';
    for($i=0; $i<$len; $i++){
        $char = $instr{$i};
        switch($char){
        case '"':
            $flag++;
            $str .= $char;
            break;
        case " ":
            if($flag%2!=0){
                $str .= $char;
            }
            break;
        default:
            $str .= $char;
            break;
        }
    }

    //correct json str, format print
    $prem = 0;
    $flag = 0;
    $len = strlen($str);
    for($i=0; $i<$len; $i++){
        $char = $str{$i};
        $nxtChar = $i<($len-1) ? $str{$i+1} : '';
        if($char == '"'){
            $flag++;
        }
        if($flag%2==0){
            if($char == "{" || $char == "["){
                echo $char."\n";
                $prem += 2;
                printf("%{$prem}s", "");
            }else if($char == "}" || $char == "]"){
                if($nxtChar == ","){
                    //$prem = $prem-1>0 ? $prem-1 : 0;
                    echo $char;
                }else if($nxtChar == "}" || $nxtChar == "]"){
                    echo $char."\n";
                    $prem = $prem-2>0 ? $prem-2 : 0;
                    printf("%{$prem}s", "");
                }else{
                    $prem = $prem-2>0 ? $prem-2 : 0;
                    printf("%{$prem}s", "");
                    echo $char;
                }
            }else if($char == ","){
                echo $char."\n";
                printf("%{$prem}s", "");
            }else{
                echo $char;
                if($nxtChar == "}" || $nxtChar == "]"){
                    $prem = $prem-2>0 ? $prem-2 : 0;
                    echo "\n";
                    printf("%{$prem}s", "");
                }
            }
        }else{
            echo $char;
        }
    }
    echo "\n";
}else{
    //wrong json str, point error location
}
