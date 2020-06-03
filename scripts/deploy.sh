 #!/bin/bash
####################################################
#
# Params
# $1 = Nombre del Repositorio + Candidato
#
# Ejemplo
# sh deploy.sh '100-tj-XXXX'
####################################################

MAESTRO="<[^_^]>! => "
echo "  -------------------------------------------------------------   $1"
BASE_REPO_NAME=$(echo "$1" | awk -F'-' '{print "$1"}')
TYPE_REPO_NAME=$(echo "$1" | awk -F'-' '{print "$2"}')
FOLDER_URL=${BASE_REPO_NAME}-${TYPE_REPO_NAME}
NEW_REPO_NAME="$1"
URL_MASTER=https://github.com/${__ORG_DEPLOY__}/${FOLDER_URL}.git
COMMIT="Reset Repo"
ORG_TARGET=$__ORG_TARGET_IT_RECT__


####################################################
#
# Muestra los valores que vienen como parámetros de la función
#
####################################################
function __debug__ {
	echo "PRINT VALUES"
	echo ""
	echo -e "BASE_REPO_NAME:\t\t ${BASE_REPO_NAME}"
	echo -e "TYPE_REPO_NAME:\t\t ${TYPE_REPO_NAME}"
	echo -e "NEW_REPO_NAME:\t\t ${NEW_REPO_NAME}"
	echo ""
	echo -e "TOKEN_GITHUB:\t\t ${__TOKEN_GITHUB__}"
	echo -e "URL_MASTER:\t\t ${URL_MASTER}"
	echo -e "COMMIT:\t\t\t ${COMMIT}"
	echo -e "FOLDER_URL:\t\t ${FOLDER_URL}"
 	echo -e "ORG_TARGET:\t\t ${ORG_TARGET}"
	echo ""
}
####################################################
#
# Copia el repo del origen maestro y lo crea en la cuenta de Destino
#
####################################################
function __execute__ {	
	echo "__execute__"
	time=$(date +%s%N)
	echo $time
	_f_="__execute__"
	echo _f_
	curl -i -H "$__PREVIEW__" -H "$__JSON__" -H "Authorization: token $__TOKEN_GITHUB__" -d "$__BODY_OK__" https://api.github.com/repos/$__ORG_DEPLOY__/$FOLDER_URL
	echo 2
	curl -v -H "Authorization: token '${__TOKEN_GITHUB__}'" https://api.github.com/orgs/${ORG_TARGET_IT_RECT}/repos -d '{"name": "'"${NEW_REPO_NAME}"'"}' 
	echo 3
	git clone ${URL_MASTER} 
	echo 4
	rm -Rf  ${NEW_REPO_NAME}
	echo 5
	mv ${FOLDER_URL} ${NEW_REPO_NAME}
	echo 6
	cd ${NEW_REPO_NAME}
	echo 7
	rm -Rf .git 
	echo 8
	git init 
	echo 9
	git add -A  
	echo 10
	git remote add origin https://$__TOKEN_GITHUB__@github.com/${ORG_TARGET_IT_RECT}/${NEW_REPO_NAME}.git 
	echo 11
	git commit -m "${COMMIT}"
	echo 12
	git push --quiet --set-upstream origin master 
	echo 13
	git checkout -b develop 
	echo 14
	git push --quiet --set-upstream origin develop 
	echo 15
	git checkout -b test
	echo 16
	git push --quiet --set-upstream origin test 
	echo 17

	echo -e " \e[42;1m ${MAESTRO} Ejecución satisfactoria ${NEW_REPO_NAME}"

	curl -i -H "$__PREVIEW__" -H "$__JSON__" -H "Authorization: token $__TOKEN_GITHUB__" -d "$__BODY_KO__" https://api.github.com/repos/$__ORG_DEPLOY__/$FOLDER_URL
	echo -e " \e[42;1m Runtime ["$_f_"]: $(echo "scale=3;($(date +%s%N) -  ${time})/(1*10^09)" | bc) seconds"	    	
}

function __preExecute__  {
	echo __execute__
	time=$(date +%s%N)
	echo $time
	_f_="__preExecute__"
	echo _f_	
	curl -v -X DELETE -H "Authorization: token '$__TOKEN_GITHUB__'" "https://api.github.com/repos/${ORG_TARGET_IT_RECT}/${NEW_REPO_NAME}"
	echo 21
        curl -i -H "$__PREVIEW__" -H "$__JSON__" -H "Authorization: token $__TOKEN_GITHUB__" -d "$__BODY_KO__" https://api.github.com/repos/$__ORG_DEPLOY__/$FOLDER_URL
	echo -e " \e[42;1m Runtime ["$_f_"]: $(echo "scale=3;($(date +%s%N) -  ${time})/(1*10^09)" | bc) seconds"	
}

function __main__ {
    __debug__
    __preExecute__
    __execute__
}

__main__
