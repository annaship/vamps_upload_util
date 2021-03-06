#!/bin/bash
#
# Export the project and dataset information
#
echo "vamps_upload_ill -e -i -s projectdataset -stop projectdataset vamps"
time vamps_upload_ill -e -i -s projectdataset -stop projectdataset vamps
# Analyzing vamps_projects_datasets_transfer

#
# Export sequences table from env454 
#
echo "vamps_upload_ill -e -skip -s sequences -stop sequences vamps"
time vamps_upload_ill -e -skip -s sequences -stop sequences vamps
# Analyzing vamps_sequences_transfer

#
# Import sequences table into VAMPS
#
echo "vamps_upload_ill -i -skip -s sequences -stop sequences vamps &"
time vamps_upload_ill -i -skip -s sequences -stop sequences vamps &
# Analyzing vamps_sequences_transfer

#
# Export data taxonomy tables
#
echo "vamps_upload_ill -e -i -skip -s taxonomy -stop taxonomy vamps &"
time vamps_upload_ill -e -i -skip -s taxonomy -stop taxonomy vamps &
# sleep 300
# Analyzing vamps_data_cube_transfer
# Analyzing vamps_junk_data_cube_transfer
# Analyzing vamps_taxonomy_transfer

#
# Export the reads and anything else after
#
echo "vamps_upload_ill -e -i -skip -s reads vamps &"
time vamps_upload_ill -e -i -skip -s reads vamps &
# Analyzing vamps_export_transfer
# Analyzing vamps_projects_info_transfer

# check if we done with work before run the next command
echo "CHECK_STATUS before = _"$CHECK_STATUS"_"
CHECK_STATUS=$(jobs | grep "vamps_upload_ill" | grep -v "grep" | grep "Running")
echo "CHECK_STATUS after the checking = _"$CHECK_STATUS"_"

until [ "$CHECK_STATUS" == "" ]
do
  sleep 300
  CHECK_STATUS=$(jobs | grep "vamps_upload_ill" | grep -v "grep" | grep "Running")
  echo "CHECK_STATUS for vamps_upload_ill = $CHECK_STATUS"
done

echo "check_vamps_upload.pl -t"
time check_vamps_upload.pl -t

if [ "$CHECK_STATUS" == "" ]; then
  echo "run vamps_upload_ill to new tables"
  time vamps_upload_ill -e -i -s norm_tables vamps
fi

#echo "rename norm tansfer tables"
#time vamps_upload_ill -i -s rename_norm vamps
# echo add illumina data to current tables
#time vamps_upload_ill -i -s add_illumina vamps

grep -in --color "ERROR" vamps_upload.log
# grep -in --color "failed" vamps_upload.log
echo "=========================="
echo "Manually: Repeat any mysqlimport failed lines if any. Take care of foreign key errors."
echo "NO! rename norm tansfer tables not done. Do that and run_vamps_upload_transfer after. Check. Then run_vamps_upload_ill, check. Then run_vamps_upload_ill_add"
