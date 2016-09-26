#!/bin/bash
#update-java VERSION 0.2beta
#Linux Java update script: Remove old versions, point default at latest version

#Copyright 2010, Bruce Ingalls GPL 3 Affero see http://www.gnu.org/ for details
#Downloads & discussion at http://www.webupd8.org/
#Contact bingalls at users dot sf dot net for licensing & additional help
#Currently supports Ubuntu, only. Likely less useful for RPM based Linux distros.
#Currently supports only full java jdk, not jre.
#Note that update-alternatives by default misses many java tools, such as 'jar'
#Known bugs:
#  Cancelling gksudo takes half a minute.
#  Sun does not install JRE in a standard location
#  Gksudo msgs cannot handle spaces
#  Does not check for Japanese environment & man pages

#BEGIN User Customizations
#SUN_ROOT='/usr/local';
SUN_ROOT='/usr/lib/jvm';
UBUNTU_ROOT='/usr/lib/jvm';

#i18n. Change for non-english
CHOOSE_MSG='Choose';                                 #button column
DELETE_CONFIRM_MSG='OK_to_delete_these_Java_directories?';
DELETE_JAVA_MSG='Choose_Java_versions_to_DELETE_(if_any)!'; #Title, with no spaces!
LINKS_MSG='Enter_sudo_password_to_update_links_to_Java';
#REQUIRES_MSG='Enter_sudo_password_to_install_Zenity_package';
SELECT_JAVA_MSG='Choose_Java_version_to_update_to'; #Title, with no spaces!
#UPDATEDB_MSG='Enter_sudo_password_to_add_new_Java_dirs_to_locate_db'; #No spaces!
VERSION_MSG='Version';                               #JAVA listing column

#END User Customizations

#If locate is active for this system, then we must add the new install.
#Running in background to avoid waiting, but might not progress adequately, before its use, below
if [ ! -z /var/lib/mlocate/mlocate.db ]; then
    gksudo updatedb&
#    gksudo -m $UPDATEDB_MSG updatedb&
fi

which zenity > /dev/null;
if [ $? -gt 0 ]; then
    gksudo 'apt-get install zenity';
#    gksudo -m $REQUIRES_MSG 'apt-get install zenity';
fi

#load current java link
jdefault=`ls -dog /etc/alternatives/java 2>/dev/null | awk '{print $8}' | sed 's|/bin/java||'`

#Prepare a Zenity check button dialog box
CHECK="zenity --list --checklist --text $DELETE_JAVA_MSG --column $CHOOSE_MSG --column $VERSION_MSG"

#Prepare a Zenity radio button dialog box
RADIO="zenity --list --radiolist --text $SELECT_JAVA_MSG --column $CHOOSE_MSG --column $VERSION_MSG"

#Populate the dialog box with located jre directories
declare -a JAVADIRS
JAVADIRS=$(
    ls -1d $UBUNTU_ROOT/java-* 2>/dev/null;
    ls -1d $SUN_ROOT/jdk* 2>/dev/null;
    locate bin/java_vm | grep jre1. | sed 's|/bin/java_vm||'  ||
    beagle-query bin/java_vm | grep jre1. | sed 's|/bin/java_vm||' | sed 's|file://||' 2>/dev/null
    )

for j in ${JAVADIRS[*]}; do
    CHECK=$CHECK" FALSE "$j;
done

