class martell-ddms {
    package {
        'nginx-full':
            ensure => present;
        'mysql-server':
            ensure => present;
    }

    service {
        'nginx':
            ensure  => running,
            enable  => true;
        'php5-fpm':
            ensure  => running,
            enable  => true;
        'mysql':
            ensure => running,
            enable => true,
    }

    # php
    file {
        '/etc/php5/cli/php.ini':
            content  => template("martell-ddms/php/${env}/php.ini.erb"),
            owner   => 'root',
            group   => 'root',
            notify  => File['/etc/php5/fpm/php.ini'];
        '/etc/php5/fpm/php.ini':
            content  => template("martell-ddms/php/${env}/php.ini.erb"),
            owner   => 'root',
            group   => 'root',
            notify  => Service['php5-fpm'],
    }

    # php-fpm
    file {
        '/etc/php5/fpm/pool.d/ddms.conf':
            content => template("martell-ddms/php-fpm/${env}/ddms.conf.erb"),
            owner   => 'root',
            group   => 'root',
            require => [Exec['prepare-php5-fpm']],
            notify  => File['/etc/php5/fpm/pool.d/ddms-er.conf'];
        '/etc/php5/fpm/pool.d/ddms-er.conf':
            content => template("martell-ddms/php-fpm/${env}/ddms-er.conf.erb"),
            owner   => 'root',
            group   => 'root',
            notify  => Service['php5-fpm'];
    }

    # nginx
    file {
        '/etc/nginx':
            ensure       => directory,
            force        => true,
            recurse      => true,
            source       => 'puppet:///modules/martell-ddms/drupal-with-nginx',
            sourceselect => all,
            owner        => 'root',
            group        => 'root',
            require      => Package['nginx-full'],
            notify       => File['/etc/nginx/nginx.conf'];
        '/etc/nginx/nginx.conf':
            content => template("martell-ddms/nginx/${env}/nginx.conf.erb"),
            owner   => 'root',
            group   => 'root',
            notify  => File['/etc/nginx/upstream_phpcgi_tcp.conf'];
        '/etc/nginx/upstream_phpcgi_tcp.conf':
            content => template("martell-ddms/nginx/${env}/upstream_phpcgi_tcp.conf.erb"),
            owner   => 'root',
            group   => 'root',
            notify  => File['/etc/nginx/php_fpm_status_vhost.conf'];
        '/etc/nginx/php_fpm_status_vhost.conf':
            content => template("martell-ddms/nginx/${env}/php_fpm_status_vhost.conf.erb"),
            owner   => 'root',
            group   => 'root',
            notify  => File['/etc/nginx/apps/drupal/drupal.conf'];
        '/etc/nginx/apps/drupal/drupal.conf':
            content => template("martell-ddms/nginx/${env}/drupal.conf.erb"),
            owner   => 'root',
            group   => 'root',
            notify  => [File['/etc/nginx/sites-available/ddms.conf'], Service['nginx']];
        '/etc/nginx/sites-available/ddms.conf':
            content  => template("martell-ddms/nginx/${env}/ddms.conf.erb"),
            owner   => 'root',
            group   => 'root',
            notify  => Exec['enable-nginx-site'],
    }

    # mysql
    file {
        '/etc/mysql/my.cnf':
            content  => template("martell-ddms/mysql/${env}/my.cnf.erb"),
            owner   => 'root',
            group   => 'root',
            notify  => Service['mysql'],
    }

    exec {
        'enable-nginx-site':
            command => 'rm -rf * && ln -s ../sites-available/ddms.conf',
            creates => '/etc/nginx/sites-enabled/ddms.conf',
            cwd     => '/etc/nginx/sites-enabled',
            user    => 'root',
            notify  => Service['nginx'];
        'prepare-php5-fpm':
            command => 'mkdir -p /var/log/php5-fpm && rm -rf /etc/php5/fpm/pool.d/*',
            user    => 'root',
    }
}
