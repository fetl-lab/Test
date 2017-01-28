#!/bin/bash
# Upload Github
# hive execution file
function fwk_hive_exec_sql()
{
# check parameter
	if [ $# -ne 5 ]
	then
		fwk_gen_msg E F 
	fi

# Set Parameter
	FWK_APP_HIVE_HOST=${1}
	FWK_APP_HIVE_PORT=${2}
	FWK_APP_HIVE_USER=${3}
	FWK_APP_HIVE_PASS=${4}
	FWK_APP_HIVE_FILE=${5}
	
# Run ExecFile
	fwk_gen_msg I F ${0} "Démarrage ${5}"
	beeline -u "jdbc:hive2://${FWK_APP_HIVE_HOST}:${FWK_APP_HIVE_PORT}/" -n "${FWK_APP_HIVE_USER}" -p "${FWK_APP_HIVE_PASS}" -f "${FWK_APP_HIVE_FILE}" 
	fwk_gen_msg I F ${0} "Fin Script HIVE -  $?"

# normal exit
	return 0
}


# hive function to load HDFS structured file in hive structured table 
# P1 = HDFS File
# P2 = Target Table
# P3 = Separator
function fwk_hive_load_struct_data()
{
# Temporary table creation as target table

# Insert into temporary Parsing Data with reject

# 

}
