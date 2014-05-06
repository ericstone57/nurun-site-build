class haier-portal-app {
    service {
        'nginx':
            ensure  => 'running',
            enable  => 'true'
    }

    service {
        'php5-fpm':
            ensure  => 'running',
            enable  => 'true'
    }

    file {
        '/etc/php5/cli/php.ini':
            content  => template("haier-portal-app/php-ini.erb"),
            owner   => 'root',
            group   => 'root',
            notify  => File['/etc/php5/fpm/php.ini'],
    }

    file {
        '/etc/php5/fpm/php.ini':
            content  => template("haier-portal-app/php-ini.erb"),
            owner   => 'root',
            group   => 'root',
            notify  => [Service['php5-fpm'], File['/etc/nginx/sites-available/haier']],
    }

    file {
        '/etc/nginx/sites-available/haier':
            content  => template("haier-portal-app/nginx-www.erb"),
            owner   => 'root',
            group   => 'root',
            notify  => Exec['enable-nginx-site'],
    }

    exec {
        'enable-nginx-site':
            command => 'rm -rf * && ln -s ../sites-available/haier',
            creates => '/etc/nginx/sites-enabled/haier',
            cwd     => '/etc/nginx/sites-enabled',
            user    => 'root',
            notify  => Service['nginx']
    }
}
