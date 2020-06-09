#!/bin/bash

app_name=$1

if [ -z "$app_name" ]; then
    echo "kylin-container-app name is empty"
    exit 8
fi

username=$(users)
app_path="/kylin-container"

echo $app_path


if [ ! -d $app_path ];then
	mkdir $app_path  #安装目录创建
fi	

cp $app_name  /app -r

ldconfig

cp /etc/ld.so.cache ./$app_name/etc/ld.so.cache 
cp /etc/ld.so.conf  ./$app_name/etc/ld.so.conf

if [ ! -d $app_path/$app_name ];then                                                                       
	echo $app_name安装
	cp ./$app_name  $app_path/$app_name  -r
else
	echo $app_name已安装，覆盖
	umount $app_path/$app_name/unionfs/etc
	umount $app_path/$app_name/unionfs/var

	rm $app_path/$app_name  -r
	cp ./$app_name  $app_path/$app_name  -r
fi


rm /app -r


if [ ! -d $app_path/$app_name/unionfs ];then
	mkdir $app_path/$app_name/unionfs  #unionfs合并目录创建
fi	


function unionfs
{
        echo  "创建  $app_path/$app_name/unionfs/$1"
        mkdir $app_path/$app_name/unionfs/$1
	mount -t aufs -o  dirs=$app_path/$app_name/$1=rw:/$1=ro none $app_path/$app_name/unionfs/$1
}


unionfs "etc"
unionfs "var"




glib-compile-schemas $app_path/$app_name/usr/share/glib-2.0/schemas  #gsetting
