#!/usr/bin/sh
####################################################################################################
# Purpose of this script is to run all the .sql files in a given location                           #
# Input 1: Source directory                                                                        # 
# Input 2: sudo user                                                                               #
#                                                                                                  #                       
#                                                                                                  #
#                                                                                                  #
# Usage: run_all_scripts.sh <absolute path to script folder> <sudo username>                       #
#                                                                                                  #
#                                                                                                  #
####################################################################################################

#Variable to store timestamp at start of execution
dt=`date +'%d%m%y%H%M%S'`

#Varialble to sotre log file location and name
log_dir="/home/ubuntu/Data-Recon/db_scripts/log/$dt.txt"

#Create log file
touch $log_dir
chmod 777 $log_dir
export_data=0
run_qry=false

#Parse the input arguments using flags
for flag in "$@"
do
	case "${flag}" in
	-p|--script_path) 
		script_path=$2
		echo "`date +'%H:%M:%S'`|Scripts source path: $script_path">>$log_dir
		shift
		shift
		;;
	-u|--user) 
		sudo_user=$2
		echo "`date +'%H:%M:%S'`|Sudo user: $sudo_user">>$log_dir
		shift
		shift
		;;
	-q|--query) 
		qry=$2
		run_qry=true
		echo "`date +'%H:%M:%S'`|Query: $qry">>$log_dir
		shift
		shift
		;;
	-f|--out_path) 
		out_loc="$2"
		echo "`date +'%H:%M:%S'`|File export path: $out_loc">>$log_dir
		shift
		shift
		;;
	-e)
		export_data=1
		shift
		;;
	esac
done
echo $run_qry
#qry="\\copy (select * from fileservice.app_30_55)to '$out_loc' with delimiter ','"
if [ $export_data==1 ]
then
	#echo "Exporting data"
	qry="copy ($qry) to '$out_loc' with delimiter ','"
	echo ${qry}>>$log_dir
fi
#Start execution as postgres
cd $script_path
#exit 1

echo "`date +'%H:%M:%S'`|Username: $(whoami)" >> $log_dir
echo "`date +'%H:%M:%S'`|Starting all script execution" >> $log_dir
echo "`date +'%H:%M:%S'`|Executing scripts from $script_path" >> $log_dir

#File path is mentioned run all scripts in the path
if [ -n "$script_path" ]
then 
#	echo 'In script path'
	for f in *.sql;
	do
		echo "-------------------------------------------------------------------------------------------------------------------" >> $log_dir
		echo "`date +'%H:%M:%S'`|Executing script $f" >> $log_dir
		echo >> $log_dir
		echo `sudo -u $sudo_user -i psql -d db_dataRecon -f $script_path/$f` >> $log_dir
		echo >> $log_dir
		echo "`date +'%H:%M:%S'`|Execution competed" >> $log_dir
		echo "-------------------------------------------------------------------------------------------------------------------" >> $log_dir
	done
fi

#Query is sent via arguments
if [ $run_qry ]
then
#	echo 'User query'
	echo "-------------------------------------------------------------------------------------------------------------------" >> $log_dir
	echo "`date +'%H:%M:%S'`|Executing query \"$qry\"" >> $log_dir
	echo `sudo -u $sudo_user -i psql -d db_dataRecon -c "$qry" --output=${out_loc}`>>$log_dir
	echo "`date +'%H:%M:%S'`|Execution competed" >> $log_dir
	echo "-------------------------------------------------------------------------------------------------------------------" >> $log_dir
fi
echo "`date +'%H:%M:%S'`|Completed all script execution" >> $log_dir