#Grab all the Java directories to be uninstalled
DELDIR=`$CHECK`;
if [ ${#DELDIR} -gt 0 ]; then
    zenity --question --text $DELETE_CONFIRM_MSG;
    if [ $? -eq 0 ]; then
        DELETE=`echo ${DELDIR[*]}|tr '|' ' '`;
        `gksudo "rm -fr $DELETE"`;
        for j in ${deldir[*]}; do
            sudo update-alternatives --remove java $j/bin/java
            sudo update-alternatives --remove java_vm $j/bin/java_vm
            sudo update-alternatives --remove javaws $j/bin/javaws
            sudo update-alternatives --remove jcontrol $j/bin/jcontrol
            sudo update-alternatives --remove keytool $j/bin/keytool
            sudo update-alternatives --remove pack200 $j/bin/pack200
            sudo update-alternatives --remove policytool $j/bin/policytool
            sudo update-alternatives --remove rmid $j/bin/rmid
            sudo update-alternatives --remove rmiregistry $j/bin/rmiregistry
            sudo update-alternatives --remove servertool $j/bin/servertool
            sudo update-alternatives --remove tnameserv $j/bin/tnameserv
            sudo update-alternatives --remove unpack200 $j/bin/unpack200
        done
    fi
fi

for j in ${JAVADIRS[*]}; do
    if [ $j == $jdefault ];then
        RADIO=$RADIO" TRUE "$j;
    else
        RADIO=$RADIO" FALSE "$j;
    fi
done

#Grab the new Java link from the radio dialog box 
NEWDIR=`$RADIO`;

if [ $? -gt 0 ]; then exit 2; fi                #cancel clicked
if [[ $NEWDIR == '' ]]; then exit 3; fi   #OK clicked, but no selection

#Increment highest version by 1. DEPENDS on update-alternative msg formatting (in English)!
#Also assumes all Java helper programs (javaws, jcontrol, etc) at same version as java
LATEST=$((`update-alternatives --query java|grep Priority:|awk '{print $2}'|sort -n|tail -1`+1));

gksudo -m "$LINKS_MSG" echo>/dev/null

[ -f $NEWDIR/bin/java ]          && sudo update-alternatives --install /usr/bin/java        java       $NEWDIR/bin/java $LATEST                 --slave /usr/share/man/man1/java.1.gz java.1.gz $NEWDIR/man/man1/java.1.gz
[ -f $NEWDIR/bin/java_vm ]    && sudo update-alternatives --install /usr/bin/java_vm     java_vm    $NEWDIR/jre/bin/java_vm $LATEST
[ -f $NEWDIR/bin/javaws ]      && sudo update-alternatives --install /usr/bin/javaws      javaws     $NEWDIR/bin/javaws $LATEST         --slave /usr/share/man/man1/javaws.1 javaws.1 $NEWDIR/man/man1/javaws.1
[ -f $NEWDIR/bin/jcontrol ]     && sudo update-alternatives --install /usr/bin/jcontrol    jcontrol   $NEWDIR/bin/jcontrol $LATEST
[ -f $NEWDIR/bin/keytool ]      && sudo update-alternatives --install /usr/bin/keytool     keytool    $NEWDIR/bin/keytool $LATEST       --slave /usr/share/man/man1/keytool.1 keytool.1 $NEWDIR/man/man1/keytool.1
[ -f $NEWDIR/bin/pack200 ]   && sudo update-alternatives --install /usr/bin/pack200     pack200    $NEWDIR/bin/pack200 $LATEST    --slave /usr/share/man/man1/pack200.1 pack200.1 $NEWDIR/man/man1/pack200.1
[ -f $NEWDIR/bin/policytool ]   && sudo update-alternatives --install /usr/bin/policytool  policytool $NEWDIR/bin/policytool $LATEST     --slave /usr/share/man/man1/policytool.1 policytool.1 $NEWDIR/man/man1/policytool.1
[ -f $NEWDIR/bin/rmid ]          && sudo update-alternatives --install /usr/bin/rmid        rmid       $NEWDIR/bin/rmid $LATEST                --slave /usr/share/man/man1/rmid.1 rmid.1 $NEWDIR/man/man1/rmid.1
[ -f $NEWDIR/bin/rmiregistry ] && sudo update-alternatives --install /usr/bin/rmiregistry rmiregistry $NEWDIR/bin/rmiregistry $LATEST     --slave /usr/share/man/man1/rmiregistry.1 rmiregistry.1 $NEWDIR/man/man1/rmiregistry.1
[ -f $NEWDIR/bin/servertool ]   && sudo update-alternatives --install /usr/bin/servertool  servertool $NEWDIR/bin/servertool $LATEST    --slave /usr/share/man/man1/servertool.1 servertool.1 $NEWDIR/man/man1/servertool.1
[ -f $NEWDIR/bin/tnameserv ]  && sudo update-alternatives --install /usr/bin/tnameserv   tnameserv  $NEWDIR/bin/tnameserv $LATEST     --slave /usr/share/man/man1/tnameserv.1 tnameserv.1 $NEWDIR/man/man1/tnameserv.1
[ -f $NEWDIR/bin/unpack200 ] && sudo update-alternatives --install /usr/bin/unpack200   unpack200  $NEWDIR/bin/unpack200 $LATEST     --slave /usr/share/man/man1/unpack200.1 unpack200.1 $NEWDIR/man/man1/unpack200.1

[ -f $NEWDIR/bin/libnpjp2.so ] && sudo update-alternatives --install /usr/lib/mozilla/plugins/libnpjp2.so libnpjp2.so $NEWDIR/jre/lib/i386/libnpjp2.so $LATEST

#update-alternatives --remove libnpjp2.so $NEWDIR/jre/lib/i386/libnpjp2.so
