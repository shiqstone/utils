<?php

if($argc < 3){
    echo "usage: myers-diff [src] [dst] \n";
    exit;
}

const INSERT = 1;
const DELETE = 2;
const MOVE   = 3;

$src = getFilelines($argv[1]);
$dst = getFilelines($argv[2]);

generateDiff($src, $dst);

function generateDiff($src, $dst)
{
    $script = shortEditScript($src, $dst);
    $srcIdx = 0;
    $dstIdx = 0;
    foreach($script as $op){
        if(!isset($dst[$dstIdx]) && !isset($src[$srcIdx])){
            break;
        }
        switch ($op) {
        case INSERT:
            echo "+".$dst[$dstIdx]."\n";
            $dstIdx++;
            break;
        case DELETE:
            echo "-".$src[$srcIdx]."\n";
            $srcIdx++;
            break;
        case MOVE:
            echo " ".$src[$srcIdx]."\n";
            $srcIdx++;
            $dstIdx++;
            break;
        default:
            break;
        }
    }
}

function shortEditscript($src, $dst)
{
    $n = count($src);
    $m = count($dst);
    $max = $n + $m;
    $v = [];
    for($i=-$max; $i<=$max; $i++){
        $v[$i] = 0;
    }
    $trace = [];
    $flag = false;

    for($d=0; $d<=$max; $d++){
        $trace[] = $v;
        for($k=-$d; $k<=$d; $k+=2){
            if($k==-$d){
                $x = $v[$k+1];
            }else if($k!=$d && $v[$k-1] < $v[$k+1]){
                $x = $v[$k+1];
            }else {
                $x = $v[$k-1] + 1;
            }

            $y = $x - $k;

            //$src[$x] = $src[$x] ?? '';
            //$dst[$y] = $dst[$y] ?? '';
            for($x,$y; $x<$n && $y<$m && $src[$x]==$dst[$y]; ){
                $x = $x + 1;
                $y = $y + 1;
            }

            $v[$k] = $x;

            if($x == $n && $y==$m){
                $flag = true;
                break;
            }
        }
        if($flag){
            break;
        }
    }

    //backtracking
    $script = [];
    $x = $n;
    $y = $m;
    for($d=count($trace)-1; $d>0; $d--){
        $k = $x - $y;
        $v = $trace[$d];
        if($k==-$d || ($k != $d && $v[$k-1]<$v[$k+1])){
            $prevK = $k + 1;
        }else{
            $prevK = $k - 1;
        }
        $prevX = $v[$prevK];
        $prevY = $prevX - $prevK;

        for(;$x>$prevX && $y>$prevY;){
            $script[] = MOVE;
            $x -= 1;
            $y -= 1;
        }

        if($x==$prevX){
            $script[] = INSERT;
        }else{
            $script[] = DELETE;
        }

        $x = $prevX;
        $y = $prevY;
    }

    krsort($script);
    return $script;
}

function getFilelines($path){
    $lines = file($path);
    $data = [];
    foreach($lines as $item){
        $data[] = trim($item);
    }
    return $data;
}
