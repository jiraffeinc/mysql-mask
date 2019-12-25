#!/bin/sh
set -eu
export SOURCE_HOST=$(ruby -ruri -e 'puts URI.parse(ENV["DATABASE_URL"]).host')
export SOURCE_USER=$(ruby -ruri -e 'puts URI.parse(ENV["DATABASE_URL"]).userinfo' | cut -d ':' -f 1)
export SOURCE_PORT=$(ruby -ruri -e 'puts URI.parse(ENV["DATABASE_URL"]).port || 3306')
export SOURCE_PASSWORD=$(ruby -ruri -e 'puts URI.parse(ENV["DATABASE_URL"]).userinfo' | cut -d ':' -f 2)
export SOURCE_DB=$(ruby -ruri -e 'puts URI.parse(ENV["DATABASE_URL"]).path.delete("/")')

export MASK_DB=${SOURCE_DB}_mask
export MASK_HOST=db
export MASK_USER=root
export MASK_PASSWORD=password
export MASK_PORT=3306

mysql -u$MASK_USER -h$MASK_HOST -p$MASK_PASSWORD -e "CREATE DATABASE $MASK_DB" || true
mysqldump -u$SOURCE_USER -h$SOURCE_HOST -P$SOURCE_PORT -p$SOURCE_PASSWORD $SOURCE_DB | mysql -u$MASK_USER -h$MASK_HOST -p$MASK_PASSWORD $MASK_DB
curl $MASK_SETTING_YAML_URL > db_mask_sensitive_data.yml
bundle exec ruby mask_sensitive_data
mysqldump -u$MASK_USER -h$MASK_HOST -p$MASK_PASSWORD $MASK_DB > masked.dump

echo $GS_UTIL_KEY_FILE > gs.key
gcloud auth activate-service-account --key-file=gs.key
gcloud config set project $GCP_PROJECT_NAME
gsutil cp masked.dump gs://$BUCKET_NAME/$OBJECT_NAME
