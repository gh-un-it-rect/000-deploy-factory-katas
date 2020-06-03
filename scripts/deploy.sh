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
echo "  -------------------------------------------------------------   "$1
BASE_REPO_NAME=$(echo $1 | awk -F'-' '{print $1}')
TYPE_REPO_NAME=$(echo $1 | awk -F'-' '{print $2}')
FOLDER_URL=${BASE_REPO_NAME}-${TYPE_REPO_NAME}
NEW_REPO_NAME=$1
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
	(set -Ee
	local time=$(date +%s%N)
	local _f_=${FUNCNAME[0]}
        function _try {     
            curl -i -H "$__PREVIEW__" -H "$__JSON__" -H "Authorization: token $__TOKEN_GITHUB__" -d "$__BODY_OK__" https://api.github.com/repos/$__ORG_DEPLOY__/$FOLDER_URL

            curl -v -H "Authorization: token '${__TOKEN_GITHUB__}'" https://api.github.com/orgs/${ORG_TARGET_IT_RECT}/repos -d '{"name": "'"${NEW_REPO_NAME}"'"}' 

            git clone ${URL_MASTER} 
            rm -Rf  ${NEW_REPO_NAME}
            mv ${FOLDER_URL} ${NEW_REPO_NAME}
            cd ${NEW_REPO_NAME}
            rm -Rf .git 
            git init 
            git add -A  
            git remote add origin https://$__TOKEN_GITHUB__@github.com/${ORG_TARGET_IT_RECT}/${NEW_REPO_NAME}.git 
            git commit -m "${COMMIT}" 
            git push --quiet --set-upstream origin master 
            git checkout -b develop 
            git push --quiet --set-upstream origin develop 
            git checkout -b test 
            git push --quiet --set-upstream origin test 
      
            echo -e " \e[42;1m ${MAESTRO} Ejecución satisfactoria ${NEW_REPO_NAME}"
        } 

        function __CATCH__ {
            echo "ERROR ***> La ejecucion ${_f_} ha fallado"
        }

        function _finally {	
            curl -i -H "$__PREVIEW__" -H "$__JSON__" -H "Authorization: token $__TOKEN_GITHUB__" -d "$__BODY_KO__" https://api.github.com/repos/$__ORG_DEPLOY__/$FOLDER_URL
	    echo -e " \e[42;1m Runtime ["$_f_"]: $(echo "scale=3;($(date +%s%N) -  ${time})/(1*10^09)" | bc) seconds"	
        }
		
        trap __CATCH__ ERR
        trap _finally EXIT
        _try
    )
	
}

function __preExecute__  {
    (set -Ee
	local time=$(date +%s%N)
	local _f_=${FUNCNAME[0]}
        function _try {    
	    curl -v -X DELETE -H "Authorization: token '$__TOKEN_GITHUB__'" "https://api.github.com/repos/${ORG_TARGET_IT_RECT}/${NEW_REPO_NAME}"
	} 

        function __CATCH__ {
            echo "ERROR ***> La ejecucion ${_f_} ha fallado"
        }

        function _finally {	
            curl -i -H "$__PREVIEW__" -H "$__JSON__" -H "Authorization: token $__TOKEN_GITHUB__" -d "$__BODY_KO__" https://api.github.com/repos/$__ORG_DEPLOY__/$FOLDER_URL
	    echo -e " \e[42;1m Runtime ["$_f_"]: $(echo "scale=3;($(date +%s%N) -  ${time})/(1*10^09)" | bc) seconds"	
        }
		
        trap __CATCH__ ERR
        trap _finally EXIT
        _try
    )
}

function __main__ {
    __debug__
    __preExecute__
    __execute__
}

__main__
