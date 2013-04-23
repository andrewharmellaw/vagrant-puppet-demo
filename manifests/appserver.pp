group { 'puppet': 
  ensure => 'present', 
}

#yumrepo { "yum":
#  proxy => "http://10.23.12.100:8080",
#}

# Install Oracle JDK.
class oracle_jdk_6 {

  file { 'oracle_jdk_rpm':
    owner => 'root',
    path => '/var/tmp/jdk.rpm',
    source => '/vagrant/files/jdk-6u11-linux-i586.rpm',
  }

  exec { 'install_jdk_rpm':
    require => File['oracle_jdk_rpm'],
    command => '/bin/rpm -ivh /var/tmp/jdk.rpm',
    unless => '/bin/rpm -q jdk',
  }

}


# Install MySQL (Server and Client)
class mysql_5_0_96 {

  file { 'mysql_server_rpm':
    owner => 'root',
    path => '/var/tmp/mysql_server.rpm',
    source => '/vagrant/files/MySQL-server-community-5.0.96-1.rhel5.x86_64.rpm',
  }
  
  file { 'mysql_client_rpm':
    owner => 'root',
    path => '/var/tmp/mysql_client.rpm',
    source => '/vagrant/files/MySQL-client-community-5.0.96-1.rhel5.x86_64.rpm',
  }
  
  exec { 'install_mysql_server':
    require => File['mysql_server_rpm'],
	command => '/bin/rpm --nodeps -ivh /var/tmp/mysql_server.rpm',
	unless => '/bin/rpm -q MySQL-server-community-5.0.96-1.rhel5.x86_64',
  }

# PLEASE REMEMBER TO SET A PASSWORD FOR THE MySQL root USER !
# To do so, start the server, then issue the following commands:
# /usr/bin/mysqladmin -u root password 'new-password'
# /usr/bin/mysqladmin -u root -h appserver01.local password 'new-password'
#
# exec { "set-mysql-password":
#    unless => "mysqladmin -uroot -p$mysql_password status",
#    path => ["/bin", "/usr/bin"],
#    command => "mysqladmin -uroot password $mysql_password",
#    require => Exec['install_mysql_server'],
#  }
  
  exec { 'install_mysql_client':
    require => File['mysql_client_rpm'],
	command => '/bin/rpm --nodeps -ivh /var/tmp/mysql_client.rpm',
	unless => '/bin/rpm -q MySQL-client-community-5.0.96-1.rhel5.x86_64',
  }
  
  service { 'mysql':
    enable => true,
    ensure => running, 
    require => Exec['install_mysql_server'],
  }
  
#  exec { "create-db-schema-and-user":
#    command => "/usr/bin/mysql -uroot -p -e \"drop database if exists testapp; create database testapp; create user dbuser@'%' identified by 'dbuser'; grant all on testapp.* to dbuser@'%'; flush privileges;\"",
#    require => Service["mysql"]
#  }
  
  file { '/etc/my.cnf':
    owner => 'root',
    group => 'root',
    mode => 644,
    notify => Service['mysql'],
    source => '/vagrant/files/my.cnf',
    require => Exec['install_mysql_server'],
  }
  
}

include oracle_jdk_6  
include mysql_5_0_96
  
#class oracle_java_7 {
#  package { "java-1.7.0-openjdk-devel":
#    ensure  => installed,
#	require => Yumrepo['yum'],
#  }
#}



#class tomcat_6 {

#  package { "tomcat6":
#    ensure => installed,
#    require => Package['openjdk-6-jdk'],
#  }
  
#  package { "tomcat6-admin":
#    ensure => installed,
#    require => Package['tomcat6'],
#  }
  
#  service { "tomcat6":
#    ensure => running,
#    require => Package['tomcat6'],
#    subscribe => File["mysql-connector.jar", "tomcat-users.xml"]
#  }

#  file { "tomcat-users.xml":
#    owner => 'root',
#    path => '/etc/tomcat6/tomcat-users.xml',
#    require => Package['tomcat6'],
#    notify => Service['tomcat6'],
#    content => template('/vagrant/templates/tomcat-users.xml.erb')
#  }

#  file { "mysql-connector.jar":
#    require => Package['tomcat6'],
#    owner => 'root',
#    path => '/usr/share/tomcat6/lib/mysql-connector-java-5.1.15.jar',
#    source => '/vagrant/files/mysql-connector-java-5.1.15.jar'
#  }

#}

# set variables
#$tomcat_password = '12345'
#$tomcat_user = 'tomcat-admin'

#include oracle_java_7
#include tomcat_6

