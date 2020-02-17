FROM ubuntu:bionic

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y apt-utils software-properties-common --fix-missing

RUN add-apt-repository -y ppa:ondrej/php && \
    apt update && \
    apt install -y php5.6 \
                   php5.6-mbstring \
                   php5.6-mcrypt \
                   php5.6-mysql \
                   php5.6-xml \
                   php5.6-gd \
                   php5.6-zip \
                   php5.6-curl \
                   php5.6-soap \
                   php5.6-intl \
                   git

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" &&\
    php composer-setup.php --install-dir=bin --filename=composer && \
    php -r "unlink('composer-setup.php');"
    
RUN apt install -y php5.6-dev \
                   libpcre3-dev \
                   gcc \
                   make \
    && \
    git clone --depth 1 https://github.com/phalcon/cphalcon.git && \
    cd cphalcon && \
    git remote set-branches origin '2.0.x' && \
    git fetch --tags --depth 1 origin tags/phalcon-v2.0.9 && \
    git checkout phalcon-v2.0.9 && \
    cd build && \
    ./install && \
    echo "extension=phalcon.so" > /etc/php/5.6/mods-available/phalcon.ini && \
    ln -s /etc/php/5.6/mods-available/phalcon.ini /etc/php/5.6/cli/conf.d/30-phalcon.ini && \
    ln -s /etc/php/5.6/mods-available/phalcon.ini /etc/php/5.6/apache2/conf.d/30-phalcon.ini && \
    /etc/init.d/apache2 restart
    
ENV MYSQL_ROOT_PASSWORD=root

RUN apt install -y mysql-server mysql-client

RUN usermod -d /var/lib/mysql/ mysql && \
    echo "innodb_file_per_table" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "slow_query_log = 1" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "slow_query_log_file = /var/log/mysql/slow.log" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "long_query_time = 5" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "log_queries_not_using_indexes = 1" >> /etc/mysql/mysql.conf.d/mysqld.cnf
