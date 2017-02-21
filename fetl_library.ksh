#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Function library
# S0F0 - 
# ----------------------------------------------------------------------------------------------

# message function
# 2 parameters : 
# p1 = severity,  p2 = errno, p3 = message text
#
function _message
{
# On affiche un message format
	echo "$(date +'%Y-%m-%d %H:%M:%S.000')|${1}${2}|$(basename $0 .ksh)|$3"

# On sort du shell si erreur

	if [ "$1" = "E" ]
	then
		if [ ! -z "$4" -a "$4" = "1" ]
		then
			_set_error_file
			exit 1
		else
			exit 1
		fi
	fi

# exit
	return 0
}


# function to generate an error file
# No parameter
function _set_error_file
{
	echo "Job is aborted before launch binary" >${FETL_TMP}/${FETL_BASE_NAME_JOB}.${FETL_JOB_ID}.00.${FETL_LAUNCHER_TS_START}.off
	date +'%s' >${FETL_GRP_END}
	return 0
}


# function to use context job
# p1 = Context file
# p2 = parameter line
# p3 = fichier resultat
function _set_parameter_from_context
{
# check up
	if [ $# -ne 3 -o ! -f ${1} -o -z "${2}" ]
	then
		return 1
	fi
	
# Traitment
	_file=${1}
	_line="${2}"
	_oufile=${3}
	
	echo ${_line} >${_oufile}	
	cat ${_file} | grep "^${FETL_STRING_CONTEXT}" | awk -F'|' '{print $2" "$3}' | while read p value
	do
	# Sourcing	
		_line=$(cat ${_oufile} | sed "s/#${p}#/${value}/g")
		echo ${_line} >${_oufile}
	done
		
# Check up
	if [ -z "$(cat ${_oufile})" -o "$(cat ${_oufile})" = "" -o ! -s ${_oufile} ]
	then
		return 2
	fi

# exit
	return 0 	

}


# function to execute before component launch
# p1 = component number
# p2 = component type
function _pre_fetl_hash_file
{
# Search hash desc value file
	_value=$(grep ^"${1}|" ${FETL_FULL_PATH_JOB} | awk -F'|' '($4=="H" || $4 == "HASH_DESC"){print $5}')
	if [ -z "${_value}" -o "${_value}" = "" ]
	then
		return 1
	fi
	_value=$(eval echo "${_value}")
	
# Hash descriptor delete
	if [ -f ${_value} ]
	then
		/bin/rm -f ${_value}
		if [ $? -ne 0 ]
		then
			return 2
		fi
	fi
# exit
	return 0
}

# function to execute before component launch
# p1 = component number
# p2 = component type
function _pre_fetl_hash_index
{
# Search hash desc value file
	_value=$(grep ^"${1}|" ${FETL_FULL_PATH_JOB} | awk -F'|' '($4=="H" || $4 == "HASH_DESC"){print $5}')
	if [ -z "${_value}" -o "${_value}" = "" ]
	then
		return 1
	fi
	_value=$(eval echo "${_value}")
	
# Hash descriptor delete
	if [ -f ${_value} ]
	then
		/bin/rm -f ${_value}
		if [ $? -ne 0 ]
		then
			return 2
		fi
	fi
# exit
	return 0
}
