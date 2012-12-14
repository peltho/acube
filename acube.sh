###############################################################
###############################################################
#########                                            ##########
#########               ACUBE_V1.2                   ##########
#########                                            ##########
#########   Script lancement d'AssaultCube en bash.  ##########
#########   Permet de sauver/charger votre config    ##########
#########   automatiquement sur n'importe quel PC !  ##########
#########                                            ##########
#########                             ©PELTHO/KRINAH ##########
###############################################################
###############################################################

#!/bin/bash

LOCAL_SAVE=$HOME/.assaultcube*                                      # Répertoire de sauvegarde local
DIR_SAVE=$HOME/net-home/                                            # Répertoire de sauvegarde "distant"
DIR_ASSAULTCUBE=$(find $HOME -name 'assaultcube.sh' | sed "s/\(.*\)\/.*/\1/")          # Dossier du jeu
DIR_TAR_ASSAULTCUBE=$(find $HOME -name 'AssaultCube*.bz2' | sed "s/\(.*\)\/.*/\1/")    # Dossier de l'archive
SLOT_MAX=6
SERVER_NAME="SERVEUR IUT"
TAILLE=$(tput cols)

function aligner {
    echo $1 | sed -e :a -e 's/^.\{1,78\}$/ & /;ta'
    #echo $1 | sed -e :a -e "s/^.\{1, $TAILLE-2  \}$/ & /;ta"

} # aligner()

function ligne {
    for ((i=1;i<$TAILLE+1;i++))
    do
      printf "#"
    done

} # ligne()

function quitter {
    clear
    ligne
    aligner "©PELTHO/KRINAH"
    ligne
    echo -e "\n"
    exit 1

} # quitter()

function lancer_jeu {
    if [ -d $DIR_ASSAULTCUBE ]; then                                # Si le dossier d'AssaultCube existe on peut continuer
        if [ -d $DIR_SAVE/.assaultcube* ]; then                     # S'il existe une sauvegarde dans le dossier "distant"
            cp -r $DIR_SAVE/.assaultcube* $HOME                     # Charge la sauvegarde distante
        fi
        sh $DIR_ASSAULTCUBE/assaultcube.sh &                        # Lancement du jeu
        wait $!                                                     # Attente de fermeture du jeu
        cp -r $LOCAL_SAVE $DIR_SAVE                                 # Enregistre la config dans le dossier "distant"
        clear
        ligne
        aligner "SUCCESS: Configuration sauvegardée dans $DIR_SAVE"
        ligne
    fi

} # lancer_jeu()

function lancer_serveur {
    if [ -n $DIR_ASSAULTCUBE ]; then                                # Si le dossier du jeu existe
        cd $DIR_ASSAULTCUBE
        xterm -e "sh server.sh -c$SLOT_MAX -n\"$SERVER_NAME\"" &
    fi
} # lancer_serveur()

function menu_config {
   select choix2 in \
   "Nombre joueurs max (Defaut: 6)" \
   "Nom serveur (Defaut : SERVEUR IUT)" \
   "Retour"
    do
    case $REPLY in
        1) echo -e "\nEntrez une valeur (6-20) : "
           read -p "> " SLOT_MAX ;;
        2) echo -e "\nEntrez un nom de serveur : "
           read -p "> " SERVER_NAME ;;
        3) echo -e "\n Configuration serveur sauvegardée"
           clear
           main_menu
           break ;;
        *) echo "Choisir un chiffre entre 1 et 3" ;;
    esac
    done

} # menu_config()

function main_menu {
    ligne
    aligner "SCRIPT LANCEMENT"
    ligne
    PS3="Que voulez vous faire ? "
    select choix in \
       "Lancer le jeu" \
       "Lancer un serveur et le jeu" \
       "Configurer le serveur" \
       "Quitter"
    do
    case $REPLY in
          1) lancer_jeu
             break ;;
          2) lancer_serveur
             sleep 3
             lancer_jeu
             break ;;
          3) clear
             ligne
             aligner "SERVEUR CONFIG"
             ligne
             menu_config
             break ;;
          4) clear
             quitter
             break ;;
          *) echo "Entrez un chiffre entre 1 et 4 !" ;;
    esac
    done

} # main_menu()

function decompression {
    aligner "Indiquez le dossier de votre choix [$HOME]"
    ligne
    read -p "> " CUSTOMPATH
    if [ -z $CUSTOMPATH ]; then
        CUSTOMPATH=$HOME
    elif [ ! -d $CUSTOMPATH ]; then
        clear
        ligne
        aligner "Le dossier $CUSTOMPATH n'existe pas !"
        ligne
        sleep 2
        quitter
    fi
    clear
    ligne
    aligner "Décompression dans $CUSTOMPATH"
    ligne
    sleep 1
    tar xvjf $DIR_TAR_ASSAULTCUBE/AssaultCube*.bz2 -C $CUSTOMPATH
    clear
    ligne
    aligner "SUCCESS: Archive décompressée dans $CUSTOMPATH"
    ligne
    sleep 2
    clear
    DIR_ASSAULTCUBE=$(find $HOME -name 'assaultcube.sh' | sed "s/\(.*\)\/.*/\1/")
    chmod 755 -R $DIR_ASSAULTCUBE

} # decompression()

if [ -z $DIR_ASSAULTCUBE ]; then                                    # Pas de dossier AssaultCube
    if [ -z $DIR_TAR_ASSAULTCUBE ]; then
        ligne
        aligner "AssaultCube non détecté !"
        aligner "Voulez-vous télécharger le jeu? [y/n]"
        ligne
        read -p "> " choice
        if [ $choice != 'y' ]; then
            quitter
        fi
        wget http://downloads.sourceforge.net/project/actiongame/AssaultCube%20Version%201.1.0.4/AssaultCube_v1.1.0.4.tar.bz2
        clear
        DIR_TAR_ASSAULTCUBE=$(find $HOME -name 'AssaultCube*.bz2' | sed "s/\(.*\)\/.*/\1/")
        ligne
        aligner "Archive téléchargée, où voulez-vous la décompresser ?"
        decompression
    else
        ligne
        aligner "Vous devez decompresser AssaultCube !"
        DIR_TAR_ASSAULTCUBE=$(find $HOME -name 'AssaultCube*.bz2' | sed "s/\(.*\)\/.*/\1/")
        decompression
    fi
fi

main_menu
