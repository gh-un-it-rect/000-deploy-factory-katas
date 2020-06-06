 #!/bin/bash
####################################################
#
# Params
# $1 = Nombre del Repositorio + Candidato
#
# Ejemplo
# sh deploy.sh 'hashing -aes-256-'
####################################################

MAESTRO="<[^_^]>! => "
echo "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
pwd
ls -ltra
chmod +x cipher-decrypt.sh
ls -ltra
echo $1
echo $__CIPHER_KEY__
cat ./cipher-decrypt.sh
NEW_REPO_NAME=echo $(echo $1 | openssl enc -aes-256-cbc -md sha256 -a -d -salt -pass pass:$__CIPHER_KEY__)
echo "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"

BASE_REPO_NAME=$(echo "$NEW_REPO_NAME" | awk -F'-' '{print $1}')
if [ "$NEW_REPO_NAME" = "echo" ]; then
     exit -1
fi


TYPE_REPO_NAME=$(echo "$NEW_REPO_NAME" | awk -F'-' '{print $2}')
FOLDER_URL=${BASE_REPO_NAME}-${TYPE_REPO_NAME}
URL_MASTER=https://github.com/${__ORG_DEPLOY__}/${FOLDER_URL}.git
COMMIT="Reset Repo"

####################################################
#
# Muestra los valores que vienen como parámetros de la función
#
####################################################
#function __debug__ {
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
 	echo -e "ORG_TARGET:\t\t $__ORG_TARGET_IT_RECT__"
	echo ""
#}

#function __preExecute__  {
	time=$(date +%s%N)
	curl -v -X DELETE -H "Authorization: token $__TOKEN_GITHUB__" https://api.github.com/repos/${__ORG_TARGET_IT_RECT__}/${NEW_REPO_NAME}
	echo -e "\e[42;1m Runtime [PreExecute]: $(echo "scale=3;($(date +%s%N) -  ${time})/(1*10^09)" | bc) seconds"	
#}

####################################################
#
# Copia el repo del origen maestro y lo crea en la cuenta de Destino
#
####################################################
#function __execute__ {	
	time=$(date +%s%N)
	curl -i -H "$__PREVIEW__" -H "$__JSON__" -H "Authorization: token $__TOKEN_GITHUB__" -d "$__BODY_OK__" https://api.github.com/repos/$__ORG_DEPLOY__/$FOLDER_URL
	curl -v -H "Authorization: token ${__TOKEN_GITHUB__}" https://api.github.com/orgs/${__ORG_TARGET_IT_RECT__}/repos -d '{"name": "'"${NEW_REPO_NAME}"'"}' 
	git clone ${URL_MASTER} 
	rm -Rf  ${NEW_REPO_NAME}
	mv ${FOLDER_URL} ${NEW_REPO_NAME}
	cd ${NEW_REPO_NAME}
	rm -Rf .git 
	git init 
	git add -A  
	git remote add origin https://$__TOKEN_GITHUB__@github.com/${__ORG_TARGET_IT_RECT__}/${NEW_REPO_NAME}.git 
	git commit -m "${COMMIT}"
	git push --quiet --set-upstream origin master 
	git checkout -b develop 
	git push --quiet --set-upstream origin develop 
	git checkout -b test
	git push --quiet --set-upstream origin test 
	
	echo -e " \e[42;1m ${MAESTRO} Ejecución satisfactoria ${NEW_REPO_NAME}"

	curl -i -H "$__PREVIEW__" -H "$__JSON__" -H "Authorization: token $__TOKEN_GITHUB__" -d "$__BODY_KO__" https://api.github.com/repos/$__ORG_DEPLOY__/$FOLDER_URL
	echo -e " \e[42;1m Runtime [__execute__]: $(echo "scale=3;($(date +%s%N) -  ${time})/(1*10^09)" | bc) seconds"	    	
#}

#function __main__ {
#    __debug__
#    __preExecute__
#    __execute__
#}

#__main__
