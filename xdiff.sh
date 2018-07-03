#!/bin/sh

LANGUAGE="utf-8"
boldcyan='\E[1;36m\c'

c_notify=$boldcyan

cecho()
{
    if [ $LANGUAGE = "utf-8" ] 
        then
            message=$1
    else
        echo $1 > /tmp/deploy_tools_tmp
            message=`iconv -f "utf-8" -t $LANGUAGE /tmp/deploy_tools_tmp`
            rm -f /tmp/deploy_tools_tmp
            fi
            color=${2:-$black}

    echo -e "$color"
        echo -e "$message"
        tput sgr0           # Reset to normal.
        echo -e "$black"
        return
}

cread()
{
	color=${4:-$black}

	echo -e "$color"
	read $1 "$2" $3 
	tput sgr0			# Reset to normal.
	echo -e "$black"
	return
}

deploy_confirm()
{
    if [ $LANGUAGE = "utf-8" ] 
        then
            message=$1
    else
        echo $1 > /tmp/deploy_tools_tmp
        message=`iconv -f "utf-8" -t $LANGUAGE /tmp/deploy_tools_tmp`
        rm -f /tmp/deploy_tools_tmp
        fi
    while [ 1 = 1 ]
    do
        cread -p "$message [y/n]: " CONTINUE $c_notify
        if [ "y" = "$CONTINUE" ]; then
            return 1;
        fi
        if [ "n" = "$CONTINUE" ]; then
            return 0;
        fi
    done
    return 0;
}


deploy_num()
{
    if [ $LANGUAGE = "utf-8" ] 
    then
        message=$1
        total=$2
    else
        echo $1 > /tmp/deploy_tools_tmp
        message=`iconv -f "utf-8" -t $LANGUAGE /tmp/deploy_tools_tmp`
        rm -f /tmp/deploy_tools_tmp
        fi
    while [ 1 = 1 ]
    do
        cread -p "$message : " NUM $c_notify
        if [ $NUM -ge 0 ] || [ $NUM -lt $total ]; then
            return "$NUM";
        else
            echo
            return
        fi
    done
    return 0;
}

function check_files_diff()
{
	file1=$1	
	file2=$2
	file3=$3

	#   确定文件类型，只针对 text 类型
	type=`file $file1 | grep "text"`
	if [ -z "$type" ]; then
		continue
	fi

	type=`file $file2 | grep "text"`
	if [ -z "$type" ]; then
		continue
	fi

#	deploy_confirm " 确认比较 $file3 ?"
#	if [ 1 != $? ]; then
#		continue
#	fi

	#cecho "\t$file"
	diffs=`diff -Bb $file1 $file2`

	#   如果没有不同就不要确认
	if [ -z "$diffs" ]; then
		continue
	fi

	cecho "\t$file1"
	#   进行 vimdiff
	sleep 1
	vimdiff $file1 $file2
}

# 使用帮助
if [ $# -ne 2 ] || [ "-h" = "$1" ] || [ "--help" = "$1" ]
then
    cecho "用法: xdiff DIR1 DIR2" $c_notify
    exit 0
fi

fold1=$1
fold2=$2
str1="Only in $fold1"
str2="Only in $fold2"
str3="differ$"
i=1
j=1
k=1
diff -rq $fold1 $fold2 > /tmp/diff.txt
while read line
do
    arr=(${line//,/ }) 
    if [[ $(echo $line | grep "${str1}") != "" ]]
    then
        files1[$i]=${arr[2]/://}${arr[3]}
        let i++
    elif [[ $(echo $line | grep "${str2}") != "" ]]
    then
        files2[$j]=${arr[2]/://}${arr[3]}
        let j++
    elif [[ $(echo $line | grep "${str3}") != "" ]]
    then
        files3[$k]=${arr[1]}
        files4[$k]=${arr[3]}
	    files5[$k]=${files3[$k]#*$fold1}
        let k++
    fi
done</tmp/diff.txt


((len1=$i-1))
((len2=$j-1))
((len3=$k-1))

cecho "\n--- 只存在$fold1的文件: ---\n" $c_notify
for((i=1;i<=len1;i++))
do
    echo ${files1[$i]}
done


cecho "\n--- 只存在$fold2的文件: ---\n" $c_notify
for((j=1;j<=len2;j++))
do
    echo ${files2[$j]}
done

cecho "\n--- 存在差异的文件: ---\n" $c_notify
for((k=1;k<=len3;k++))
do
    echo $k ${files5[$k]}
done

echo -e "\n"

deploy_confirm "是否逐个文件比较差异 ?" $c_notify
if [ 1 != $? ]; then
	exit 1;
fi
while [ 1 = 1 ]
do
    message="请输入差异文件编号 [0:全部 -1:退出] " 
    while [ 1 = 1 ]
    do
        cread -p "$message : " NUM $c_notify
        if [ $NUM -ge -1 ] || [ $NUM -lt $len3 ]; then
            break
        fi
    done
    num=$NUM
    if [ '0' = $num ]; then
        for((k=1;k<=len3;k++))
        do
        check_files_diff ${files3[$k]} ${files4[$k]} ${files5[$k]}
        done
        exit
    elif [ '-1' = $num ]; then
        exit
    elif [ $num -ge 1 ] && [ $num -le $len3 ]; then
        check_files_diff ${files3[$num]} ${files4[$num]} ${files5[$num]}
    else
        continue
    fi
done
