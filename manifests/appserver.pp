group { 'puppet':  
  ensure => 'present', 
}

# Push across the yum config
file { 'yum_conf_default':

  owner => 'root',
  path => '/etc/yum.conf',
  source => '/vagrant/files/yum.conf.default',
  
}

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
  
  # Set the classpath in the default profile
  file { 'java.profile':
	owner => 'root',
	group => 'root',
	mode => 644,
	path => '/etc/profile',
	source => '/vagrant/files/java.profile',
	require => Exec['install_jdk_rpm'],
  }
  
}


# Install MySQL (Server and Client)
class mysql_5_0_96 {

#  file { 'mysql_server_rpm':
#    owner => 'root',
#    path => '/var/tmp/mysql_server.rpm',
#    source => '/vagrant/files/MySQL-server-community-5.0.96-1.rhel5.x86_64.rpm',
#  }
  
#  file { 'mysql_client_rpm':
#    owner => 'root',
#    path => '/var/tmp/mysql_client.rpm',
#    source => '/vagrant/files/MySQL-client-community-5.0.96-1.rhel5.x86_64.rpm',
#  }
  
#  exec { 'install_mysql_server':
#    require => File['mysql_server_rpm'],
#	command => '/bin/rpm --nodeps -ivh /var/tmp/mysql_server.rpm',
#	unless => '/bin/rpm -q MySQL-server-community-5.0.96-1.rhel5.x86_64',
#  }

  package {'MySQL-server-community-5.0.96-1.rhel5.i386':
	ensure => installed,
	require => File['yum_conf_default'],
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
  
#  exec { 'install_mysql_client':
#    require => File['mysql_client_rpm'],
#	command => '/bin/rpm --nodeps -ivh /var/tmp/mysql_client.rpm',
#	unless => '/bin/rpm -q MySQL-client-community-5.0.96-1.rhel5.x86_64',
#  }

  package {'MySQL-client-community-5.0.96-1.rhel5.i386':
	ensure => installed,
	require => File['yum_conf_default'],
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

# MySQL JDBC Driver
class jdbc_driver {

  exec { 'mkdir_cordys_jdbc':
    command => "/bin/mkdir -p /opt/Cordys/JDBC"
  }
  
  file { 'mysql-connector-java-5.0.8.jar':
	owner => 'root',
	group => 'root',
	mode => 755,
	path => '/opt/Cordys/JDBC/mysql-connector-java-5.0.8-bin.jar',
	source => '/vagrant/files/mysql-connector-java-5.0.8.jar',
	require => Exec['mkdir_cordys_jdbc'],
  }
  
  # Create /etc/profile.d/mysql_jdbc.sh
  file { 'mysql_jdbc.profile':
	owner => 'root',
	group => 'root',
	mode => 644,
	path => '/etc/profile.d/mysql_jdbc.sh',
	source => '/vagrant/files/mysql_jdbc.profile',
	require => File['mysql-connector-java-5.0.8.jar'],
  }
}

# Apache
class apache_2_2_43 {
  
  package {'httpd-2.2.3-76.el5.centos':
	ensure => installed,
	require => File['yum_conf_default'],
  }
  
  # Send over updated version of httpd.conf with required modules enabled
  file { 'httpd.conf.mpm':
	owner => 'root',
	group => 'root',
	mode => 644,
	path => '/etc/httpd/httpd.conf',
	source => '/vagrant/files/httpd.conf.mpm',
	require => Package['httpd-2.2.3-76.el5.centos'],
  }
  
  # Add the extra required httpd-mpm.conf
  # First creating the directory...
  file { "/etc/httpd/extra":
    ensure => "directory",
	require => Package['httpd-2.2.3-76.el5.centos'],
  }
  # and then copying over the file...
  file { 'httpd-mpm.conf.mpm':
	owner => 'root',
	group => 'root',
	mode => 644,
	path => '/etc/httpd/extra/httpd-mpm.conf',
	source => '/vagrant/files/httpd-mpm.conf.mpm',
	require => Package['httpd-2.2.3-76.el5.centos'],
  }
  
  service { 'httpd':
    enable => true,
    ensure => running, 
    require => Package['httpd-2.2.3-76.el5.centos'],
  }
  
}

include oracle_jdk_6  
include mysql_5_0_96
include jdbc_driver
include apache_2_2_43
