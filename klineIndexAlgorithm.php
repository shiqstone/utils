<?php
class KlineAlg{

    /*
     * $n   options, usually set 5, 10 ,20
     * $pos last close(day)
     * $list last n days close price
     * */
    public function getSMA($n, $pos, $list){
        $startIdx = $pos - $n +1;
        $endIdx = $pos;
        $count = 0;

        $startIdx = $startIdx<0 ? 0 : $startIdx;

        for($i=$startIdx; $i<$endIdx; $i++){
            $closePrice = $list[$i]['closePrice'];
            $count += $closePrice;
        }
        return $count / ($n-1);
    }
}
