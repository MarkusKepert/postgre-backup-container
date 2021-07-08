DUMP_FILE_NAME="backupOn`date +%Y-%m-%d-%H-%M`.dump"
echo "Creating dump: $DUMP_FILE_NAME"

backup_date=`date +%d-%m-%Y`
backup_dir=/pg_backup

cd $backup_dir


#Numbers of days you want to keep copie of your databases
number_of_days=3
databases=`psql -l -t | cut -d'|' -f1 | sed -e 's/ //g' -e '/^$/d'`
for i in $databases; do  if [ "$i" != "postgres" ] && [ "$i" != "template0" ] && [ "$i" != "template1" ] && [ "$i" != "template_postgis" ]; then    
    echo Dumping $i to $backup_dir/$i\_$backup_date.sql    
    pg_dump $i > $backup_dir/$i\_$backup_date.sql
    echo bzip $backup_dir/$i\_$backup_date.sql
    bzip2 $backup_dir/$i\_$backup_date.sql
    ln -fs $backup_dir/$i\_$backup_date.sql.bz2 $nightly_dir$i-nightly.sql.bz2

  fi
done

echo Sync to external S3 storage

mc alias set s3target $S3_URL $S3_KEY $S3_SECRET
mc mirror $backup_dir s3target/$S3_BUCKET/prod-postgresql-replicaset/


find $backup_dir -type f -prune -mtime +$number_of_days -exec rm -f {} \;


echo 'Successfully Backed Up'
exit 0