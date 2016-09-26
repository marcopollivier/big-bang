#!/bin/bash

################################################################################################
##								VARIAVEIS E CONSTANTES                                        ##
################################################################################################

_USR_BIN="/usr/bin"
_USR_LOCAL="/usr/local"

_user_name="$(id -u -n)"
_group_users_name="users"

## instalacao

_dir_opt="/opt"

_dir_opt_dev="$_dir_opt/dev"
_dir_opt_apps="$_dir_opt/apps"
_dir_opt_setup="$_dir_opt/setup"


_dir_opt_dev_database="$_dir_opt_dev/database"
_dir_opt_dev_ide="$_dir_opt_dev/ide"
_dir_opt_dev_server="$_dir_opt_dev/server"
_dir_opt_dev_support="$_dir_opt_dev/support"

## Desenvolvimento

_dir_user="/home/$_user_name"

_dir_user_dev="$_dir_user/dev"

_dir_user_dev_siplom="$_dir_user_dev/siplom"

_dir_user_dev_siplom_wks="$_dir_user_dev_siplom/workspace"
_dir_user_dev_siplom_doc="$_dir_user_dev_siplom/docs"

_dir_siplom_v_40="/4.0"
_dir_siplom_v_40_docs="/4.0.docs"
_dir_siplom_v_31="/3.1"

## Versoes

_tomcat="$_dir_opt_dev_server/apache-tomcat-7.0.47"
_maven="$_dir_opt_dev_support/maven"
_ant="$_dir_opt_dev_support/ant"

################################################################################################
##										FUNCOES                                               ##
################################################################################################

###########################################
#Funcao para verificar se diretorio existe#
#$1 -> Path                               #
###########################################
dirCreateIfNotExists(){
	if [ ! -d $1 ]; then
		sudo mkdir -p $1
		echo "## Diretorio $1 criado com sucesso!"
	else
		echo "## Diretorio $1 ja existe!"
	fi
}

#########################
#Mudar permissao usuario#
#$1 -> User Name        #
#$2 -> User Group       #
#$3 -> Path				#
#########################
changeUserPermission(){
	sudo chown -R $1:$2 $3
	echo "## Permissao alterada para a pasta $3"
}

########################
#Cria um link simbolico#
#$1 -> Real Path       #
#$2 -> Symbolic Path   #
########################
configSymbolicLink(){
	if [ ! -h $2 ]; then
		sudo ln -s $1 $2
		echo "## Link $2 criado com sucesso" 
	else
		echo "## Já existe um link simbolico para o $2"
	fi
}

########################################################################
#Funcao destinada para configuracao inicial de diretorios de instalacao#
########################################################################
configInitDirInstall(){

	sleep 1

	echo "############################################################"
	echo "#Criando Estrutura inicial de diretorios dentro de /opt/...#"
	echo "############################################################"
	dirCreateIfNotExists $_dir_opt_dev_database
	dirCreateIfNotExists $_dir_opt_dev_ide
	dirCreateIfNotExists $_dir_opt_dev_server
	dirCreateIfNotExists $_dir_opt_dev_support

	dirCreateIfNotExists $_dir_opt_apps
	dirCreateIfNotExists $_dir_opt_setup

}

#######################################################################
#Funcao destinada para configuracao inicial de diretorios de workspace#
#######################################################################
configInitDirWorkspace(){

	sleep 3

	echo "####################################################################"
	echo "#Criando Estrutura inicial de diretorios dentro de ~/dev/siplom/...#"
	echo "####################################################################"

	dirCreateIfNotExists "$_dir_user_dev_siplom_wks{$_dir_siplom_v_40, $_dir_siplom_v_40_docs, $_dir_siplom_v_31}"

	echo "####################################################"
	echo "#Criando diretorios dentro de ~/dev/siplom/docs/...#"
	echo "####################################################"

	dirCreateIfNotExists "$_dir_user_dev_siplom_doc{$_dir_siplom_v_40, $_dir_siplom_v_40_docs, $_dir_siplom_v_31}"

}

######################
#Definindo permissoes#
######################
configurePermission(){

	sleep 1

	echo "########################################"
	echo "#Configurando permissões de usuários...#"	
	echo "########################################"
	changeUserPermission $_user_name $_group_users_name $_dir_opt_dev
	changeUserPermission $_user_name $_group_users_name $_dir_opt_apps
	changeUserPermission $_user_name $_group_users_name $_dir_opt_setup
	
	changeUserPermission $_user_name $_group_users_name $_dir_user_dev
}

########################
#Funcao main de chamada#
########################
main(){

	if [ $_user_name == "root" ]; then
		echo "Execute inicialmente sem ser ROOT"
	else
		configInitDirInstall
		configInitDirWorkspace

		echo "#######################"
		echo "#Configurando Maven...#"	
		echo "#######################"
		configSymbolicLink $_maven "$_USR_LOCAL/maven"

		echo "#####################"
		echo "#Configurando Ant...#"	
		echo "#####################"
		configSymbolicLink $_ant "$_USR_LOCAL/ant"

		echo "########################"
		echo "#Configurando Tomcat...#"	
		echo "########################"
		configSymbolicLink $_tomcat"bin/catalina.sh" "$_USR_BIN/tomcat"
		
		configurePermission

	fi
}

################################################################################################
##									     EXECUCAO                                        	  ##
################################################################################################
main