#!/bin/sh
set -eu
export MASK_HOST=$(ruby -ruri -e 'puts URI.parse(ENV["DATABASE_URL"]).host')
export MASK_USER=$(ruby -ruri -e 'puts URI.parse(ENV["DATABASE_URL"]).userinfo' | cut -d ':' -f 1)
export MASK_PORT=$(ruby -ruri -e 'puts URI.parse(ENV["DATABASE_URL"]).port || 3306')
export MASK_PASSWORD=$(ruby -ruri -e 'puts URI.parse(ENV["DATABASE_URL"]).userinfo' | cut -d ':' -f 2)
export SOURCE_DB=$(ruby -ruri -e 'puts URI.parse(ENV["DATABASE_URL"]).path.delete("/")')
export MASK_DB=${SOURCE_DB}_mask

mysql -uroot -hdb -ppassword -e "CREATE DATABASE $MASK_DB"
mysqldump -u$MASK_USER -h$MASK_HOST -P$MASK_PORT -p$MASK_PASSWORD $SOURCE_DB | mysql -uroot -hdb -ppassword $MASK_DB
curl $MASK_SETTING_YAML_URL > db_mask_sensitive_data.yml
bundle exec ruby mask_sensitive_data
mysqldump -uroot -hdb -ppassword $MASK_DB > masked.dump
echo $GS_UTIL_KEY_FILE > gs.key
gcloud auth activate-service-account --key-file=gs.key
gcloud config set project $GCP_PROJECT_NAME
gsutil cp masked.dump gs://$BUCKET_NAME/$OBJECT_NAME
