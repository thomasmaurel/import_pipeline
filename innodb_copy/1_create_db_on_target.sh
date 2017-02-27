#!/bin/bash
# Create an empty database using schema from host onto host2

function usage {
  echo "Usage: $0 -h host -d database -s host2"
  echo "With -h MySQL server host, -d database to be backed up, -s MySQL server host2"
}

function die {
    err=$1
    shift
    msg $@
    exit $err
}

# parse cli
OPTIND=1
while getopts "h:s:d:e" opt; do
    case "$opt" in
    h)  HOST=$OPTARG
        ;;
    s) HOST2=$OPTARG
        ;;
    d)  DATABASE=$OPTARG
        ;;
    esac
done
if [ -z "$HOST" ]; then
    usage
    die 1 "MySQL server host1 not specified!"
fi
if [ -z "$HOST2" ]; then
    usage
    die 1 "MySQL server host2 not specified!"
fi
if [ -z "$DATABASE" ]; then
    usage
    die 1 "MySQL server database not specified!"
fi

#DB tables on source server
TABLES=$(mysql $($HOST details mysql) --column-names=false information_schema -e "select table_name from TABLES where TABLE_SCHEMA='$DATABASE'")
#Create db on target server
$(mysql $($HOST2 details mysql) --column-names=false -e "CREATE DATABASE $DATABASE")
for table in $TABLES
do
echo -n " * Creating table: $table ... "
#Get create table statement from source server
CREATETABLE=$(mysql $($HOST details mysql) --silent --column-names=false $DATABASE -e "SHOW CREATE TABLE $table" | sed "s/^$table//" | sed 's/\\n//g')
#Create table on source server
$(mysql $($HOST2 details mysql) --column-names=false $DATABASE -e "$CREATETABLE")
done
