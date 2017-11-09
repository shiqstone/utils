<?php
class IpqueryService {
    public static function ipquery($iplong){
        $info = self::parseLocalFile($iplong);
        return $info;
    }

    public static function parseLocalFile($iplong){

        $ipindex_path = dirname(__FILE__)."/ip_demo_index.dat";
        $fp = fopen($ipindex_path, 'r');
        $begin = 0;
        $end = filesize($ipindex_path);
        $start_ip = sprintf('%u', implode('', unpack('L', fread($fp, 4))));
        fseek($fp, $end-10);
        $end_ip = sprintf('%u', implode('', unpack('L', fread($fp, 4))));
        $offset = 0;
        $length = 0;
        do{
            if($end-$begin <= 14){
                fseek($fp, $begin);
                $s = sprintf('%u', implode('', unpack('L', fread($fp, 4))));
                $e = sprintf('%u', implode('', unpack('L', fread($fp, 4))));
                if($iplong<$s || $iplong>$e){
                    break;
                }
                $offset = sprintf('%u', implode('', unpack('L', fread($fp, 4))));
                $length = implode('', unpack('S', fread($fp, 2)));
                break;
            }
            $middle = ceil(($end - $begin) / 14 /2 ) * 14 + $begin;
            fseek($fp, $middle);
            $middle_ip = sprintf('%u', implode('', unpack('L', fread($fp, 4))));
            if($iplong > $middle_ip){
                $begin = $middle;
            }else{
                $end = $middle;
            }
        }while(true);
        fclose($fp);

        if($length){
            $ipstard_path = dirname(__FILE__)."/ip_demo.txt";
            $handle = fopen($ipstard_path, 'r');
            fseek($handle, $offset);
            $line = fgets($handle);
            $data = explode("\t", trim($line));
            if(!empty($data[0]) && !empty($data[1])){
                $info = ['nation'=>$data[2], 'prov'=>$data[3], 'city'=>$data[4], 'op'=>$data[7]];
            }
            fclose($handle);
            return $info;
        }
        return null;
    }
}
