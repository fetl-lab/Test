#!/bin/bash
# Dameon scrutant les demandes de lancement y u
# envoi github 666

# On source l'environnement
. ${FETL_HOME}/.fetl_env
. ${FETL_KSH}/fetl_library.ksh

function fetl_launch
{
#Verification presence d'une demande de lancement

	
	msg_file=$(ls ${FETL_MSG}/${FETL_MSG_START_FILE}.*.in 2>/dev/null| head -1)
	
	if [ -z "${msg_file}" ]
	then
		return 0
	fi
	_fetl_p=$(head -1 ${msg_file} | awk -F'|' '{print $1}')
	_fetl_m=$(head -1 ${msg_file} | awk -F'|' '{print $2}')
	_fetl_j=$(head -1 ${msg_file} | awk -F'|' '{print $3}')
	_fetl_t=$(head -1 ${msg_file} | awk -F'|' '{print $4}')  # Timestamp de lancement du job
	_fetl_x=$(head -1 ${msg_file} | awk -F'|' '{print $5}')  # Contexte d'execution du job
	_fetl_i=$(echo $msg_file | awk -F'.' '{print $(NF-1)}')  # Job id (id unique du job)
	
# Si demande invalide, rejet de la demande
# Si demande valide, lancement en tâche de fond du lanceur
#@TODO : ajouter contrôle sur contexte
	
	if [ -z "${_fetl_p}" -o -z "${_fetl_m}" -o -z "${_fetl_j}" -o -z "${_fetl_t}" -o -z "${_fetl_x}" ]
	then
		rej_file=${FETL_MSG}/$(basename $msg_file .in).ko
		mv ${msg_file} ${rej_file}
		if [ $? -ne 0 ]
		then
		  _message I 0205 "Failure to rename ${msg_file}"  >>${FETL_DAMEON_LOG}
		else
		  _message I 0206 "File ${msg_file} is successfuly renamed because error" >>${FETL_DAMEON_LOG}
		fi
		return 1
	else
		export _fetl_i
		export _fetl_t
		response_file=${FETL_MSG}/$(basename $msg_file .in).ok

# On appelle le lanceur
		${FETL_KSH}/fetl_lanceur.ksh ${_fetl_p} ${_fetl_m} ${_fetl_j} ${_fetl_x} >>${FETL_DAMEON_LOG} &
		if [ $? -ne 0 ]
		then
		  _message I 0207 "Failure to launch fetl_lanceur.ksh with ${_fetl_p} ${_fetl_m} ${_fetl_j} parameters"
		else
		  mv ${msg_file} ${response_file}
		  if [ $? -ne 0 ]
		  then
		    _message I 0201 "Failure to rename ${msg_file} to ${response_file}" >>${FETL_DAMEON_LOG}
		    _message I 0208 "Fatal error on deamon - Stop"
		    exit 1
		  else
        _message I 0200 "Sending launcher request with ${_fetl_p} ${_fetl_m} ${_fetl_j} ${_fetl_x}" >>${FETL_DAMEON_LOG}
      fi
		fi
	fi
	return 0
}


# To stop a job
function fetl_kill
{
# Check stop request
	msg_file=$(ls ${FETL_MSG}/${FETL_MSG_STOP_FILE}.*.in 2>/dev/null| head -1)
	
	if [ -z "${msg_file}" ]
	then
		return 0
	fi
	
# A request exists
	_fetl_p=$(head -1 ${msg_file} | awk -F'|' '{print $1}')
	_fetl_m=$(head -1 ${msg_file} | awk -F'|' '{print $2}')
	_fetl_j=$(head -1 ${msg_file} | awk -F'|' '{print $3}')
	_fetl_t=$(head -1 ${msg_file} | awk -F'|' '{print $4}')  # Timestamp de lancement du job
	_fetl_i=$(echo $msg_file | awk -F'.' '{print $(NF-1)}')  # Job id (id unique du job)

# we get the PID file and kill the process
	touch "${FETL_TMP}/$(basename ${_fetl_j} .run).${_fetl_i}.${FETL_ID_JOB_STOP}.${_fetl_t}.off"
	if [ $? -ne 0 ]
	then
		_message I 0210 "Failure to create stop request" >>${FETL_DAMEON_LOG}
		_message I 0211 "Fatal error on deamon - Stop"
		exit 1
	else
		_message I 0212 "Sending stop request for ${_fetl_p} ${_fetl_m} ${_fetl_j}" >>${FETL_DAMEON_LOG}
	fi 
	
# The stop request is send, we rename 
	response_file=${FETL_MSG}/$(basename $msg_file .in).ok
	mv ${msg_file} ${response_file}
	if [ $? -ne 0 ]
	then
		_message I 0213 "Failure to rename ${msg_file} to ${response_file}" >>${FETL_DAMEON_LOG}
		_message I 0214 "Fatal error on deamon - Stop"
		exit 1
	else
		_message I 0215 "Sending stop request is ok for ${_fetl_p} ${_fetl_m} ${_fetl_j}" >>${FETL_DAMEON_LOG}
	fi 	
	
# Exit
	return 0
}

# main

	_message I 0204 "FETL deamon is started - Listening request ..." >>${FETL_DAMEON_LOG}
	while [ "1" = "1" ]
	do
			fetl_launch
			fetl_kill
			sleep ${FETL_SLEEP_DAMEON}
			if [ -f ${FETL_MSG}/${FETL_STOP_DAMEON} ]
			then
				/bin/rm ${FETL_MSG}/${FETL_STOP_DAMEON} 
				_message I 0202 "Stopping FETL dameon." >>${FETL_DAMEON_LOG}
				exit 0
			fi
	done
