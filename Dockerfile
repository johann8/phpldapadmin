ARG ARCH=

ARG BASE_IMAGE=alpine:3.19

FROM ${ARCH}${BASE_IMAGE}

ARG BUILD_DATE

ARG VCS_REF

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=phpldapadmin \
      org.label-schema.authors="Johann H. <>" \ 
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/johann8/phpldapadmin" \
      org.label-schema.description="Docker container with PHPLDAPAdmin based on Alpine Linux"

ARG POST_MAX_FILESIZE=5M

ARG UPLOAD_MAX_FILESIZE=10M

ARG PLA_VERSION=1.2.6.7-r0

ENV PHP_VERSION 81

# Install packages
RUN apk --no-cache add \
        phpldapadmin=${PLA_VERSION} \
        php${PHP_VERSION} \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-opcache \
        php${PHP_VERSION}-pecl-apcu \
        php${PHP_VERSION}-mysqli \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-ldap \
        php${PHP_VERSION}-imap \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-pgsql \
        php${PHP_VERSION}-json \
        php${PHP_VERSION}-openssl \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-zlib \
        php${PHP_VERSION}-bz2 \
        php${PHP_VERSION}-soap \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-fileinfo \
        php${PHP_VERSION}-phar \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-dom \
        php${PHP_VERSION}-xmlreader \
        php${PHP_VERSION}-ctype \
        php${PHP_VERSION}-session \
        php${PHP_VERSION}-iconv \
        php${PHP_VERSION}-tokenizer \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-simplexml \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-gettext \
        nginx \
        runit \
        curl \
        # php${PHP_VERSION}-pdo \
        # php${PHP_VERSION}-pdo_pgsql \
        # php${PHP_VERSION}-pdo_mysql \
        # php${PHP_VERSION}-pdo_sqlite \
        # php${PHP_VERSION}-bz2 \
# Bring in gettext so we can get `envsubst`, then throw
# the rest away. To do this, we need to install `gettext`
# then move `envsubst` out of the way so `gettext` can
# be deleted completely, then move `envsubst` back.
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    && runDeps="$( \
        scanelf --needed --nobanner /tmp/envsubst \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache $runDeps \
    && apk del .gettext \
    && mv /tmp/envsubst /usr/local/bin/ \
# Remove alpine cache
    && rm -rf /var/cache/apk/* \
# Remove default server definition
    && rm /etc/nginx/http.d/default.conf \
# Make sure files/folders needed by the processes are accessable when they run under the nobody user
    && chown -R nobody.nobody /run \
    && chown -R nobody.nobody /var/lib/nginx \
    && chown -R nobody.nobody /var/log/nginx

# copy phpldapadmin config file
RUN rm -rf /var/www/localhost/htdocs \
    && ln -sf /usr/share/webapps/phpldapadmin/htdocs/ /var/www/localhost/
    #&& cp /etc/phpldapadmin/config.php.example /etc/phpldapadmin/config.php

### === fix bug #183 on github ===
# --- Start ---
#RUN if [ -f /usr/share/webapps/phpldapadmin/lib/functions.php ]; then \
#       # create backup
#       mv /usr/share/webapps/phpldapadmin/lib/functions.php /usr/share/webapps/phpldapadmin/lib/functions.php.back; \
#    fi 

#COPY assets/phpldapadmin/web/functions.php /usr/share/webapps/phpldapadmin/lib/ 
# --- End ---

### === fix bug #193 on github ===
# --- Start ---
#RUN if [ -f /usr/share/webapps/phpldapadmin/lib/createlm.php ]; then \
#       # create backup
#       mv /usr/share/webapps/phpldapadmin/lib/createlm.php /usr/share/webapps/phpldapadmin/lib/createlm.php.back; \
#    fi

#COPY assets/phpldapadmin/web/createlm.php /usr/share/webapps/phpldapadmin/lib/
# --- End ---


# Add configuration files
COPY --chown=nobody rootfs/ /

# Switch to use a non-root user from here on
USER nobody

# Add application
WORKDIR /var/www/html

# Expose the port nginx is reachable on
EXPOSE 8080

# Let runit start nginx & php-fpm
CMD [ "/bin/docker-entrypoint.sh" ]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping

ENV client_max_body_size=2M \
    clear_env=no \
    allow_url_fopen=On \
    allow_url_include=Off \
    display_errors=Off \
    file_uploads=On \
    max_execution_time=0 \
    max_input_time=-1 \
    max_input_vars=1000 \
    memory_limit=256M \
    post_max_size=${POST_MAX_FILESIZE:-8M} \
    upload_max_filesize=${UPLOAD_MAX_FILESIZE:-2M} \
    zlib.output_compression=On
