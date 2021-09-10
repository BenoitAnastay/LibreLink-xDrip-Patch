#!/bin/bash

# Color codes
NORMAL='\033[0;39m'
GREEN='\033[1;32m'
RED='\033[1;31m'
WHITE='\033[1;37m'
YELLOW='\033[1;33m'

WORKDIR=$(pwd)
FILENAME='com.freestylelibre.app.de_2019-04-22'

if [ ! -x tools/apktool ]; then
  /bin/bash download.sh
fi

if [ ! -e APK/${FILENAME}.apk ]; then
  echo -e "${YELLOW} À cause des CAPCHAT, vous devez manuellement télécharger le fichier APK depuis https://apkpure.com/de/freestyle-librelink-de/com.freestylelibre.app.de/download/4751-APK, puis le placer dans le dossier APK"
fi

echo -e "${WHITE}Vérification des dépendances ...${NORMAL}"
MISSINGTOOL=0
echo -en "${WHITE}  apksigner ... ${NORMAL}"
which apksigner > /dev/null
if [ $? = 0 ]; then
  echo -e "${GREEN}trouvé.${NORMAL}"
else
  echo -e "${RED}non trouvé.${NORMAL}"
  MISSINGTOOL=1
fi
echo -en "${WHITE}  apktool ... ${NORMAL}"
if [ -x tools/apktool ]; then
  echo -e "${GREEN}trouvé.${NORMAL}"
  APKTOOL=$(pwd)/tools/apktool
else
  which apktool > /dev/null
  if [ $? = 0 ]; then
    echo -e "${GREEN}trouvé.${NORMAL} Origine et compatibilité inconnues."
    APKTOOL=$(which apktool)
  else
    echo -e "${RED}non trouvé.${NORMAL}"
    MISSINGTOOL=1
  fi
fi
echo -en "${WHITE}  git ... ${NORMAL}"
which git > /dev/null
if [ $? = 0 ]; then
  echo -e "${GREEN}trouvé.${NORMAL}"
else
  echo -e "${RED}non trouvé.${NORMAL}"
  MISSINGTOOL=1
fi
echo -en "${WHITE}  keytool ... ${NORMAL}"
which keytool > /dev/null
if [ $? = 0 ]; then
  echo -e "${GREEN}trouvé.${NORMAL}"
else
  echo -e "${RED}non trouvé.${NORMAL}"
  MISSINGTOOL=1
fi
echo -en "${WHITE}  zipalign ... ${NORMAL}"
which zipalign > /dev/null
if [ $? = 0 ]; then
  echo -e "${GREEN}trouvé.${NORMAL}"
else
  echo -e "${RED}non trouvé.${NORMAL}"
  MISSINGTOOL=1
fi
echo
if [ ${MISSINGTOOL} = 1 ]; then
  echo -e "${YELLOW}=> Veuillez installer les outils requis.${NORMAL}"
  exit 1
fi

echo -e "${WHITE}Recherche du fichier APK '${FILENAME}.apk' ...${NORMAL}"
if [ -e APK/${FILENAME}.apk ]; then
  echo -e "${GREEN}  trouvé.${NORMAL}"
  echo
else
  echo -e "${RED}  non trouvé.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Veuillez télécharger le fichier APK original depuis https://apkpure.com/de/freestyle-librelink-de/com.freestylelibre.app.de/download/4751-APK et le placer dans le dossier APK/.${NORMAL}"
  exit 1
fi

echo -e "${WHITE}Vérification de la signature MD5 ...${NORMAL}"
md5sum -c APK/${FILENAME}.apk.md5 > /dev/null 2>&1
if [ $? = 0 ]; then
  echo -e "${GREEN}  valide.${NORMAL}"
  echo
else
  echo -e "${RED}  non valide.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Vérifiez d'avoir effectivement téléchargé le fichier original dans sa version allemande.${NORMAL}"
  exit 1
fi

echo -e "${WHITE}Extraction du ficher APK ...${NORMAL}"
${APKTOOL} d -o /tmp/librelink APK/${FILENAME}.apk
if [ $? = 0 ]; then
  echo -e "${GREEN}  OK.${NORMAL}"
  echo
else
  echo -e "${RED}  erreur.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Vérifiez l'erreur.${NORMAL}"
  exit 1
fi

echo -e "${WHITE}Patching de l'application Freestyle ...${NORMAL}"

#Suppresion de la demande de patch de désactivation des fonctions réseau car rendue obligatoire

patches=0001-Add-forwarding-of-Bluetooth-readings-to-other-apps.patch
patches+=" 0002-Disable-uplink-features.patch"
appmode=Offline

cd /tmp/librelink/
for patch in ${patches} ; do
    echo -e "${WHITE}Patch : ${patch}${NORMAL}"
    git apply --whitespace=nowarn --verbose "${WORKDIR}/${patch}"
    if [ $? = 0 ]; then
        echo -e "${GREEN}  OK.${NORMAL}"
        echo
    else
        echo -e "${RED}  erreur.${NORMAL}"
        echo
        echo -e "${YELLOW}=> Une erreur s'est produite.${NORMAL}"
        exit 1
    fi
