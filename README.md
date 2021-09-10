# Adaptation française du patcher pour application FreeStyle Libre 2#

**Avant Propos:**
Quand les alarmes sont activés sur le téléphonne qui a servi à initialiser un capteur FSL2, celui-ci communique ses mesures à fréquence d'une fois toutes les 5 minutes au téléphonne, mais l'application FreeStyle Libre ne conserve pas ces données et il reste necesairre de faire des scans NFC en raprochant le téléphonne du capteur.

Pour palier à cela et rendre exploitable les données transmises en bleutooth par le capteur, un correctif (patch) a été developpé par des développeurs indépendants.

Ce correctif permet de diffuser les données transmises par le capteur à d'autres applications présentes sur le téléphonne, notament xDrip+ qui est une application open-source prenant en charge plusieurs CGM et pouvant fonctionner avec AndroidAPS pour les boucles fermés DIY

Si vous avez les diffictultés à generer la version modifié de l'application vous pouvez demander à un proche compétant en informatique, pour éviter de recevoir une plainte par Abbott pour atteinte au copyright il n'est pas possible de diffuser une version déjà modifié de leur application mais ce script ne comptenant aucun code appartenant à Abbot peut librement être diffusé.

Une documentation de l'outil est disponible sur AndroidAPS : https://androidaps.readthedocs.io/fr/latest/Hardware/Libre2.html (si vous n'avez pas de pompe vous pouvez ignorer les dernières étapes)

**Installation:**
NB : La transmission ne fonctionnera que si vous avez démaré le capteur avec l'application modifié
## Téléchargement de Ubuntu
Rendez vous sur le [Windows Store](https://www.microsoft.com/fr-fr/p/ubuntu/9nblggh4msv6) (https://www.microsoft.com/fr-fr/p/ubuntu/9nblggh4msv6) pour télécharger et installer Ubuntu
## Installation des dépendances
Lancez l'application Ubuntu puis faites la commande suivante :
```
sudo apt-get update
```
Entrez votre mot de passe de session Ubuntu, puis validez
Continuez avec cette commande :
```
sudo apt-get -y install git
```

Clonez ensuite ce dépot `git clone https://github.com/BenoitAnastay/LibreLink-xDrip-Patch.git`
Puis metez le fichier APK de l'application original dans le dossier `APK` (téléchargable ici : https://apkpure.com/de/freestyle-librelink-de/com.freestylelibre.app.de/download/4751-APK)

## Génération du fichier patché
Changez de dossier si cela n'est pas déjà fait 
```
cd LibreLink-xDrip-Patch
```
Puis generez le fichier en lancant le script suivant
```
sudo /bin/bash ./patch.sh
```


Le fichier devrait se generer après un temps et devrait être copier dans un dossier à la racine de votre disque C

## WIP

Ce README n'est pas complet, si vous avez la moindre difficulté vous pouvez ouvrir un ticket dans l'onglet issues de github, toute personne aillant une maitrise de l'outil est invité a faire un PR