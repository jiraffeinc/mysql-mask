# mysql-mask

MySQL database dump and mask sensitive data according to yaml settings and put it to Google Cloud Strage.

## run

```
$ docker-compose run -e "GS_UTIL_KEY_FILE=$(cat YOUR_KEY_FILE)" -e "GCP_ACCOUNT=ACCOUNT" -e "GCP_PROJECT_NAME=PROJECT_NAME" -e "BUCKET_NAME=BUCKET_NAME" -e "OBJECT_NAME=FILE_NAME" -e "DATABASE_URL=mysql://USER:PASSWORD@HOST/DATABASE_NAME" -e "MASK_SETTING_YAML_URL=https://example.com/mask_settings.yml" --rm app
```


## Yaml example

```yaml
inquiries:
  mail_address: Faker::Internet.email
  nickname: Faker::Games::Pokemon.name
  message_body: Faker::Lorem.paragraph
```

## Need environment variables

- GS_UTIL_KEY_FILE
- GCP_ACCOUNT
- GCP_PROJECT_NAME
- BUCKET_NAME
- OBJECT_NAME
- DATABASE_URL
- MASK_SETTING_YAML_URL
