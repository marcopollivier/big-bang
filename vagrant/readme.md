# Criando uma VM utilizando Vagrant

## Pre-requisitos
Para criar uma máquina virtual utilizando o Vagrant é necessário que já tenha instalado o próprio Vagrant e um gerenciador de VM's (no caso VirtualBox)

Este exemplo é baseado em uma máquina Ubuntu 

```sh
$ sudo apt-get install virtualbox
$ sudo apt-get install vagrant
$ sudo apt-get install virtualbox-dkms
```

## Iniciar
Comandos iniciais para execução

```sh
$ mkdir vagrant_getting_started
$ cd vagrant_getting_started
$ vagrant init
$ vagrant up
$ vagrant ssh
```
