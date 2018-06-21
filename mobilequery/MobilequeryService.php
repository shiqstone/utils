<?php
class MobilequeryService
{
    public static function mobilequery($mobile)
    {
        $secmobile = substr($mobile, 0, 7);
        $info = self::parseLocalFile($secmobile);
        return $info;        
    }                        

    public static function parseLocalFile($secmobile){
        $mobileindex_path = dirname(__FILE__)."/mobile_demo_index.dat";
        $fp = fopen($mobileindex_path, 'r');
        $begin = 0;          
        $end = filesize($mobileindex_path);
        fseek($fp, $end-6);  
        $offset = 0;         
        $length = 0;         
        do{
            $middle = ceil(($end - $begin) / 10 /2 ) * 10 + $begin;
            fseek($fp, $middle);            
            $middle_mobile = sprintf('%u', implode('', unpack('L', fread($fp, 4))));
            if($secmobile == $middle_mobile){
                $offset = sprintf('%u', implode('', unpack('L', fread($fp, 4))));
                $length = implode('', unpack('S', fread($fp, 2)));
                break;
            }else if($secmobile > $middle_mobile){
                $begin = $middle;               
            }else{
                $end = $middle;
            }
        }while(true);
        fclose($fp);
            
        if($length){
            $mobilestard_path = dirname(__FILE__)."/mobile_demo.txt";
            $handle = fopen($mobilestard_path, 'r');
            fseek($handle, $offset);        
            $line = fgets($handle);         
            $data = explode("\t", trim($line));
            if(!empty($data[0]) && !empty($data[1])){
                $info = ['prov'=>$data[1], 'city'=>$data[2], 'op'=>$data[3]];
            }
            fclose($handle);
            return $info;    
        }   
        return null;
    }
}
