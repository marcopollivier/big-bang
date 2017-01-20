exec { "apt-update":
    command => "/usr/bin/apt-get update"
}
package { ["openjdk-7-jre", "tomcat7"]:
    ensure => installed,
    require => Exec["apt-update"]
}