# mysql-mask

MySQL database dump and mask sensitive data according to yaml settings and put it to Google Cloud Strage.

## run

Write docker-compose.yml for about your GCP project settings.

```
$ docker-compose run --rm dump
$ docker-compose run --rm mask
```

## Yaml example

```yaml
inquiries:
  mail_address: Faker::Internet.email
  nickname: Faker::Games::Pokemon.name
  message_body: Faker::Lorem.paragraph
```

## Need environment variables

- PRODUCTION_GS_UTIL_KEY_FILE
- PRODUCTION_DUMP_OBJECT_URL
- PRODUCTION_DATABASE_URL
- BACKUP_GS_UTIL_KEY_FILE
- BACKUP_DUMP_OBJECT_URL
- MASK_SETTING_YAML_URL

## build and ship

```
$ docker build -t gcr.io/YOUR_REPOSITORY/mysql-mask .
$ docker push gcr.io/YOUR_REPOSITORY/mysql-mask
```

## k8s example

```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: db-dump
spec:
  schedule: "20 18 * * *"  # by 3:20 (JST)
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: mask
            image: gcr.io/YOUR_REPOSITORY/mysql-mask
            command: ["/bin/sh", "-c"]
            args: ["sleep 30; echo '127.0.0.1 db' >> /etc/hosts; /mask/dump.sh"]
            envFrom:
            - configMapRef:
                name: data-mask
          restartPolicy: Never
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: db-mask
spec:
  schedule: "20 19 * * *"  # by 4:20 (JST)
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: db
            image: mysql
            env:
              - name: MYSQL_ROOT_PASSWORD
                value: "password"
          - name: dump
            image: gcr.io/YOUR_REPOSITORY/mysql-mask
            command: ["/bin/sh", "-c"]
            args: ["sleep 30; echo '127.0.0.1 db' >> /etc/hosts; /mask/mask.sh"]
            envFrom:
            - configMapRef:
                name: data-mask
          restartPolicy: Never
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: data-mask
data:
  PRODUCTION_GS_UTIL_KEY_FILE: |
    {
    "type": "service_account",
    ... YOUR PRODUCTION GS_UTIL_KEY_FILE
    }
  PRODUCTION_DUMP_OBJECT_URL: 'gs://PRODUCTION_BUCKET/mysql.dump'
  PRODUCTION_DATABASE_URL: 'mysql://root:password@progressio-mysql-service:3306/magi_staging_1'
  BACKUP_GS_UTIL_KEY_FILE: |
    {
    "type": "service_account",
    ... YOUR BACKUP GS_UTIL_KEY_FILE
    }
  BACKUP_DUMP_OBJECT_URL: 'gs://BACKUP_BUCKET/mysql-masked.dump'
  MASK_SETTING_YAML_URL: 'https://gist.githubusercontent.com/yalab/572d8dd2c96e07bdc454febeddedb671/raw/30cf297ce0cd69ecde06f51ae571d56688c88496/data-mask.yml'
```
