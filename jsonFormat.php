<?php
  $str = '{"animals":{"dog":[{"name": "Rufus","age":15}, {"name": "Marty","age": null}] }}';
  //TODO input method, args/file/url
  $res = json_decode($str);
  if($res){
      //TODO trim space
      
      //correct json str, format print
      $prem = 0;
      for($i=0; $i<strlen($str); $i++){
          $char = $str{$i};
          $nxtChar = $str{$i+1};
          if($char == "{"){
              echo $char."\n";
              $prem += 2;
              printf("%{$prem}s", "");
          }else if($char == "}"){ 
              $prem = $prem-2>0 ? $prem-2 : 0;
              printf("%{$prem}s", "");
              echo "\n".$char;
          }else if($char == "["){
              echo $char."\n";
              $prem += 2;
              printf("%{$prem}s", "");
          }else if($char == "]"){ 
              $prem = $prem-2>0 ? $prem-2 : 0;
              printf("%{$prem}s", "");
              echo "\n".$char;
          }else if($char == ","){
              echo $char."\n";
              printf("%{$prem}s", "");
          }else{
              echo $char;
          }   
      }   
      
  }else{  
      //wrong json str, point error location
  }   
