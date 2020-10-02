.DEFAULT_GOAL := start

distroname := $(shell lsb_release -is)  # nome da distro Ex.: Ubuntu, ManjaroLinux
gitname    := $(or $(gitname),${USER})  # nome do usuário git
hostname   := $(shell uname -n)         # nome do host da máquina
username   := $(shell id -u -n)         # nome do usuario autenticado
xdgname    := ${XDG_CURRENT_DESKTOP}    # nome da interface grafica usada Ex.: GNOME

ifeq "$(distroname)" "Ubuntu"
pre-config: -pre-config-ubuntu
endif
ifeq "$(distroname)" "ManjaroLinux"
pre-config: -pre-config-manjaro
endif
ifeq "$(distroname)" "Fedora"
pre-config: -pre-config-fedora
endif

.PHONY: greetings
greetings:
	@echo "################################################################"
	@echo "        Configurando ambiente de dev no host $(hostname)        "
	@echo "################################################################"
	@echo ""

.PHONY: confirm
confirm:
	@$(if $(gitemail), echo "Email informed $(gitemail)",  echo -e "Email not informed!\nYou must inform a email make gitemail=fulano@gmail.com "; exit 1 )
	@echo "# DISTRONAME: $(distroname)"
	@echo "# USERNAME: $(username)"
	@echo "# XDGNAME: $(xdgname)"
	@echo "# GITNAME: $(gitname)"
	@echo "# GITEMAIL: $(gitemail)"

	@echo -n "Are you sure? [ENTER]"
	@read SURE

.PHONY: start
start: greetings confirm
	ansible-playbook \
		-e var_deploy_release="$(distroname)" \
		-e var_deploy_user="$(username)" \
		-e var_deploy_xdg="$(xdgname)" \
		-e var_deploy_git_name="$(gitname)" \
		-e var_deploy_git_email="$(gitemail)" \
		-k -b --ask-become-pass \
		ansible/install.yml

-pre-config-ubuntu:
	@echo "ubuntu not implemented"
	#sudo apt list --installed | grep -i apache
	#sudo apt update
	#sudo apt upgrade
	#sudo apt install -y software-properties-common
	#sudo apt-add-repository ppa:ansible/ansible
	#sudo apt install -y ansible

-pre-config-manjaro:
	@sudo pacman -Syu
	@sudo pacman -S ansible --noconfirm

-pre-config-fedora:
	@echo "fedora not implemented"

-pre-config-unknown:
	@echo "not implemented"
