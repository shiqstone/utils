APACHE_INSTALL="/usr/local/apache2"
adirname() { odir=`pwd`; cd `dirname $1`; pwd; cd "${odir}"; }
INSTALL_DIR=`adirname "$0"`
   function apache_install()
     {
         ###install apache######
         yum -y install zlib zlib-devel openssl openssl-devel
         tar zxvf httpd-2.2.22.tar.gz
         cd httpd-2.2.22
         ./configure --prefix=/usr/local/apache2 --enable-so --enable-deflate --enable-headers --enable-ssl --enable-rewrite --enable-logio --enable-expires
         make ; make install
         #####add conf##########
         cd ..
         tar zxvf conf.tar.gz
         if [ -d ${APACHE_INSTALL} ]; then
            rm -rf ${APACHE_INSTALL}/conf
         else
            echo "${APACHE_INSTALL} is not Exist"
            exit 1
         fi 
         cp -r conf /usr/local/apache2/conf 
     }

   function mysql_install()
      { 
           ######install mysql########
           yum -y install ncurses-devel
           yum -y install mcrypt
           tar zxvf mysql-5.1.61.tar.gz 
           cd mysql-5.1.61
           ./configure --prefix=/usr/local/mysql --enable-assembler --with-charset=utf8
           make; make install
      }
      
      
   function php_install()
     {
        ############install lib################
        yum -y install zlib-devel
        yum -y install curl-devel
        yum -y install libxml2-devel
        yum -y install freetype freetype-devel
        yum -y install libpng libpng-devel
        yum -y install libjpeg libjpeg-devel libtool-ltdl-devel 
        ##############install php##############
        cd ${INSTALL_DIR} 
        cp /usr/lib64/libpng* /usr/lib/
        cp /usr/lib64/libjpeg* /usr/lib/
        tar zxvf php-5.2.17.tar.gz
        cd php-5.2.17
        patch -p1 < php-5.2.17-max-input-vars.patch
        ./configure --with-apxs2=/usr/local/apache2/bin/apxs --enable-mbstring --with-mysql=/usr/local/mysql --with-pdo-mysql=/usr/local/mysql --with-libxml-dir --with-iconv --with-mcrypt --with-freetype-dir --with-jpeg-dir=/usr/local/jpeg --with-png-dir  --with-gd --enable-sqlite-utf8 --with-zlib --with-curl --with-openssl --enable-gd-native-ttf --with-ttf
        make ; make install
        ##############install php.ini#########
        [ -f /usr/local/lib/php.ini ] && rm -rf /usr/local/lib/php.ini
        cd ..
        cp php.ini /usr/local/lib/
      }
      
      
    function memcache_install() 
    {
      tar zxvf memcache-3.0.6.tgz 
      cd memcache-3.0.6
      /usr/local/bin/phpize
      ./configure --enable-memcache --with-php-config=/usr/local/bin/php-config --with-zlib-dir
      make && make install
    }
 
     function php_openssl()
   {
     [ -f ${INSTALL_DIR}/php-5.2.17/ext/openssl/config0.m4 ] && cp ${INSTALL_DIR}/php-5.2.17/ext/openssl/config0.m4 ${INSTALL_DIR}/php-5.2.17/ext/openssl/config.m4 
        cd ${INSTALL_DIR}/php-5.2.17/ext/openssl/
        /usr/local/bin/phpize
        ./configure
        make ; make install
    }



   function php_libssh2()
   {
        cd ${INSTALL_DIR}
        tar zxvf libssh2-1.2.8.tar.gz
        cd libssh2-1.2.8
        ./configure --prefix=/usr/local/libss2
        make ; make install
        cd ..
        tar zxvf ssh2-0.11.0.tgz
        cd ssh2-0.11.0
        /usr/local/bin/phpize
        ./configure --with-ssh2=/usr/local/libss2
        make ; make install
   }


   function php_gd()
 {
   cd ${INSTALL_DIR}
   yum -y install libpng-devel libjpeg-devel 
   cp /usr/lib64/libpng* /usr/lib/
   cp /usr/lib64/libjpeg* /usr/lib/
   cd ${INSTALL_DIR}/php-5.2.17/ext/gd
   ./configure
   make; make install
 }
   
 function php_redis()
{
 cd ${INSTALL_DIR}
 tar zxvf phpredis-2.2.4.tar.gz
 cd phpredis-2.2.4
 /usr/local/bin/phpize
 ./configure ; make ; make install
}

function php_mongo()
{
 cd ${INSTALL_DIR}
 tar zxvf mongo-1.3.7.tgz
 cd mongo-1.3.7
 /usr/local/bin/phpize
 ./configure
 make 
 make install 
}


function php_jpeg()
{
  cd {$INSTALL_DIR}
  mkdir -p /usr/local/jpeg/{bin,include,lib,man}
  tar zxvf jpeg-6b.tar.gz 
   cd jpeg-6b
  ./configure --prefix=/usr/local/jpeg --enable-shared
  make ; make install
}

function php_mcrypt()
{
  cd {$INSTALL_DIR}
  tar zxvf libmcrypt-2.5.8.tar.gz  
  cd libmcrypt-2.5.8
  ./configure
  make 
  make install
}
function php_memached()
{
  #wget https://launchpad.net/libmemcached/1.0/0.51/+download/libmemcached-0.51.tar.gz
  tar zxvf libmemcached-0.51.tar.gz
  cd libmemcached-0.51
  ./configure  --prefix=/usr/local/libmemcached --with-memcached
  make ; make install
  cd ..
  #wget http://pecl.php.net/get/memcached-1.0.2.tgz
  tar zxvf memcached-1.0.2.tgz
  cd memcached-1.0.2
  /usr/local/bin/phpize
  ./configure  --enable-memcached -with-php-config=/usr/local/bin/php-config --with-libmemcached-dir=/usr/local/libmemcached
  make ; make install
}
function php_memache()
{
  tar zxvf memcache-3.0.6.tgz
  cd memcache-3.0.6
  /usr/local/bin/phpize
  ./configure
  make ; make install
}
function php_zlib()
{
    tar zxvf zlib-1.2.8.tar.gz 
    cd zlib-1.2.8
    CFLAGS="-O3 -fPIC" ./configure
    make ; make install
}

#cp CentOS6-Base-163.repo /etc/yum.repos.d/
#cp epol.repo /etc/yum.repos.d/

apache_install
#mysql_install
php_mcrypt
php_jpeg
php_libssh2
memcache_install
php_redis         
php_mongo
php_memached
php_memache
php_zlib
php_install
