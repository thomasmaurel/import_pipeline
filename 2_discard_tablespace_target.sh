#!/bin/bash
# Discard transportable tablespace on target server

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
TABLES=$(mysql $($HOST2 details mysql)  --column-names=false information_schema -e "select table_name from TABLES where TABLE_SCHEMA='$DATABASE'")
for table in $TABLES
do
      echo -n " * Discarding tablespace for table: $table ... "
      $(mysql $($HOST2 details mysql) $DATABASE -e "ALTER TABLE $table DISCARD TABLESPACE;")
      
done
