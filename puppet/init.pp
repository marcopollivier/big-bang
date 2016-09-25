exec { "apt-update" :
	command => "/usr/bin/apt-get update"
}

#exec { "add-partner-repo" :
#	command => "sed -i '/^# deb .*partner/ s/^# //' /etc/apt/sources.list"
#}

## Ferramentas básicas
package { "ubuntu-restricted-extras":
	ensure => installed,
	require => Exec["apt-update"],
}

package { "synaptic":
	ensure => installed,
}

package { "apt-listchanges":
	ensure => installed,
	require => Exec["apt-update"],
}

#package { "apt-listbugs":
#	ensure => installed,
#	require => Exec["apt-update"],
#}

package { "vim":
	ensure => installed,
}

package { "unity-tweak-tool":
	ensure => installed,
}

## Uteis
package { "nautilus-dropbox":
	ensure => installed,
}

package { "skype":
	#add-partner-repo
	ensure => installed,
}

## Desenvolvimento - Controle de código e artefatos
package { "git":
	ensure => installed,
	#Adicionar estrutura para configuração
}

package { "maven":
	ensure => installed,
}

## Desenvolvimento - Banco de Dados
package { "mysql-server":
	ensure => installed,
}

#service { "mysql":
#	ensure => running,
#	enable => true,
#	hasstatus => true,
#	hasrestart => true,
#	require => Package["mysql-server"],
#}

package { "mysql-workbench":
	ensure => installed,
}

package { "mongodb":
	ensure => installed,
}

## Desenvolvimento - Ferramentas
package { "filezilla":
	ensure => installed,
}


#Estudos
package { "stellarium":
	ensure => installed,
}
