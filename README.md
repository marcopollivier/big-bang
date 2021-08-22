# Big Bang

![Big Bang Cover](https://p2.trrsf.com/image/fget/cf/460/0/images.terra.com/2018/03/06/o-que-existia-antes-do-big-bang-stephen-hawking-responde.jpg "Big Bang Project Cover")

## Motivation

Criar uma estrutura que facilite a construção de um ambiente de desenvolvimento de forma idempotente e que possa ser utilizado tanto para propósitos educativos quanto profissionais.
Este projeto será preparado para ser executado em ambientes Linux com distribuições Manjaro ou Ubuntu.

O intuito é que quem precisar de algo parecido possa fazer um fork do projeto e customizar da forma que melhor o atender.

Sugestões também são sempre bem-vindas =)

## Executando

Para iniciar a executação do script basta utilizar o seguinte comando:

```shell-script
$ make gitname=fulano gitemail=fulano@gmail.com
```

## Pendencias

### TODO - Analisar
* chrome
* brave

* Jetbrains Toolbox

* VS Code

* Java 11
* Maven
* Gradle

* Terraform

* Wireshark

* Postman 		https://www.getpostman.com/

* Slack              https://slack.com/downloads/linux
* Discord

## #Ferramentas que adicionam source

#### Spotiy
```
# 1. Add the Spotify repository signing keys to be able to verify downloaded packages
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0DF731E45CE24F27EEEB1450EFDC8610341D9410

# 2. Add the Spotify repository
echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list

# 3. Update list of available packages
sudo apt-get update

# 4. Install Spotify
sudo apt-get install spotify-client
```

---
### Ferramentas via WGET

#### Google Chrome
```
sudo dpkg -i "$(wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O -)"
rm google-chrome*
```

#### Git Kraken
```
sudo dpkg -i "$(wget https://release.gitkraken.com/linux/gitkraken-amd64.deb -O -)"
rm gitkraken*
```

#### Oh My Zsh
```
sudo sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
```

---

### Gnome Extensions
- https://extensions.gnome.org/extension/19/user-themes/
- https://extensions.gnome.org/extension/723/pixel-saver/
- https://extensions.gnome.org/extension/906/sound-output-device-chooser/
- https://extensions.gnome.org/extension/120/system-monitor/
- https://extensions.gnome.org/extension/1194/show-desktop-button/
- https://extensions.gnome.org/extension/7/removable-drive-menu/
- https://extensions.gnome.org/extension/779/clipboard-indicator/
- https://extensions.gnome.org/extension/307/dash-to-dock/
- https://extensions.gnome.org/extension/517/caffeine/
- https://extensions.gnome.org/extension/131/touchpad-indicator/

## Outros

### Ambiente Arch

#### Discord

Para instalar o discord em um ambiente Arch-Manjaro, é necessário utilizar um pacote AUR.
Nesse projeto, sempre que necessário utilizamos o **yaourt** como gerenciador de pacotes.

No caso do Discord, é necessário passar uma chave na hora da instalação solicitada pela libce2p.
Dessa forma é necessário fazer o processo de instalação normalmente, pegar a chave que irá informar no final do
processo e depois instalar novamente informando a chave. Dessa forma:

```sh
$ yaourt -S discord --noconfirm
$ gpg --recv-keys <key> && yaourt -S discord --noconfirm
```

Dica do @caioeverest