done

echo -e "${WHITE}Remplacement des sources smali ...${NORMAL}"
cp -Rv ${WORKDIR}/sources/* /tmp/librelink/smali_classes2/com/librelink/app/
if [ $? = 0 ]; then
  echo -e "${GREEN}  OK.${NORMAL}"
  echo
else
  echo -e "${RED}  erreur.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Une erreur s'est produite.${NORMAL}"
  exit 1
fi
chmod 644 /tmp/librelink/smali_classes2/com/librelink/app/*.smali

echo -e "${WHITE}Modification des images de l'application ...${NORMAL}"
cp -Rv ${WORKDIR}/graphics/* /tmp/librelink/
if [ $? = 0 ]; then
  echo -e "${GREEN}  OK.${NORMAL}"
  echo
else
  echo -e "${RED}  erreur.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Une erreur s'est produite.${NORMAL}"
  exit 1
fi

echo -e "${WHITE}Copie de l'APK d'origine ...${NORMAL}"
cp ${WORKDIR}/APK/${FILENAME}.apk /tmp/librelink/assets/original.apk
if [ $? = 0 ]; then
  echo -e "${GREEN}  OK.${NORMAL}"
  echo
else
  echo -e "${RED}  erreur.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Une erreur s'est produite.${NORMAL}"
  exit 1
fi

echo -e "${WHITE}Réassemblange de l'APK ...${NORMAL}"
${APKTOOL} b -o ${WORKDIR}/APK/librelink_unaligned.apk
if [ $? = 0 ]; then
  echo -e "${GREEN}  OK.${NORMAL}"
  echo
else
  echo -e "${RED}  erreur.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Une erreur s'est produite.${NORMAL}"
  exit 1
fi

echo -e "${WHITE}Vidange des fichier temporaires ...${NORMAL}"
cd ${WORKDIR}
rm -rf /tmp/librelink/
echo -e "${GREEN}  okay."
echo

echo -e "${WHITE}Amélioration de l'allignement de l'APK...${NORMAL}"
zipalign -p 4 APK/librelink_unaligned.apk APK/${FILENAME}_patched.apk
if [ $? = 0 ]; then
  echo -e "${GREEN}  ok.${NORMAL}"
  echo
  rm APK/librelink_unaligned.apk
else
  echo -e "${RED}  erreur.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Une erreur s'est produite.${NORMAL}"
  exit 1
fi

echo -e "${WHITE}Génération d'un keystore pour signature ...${NORMAL}"
keytool -genkey -v -keystore /tmp/libre-keystore.p12 -storetype PKCS12 -alias "Libre Signer" -keyalg RSA -keysize 2048 --validity 10000 --storepass geheim --keypass geheim -dname "cn=Libre Signer, c=de"
if [ $? = 0 ]; then
  echo -e "${GREEN}  okay.${NORMAL}"
  echo
else
  echo -e "${RED}  erreur.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Une erreur s'est produite.${NORMAL}"
  exit 1
fi

echo -e "${WHITE}Signature de l'APK ...${NORMAL}"
if [ -x /usr/lib/android-sdk/build-tools/debian/apksigner.jar ]; then
  java -jar /usr/lib/android-sdk/build-tools/debian/apksigner.jar sign --ks-pass pass:geheim --ks /tmp/libre-keystore.p12 APK/${FILENAME}_patched.apk
elif [ -x /usr/share/apksigner/apksigner.jar ]; then
  java -jar /usr/share/apksigner/apksigner.jar sign --ks-pass pass:geheim --ks /tmp/libre-keystore.p12 APK/${FILENAME}_patched.apk
else
  apksigner sign --ks-pass pass:geheim --ks /tmp/libre-keystore.p12 APK/${FILENAME}_patched.apk
fi
if [ $? = 0 ]; then
  echo -e "${GREEN}  okay.${NORMAL}"
  echo
  rm /tmp/libre-keystore.p12
else
  echo -e "${RED}  erreur.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Une erreur s'est produite.${NORMAL}"
  exit 1
fi

if [ -d /mnt/c/ ]; then
  echo -e "${WHITE}WSL detecté ...${NORMAL}"
  echo -e "${WHITE}Déplacement de l'APK ...${NORMAL}"
  mkdir -p /mnt/c/APK
  cp APK/${FILENAME}_patched.apk /mnt/c/APK/
  if [ $? = 0 ]; then
    echo -e "${GREEN}  OK.${NORMAL}"
    echo
  echo -en "${YELLOW}La version modifié de l'application se trouve dans le dossier C:\\APK"
  echo -en "\\"
  echo -e "${FILENAME}_patched.apk${NORMAL}"
  else
    echo -e "${RED}  erreur.${NORMAL}"
    echo
    echo -e "${YELLOW}=> Une erreur s'est produite.${NORMAL}"
    exit 1
  fi
else
  echo -e "${YELLOW}Le fichier de l'application patché est localisé là : APK/${FILENAME}_patched.apk${NORMAL}"
fi

echo -en "${GREEN}Les fonctionalités réseaux ont été désactivés, veulliez utiliser une methode alternative tel que Tidepool"
