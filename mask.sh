#!/bin/sh
set -eu
export MASK_DB=_mask
export MASK_HOST=db
export MASK_USER=root
export MASK_PASSWORD=password
export MASK_PORT=3306

echo $PRODUCTION_GS_UTIL_KEY_FILE > gs.key
gcloud auth activate-service-account --key-file=gs.key
gsutil cp $PRODUCTION_DUMP_OBJECT_URL . 

echo $BACKUP_GS_UTIL_KEY_FILE > gs.key
gcloud auth activate-service-account --key-file=gs.key

mysql -u$MASK_USER -h$MASK_HOST -p$MASK_PASSWORD -e "CREATE DATABASE $MASK_DB" || true
mysql -u$MASK_USER -h$MASK_HOST -p$MASK_PASSWORD $MASK_DB < mysql.dump
rm -f mysql.dump
curl $MASK_SETTING_YAML_URL > db_mask_sensitive_data.yml
bundle exec ruby mask_sensitive_data
mysqldump -u$MASK_USER -h$MASK_HOST -p$MASK_PASSWORD $MASK_DB > masked.dump

gsutil cp masked.dump $BACKUP_DUMP_OBJECT_URL
mysql -u$MASK_USER -h$MASK_HOST -p$MASK_PASSWORD -e "DROP DATABASE $MASK_DB" || true
