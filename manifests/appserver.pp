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
  
#class oracle_java_7 {
#  package { "java-1.7.0-openjdk-devel":
#    ensure  => installed,
#	require => Yumrepo['yum'],
#  }
#}

include oracle_jdk_6

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

