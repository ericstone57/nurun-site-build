class lancome-efforless-chic {

  service {
    'nginx':
      ensure  => 'running',
      enable  => 'true'
  }

  file {
    '/etc/nginx/sites-available/efc':
      content  => template("lancome-efforless-chic/nginx-dev.erb"),
      owner   => 'root',
      group   => 'root',
      notify  => Exec['enable-nginx-site'],
  }

  exec {
    'enable-nginx-site':
      command => 'rm -rf * && ln -s ../sites-available/efc',
      creates => '/etc/nginx/sites-enabled/efc',
      cwd     => '/etc/nginx/sites-enabled',
      user    => 'root',
      notify  => Service['nginx']
  }
}
