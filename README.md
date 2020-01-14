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
