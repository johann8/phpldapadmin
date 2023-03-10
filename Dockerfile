ARG ARCH=

ARG BASE_IMAGE=alpine:3.17

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

ARG PLA_VERSION=1.2.6.5-r0

# Install packages
RUN apk --no-cache add \
        phpldapadmin=${PLA_VERSION} \
        php81 \
        php81-fpm \
        php81-opcache \
        php81-pecl-apcu \
        php81-mysqli \
        php81-cli \
        php81-ldap \
        php81-imap \
        php81-intl \
        php81-pgsql \
        php81-json \
        php81-openssl \
        php81-curl \
        php81-zlib \
        php81-bz2 \
        php81-soap \
        php81-xml \
        php81-fileinfo \
        php81-phar \
        php81-intl \
        php81-dom \
        php81-xmlreader \
        php81-ctype \
        php81-session \
        php81-iconv \
        php81-tokenizer \
        php81-zip \
        php81-simplexml \
        php81-mbstring \
        php81-gd \
        nginx \
        runit \
        curl \
        # php8-pdo \
        # php8-pdo_pgsql \
        # php8-pdo_mysql \
        # php8-pdo_sqlite \
        # php8-bz2 \
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
RUN if [ -f /usr/share/webapps/phpldapadmin/lib/functions.php ]; then \
       # create backup
       mv /usr/share/webapps/phpldapadmin/lib/functions.php /usr/share/webapps/phpldapadmin/lib/functions.php.back; \
    fi 

COPY assets/phpldapadmin/web/functions.php /usr/share/webapps/phpldapadmin/lib/ 
# --- End ---

### === fix bug #193 on github ===
# --- Start ---
RUN if [ -f /usr/share/webapps/phpldapadmin/lib/createlm.php ]; then \
       # create backup
       mv /usr/share/webapps/phpldapadmin/lib/createlm.php /usr/share/webapps/phpldapadmin/lib/createlm.php.back; \
    fi

COPY assets/phpldapadmin/web/createlm.php /usr/share/webapps/phpldapadmin/lib/
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
