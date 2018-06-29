 <?php
  $start = time();
  echo "start...\n";

  if(isset($argv[1])){
      $mobilestard_path = $argv[1];
  }else{
      $mobilestard_path = dirname(__FILE__)."/mobile_demo_short.txt";
  }
  if(isset($argv[2])){
      $mobileindex_path = $argv[2];
  }else{
      $mobileindex_path = dirname(__FILE__)."/mobile_demo_s_index.dat";
  }
  $handle = fopen($mobilestard_path, 'r');
  $fp = fopen($mobileindex_path, 'w');

  $offset = 0;
  while(!feof($handle)){
      $line = fgets($handle);
      $length = strlen($line);
      $data = explode("\t", $line);

      if(count($data)==7 && !empty($data[0])){
          $sec_mobile = $data[0];
          $index = pack('L',$sec_mobile).pack('L',$offset).pack('S',$length);
          fwrite($fp, $index);
          $offset += $length;
      }
  }
  fclose($handle);
  fclose($fp);
  $end = time();
  echo "import done\n";
  echo "cost ".($end-$start)." s\n";
