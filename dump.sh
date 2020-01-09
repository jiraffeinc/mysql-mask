#!/bin/sh
export SOURCE_HOST=$(ruby -ruri -e 'puts URI.parse(ENV["DATABASE_URL"]).host')
export SOURCE_USER=$(ruby -ruri -e 'puts URI.parse(ENV["DATABASE_URL"]).userinfo' | cut -d ':' -f 1)
export SOURCE_PORT=$(ruby -ruri -e 'puts URI.parse(ENV["DATABASE_URL"]).port || 3306')
export SOURCE_PASSWORD=$(ruby -ruri -e 'puts URI.parse(ENV["DATABASE_URL"]).userinfo' | cut -d ':' -f 2)
export SOURCE_DB=$(ruby -ruri -e 'puts URI.parse(ENV["DATABASE_URL"]).path.delete("/")')

mysqldump -u$SOURCE_USER -h$SOURCE_HOST -P$SOURCE_PORT -p$SOURCE_PASSWORD $SOURCE_DB > mysql.dump
echo $GS_UTIL_KEY_FILE > gs.key
gcloud auth activate-service-account --key-file=gs.key
gcloud config set project $GCP_PROJECT_NAME
gsutil cp mysql.dump gs://$BUCKET_NAME/mysql.dump
