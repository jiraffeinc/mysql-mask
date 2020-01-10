#!/bin/sh
export HOST=$(ruby -ruri -e 'puts URI.parse(ENV["PRODUCTION_DATABASE_URL"]).host')
export USER=$(ruby -ruri -e 'puts URI.parse(ENV["PRODUCTION_DATABASE_URL"]).userinfo' | cut -d ':' -f 1)
export PORT=$(ruby -ruri -e 'puts URI.parse(ENV["PRODUCTION_DATABASE_URL"]).port || 3306')
export PASSWORD=$(ruby -ruri -e 'puts URI.parse(ENV["PRODUCTION_DATABASE_URL"]).userinfo' | cut -d ':' -f 2)
export DB=$(ruby -ruri -e 'puts URI.parse(ENV["PRODUCTION_DATABASE_URL"]).path.delete("/")')

echo $PRODUCTION_GS_UTIL_KEY_FILE > gs.key
gcloud auth activate-service-account --key-file=gs.key
mysqldump -u$USER -h$HOST -P$PORT -p$PASSWORD $DB > mysql.dump
gsutil cp mysql.dump $PRODUCTION_DUMP_OBJECT_URL

