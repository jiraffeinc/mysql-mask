FROM ruby:2.6.5-alpine3.10

ENV LANG=C.UTF-8 \
    ROOT_PATH=/mask \
    BUNDLE_JOBS=4 \
    CLOUDSDK_INSTALL_DIR=/usr/local \
    CLOUDSDK_CORE_DISABLE_PROMPTS=1 \
    PATH=$PATH:/usr/local/google-cloud-sdk/bin/
RUN apk add --update --no-cache mysql-client mysql-dev build-base curl bash python && \
    curl https://sdk.cloud.google.com | bash
ADD . $ROOT_PATH
WORKDIR $ROOT_PATH
RUN bundle install

