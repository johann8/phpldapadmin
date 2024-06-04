#!/bin/sh -e
#
# set vars
#PLA_VERSION=1.2.6.7-r1

echo -e "\n"
echo "+----------------------------------------------------------+"
echo "|                                                          |"
echo "|             Welcome to PHPLDAPAdmin Docker!              |"
echo "|                                                          |"
echo "+----------------------------------------------------------+"

echo ""
echo "INFO: Start PHPLDAPAdmin version \"${PLA_VERSION}\"."
echo ""
echo "INFO: PHP version \"${PHP_VERSION}\"."

echo -e "\n"
echo -n "Setting variable... "
#FIRST_START_DONE="/var/run/docker-phpldapadmin-first-start-done"
PHPLDAPADMIN_CONFIG_FILE="/etc/phpldapadmin/config.php"
echo "[ DONE ]"

# If there is config
if [ -e "${PHPLDAPADMIN_CONFIG_FILE}" ]; then

  # On container first start customise the container config file
  if [ ! -e "$FIRST_START_DONE" ]; then

    get_salt() {
      salt=$(</dev/urandom tr -dc '1324567890#<>,()*.^@$% =-_~;:/{}[]+!`azertyuiopqsdfghjklmwxcvbnAZERTYUIOPQSDFGHJKLMWXCVBN' | head -c64 | tr -d '\\')
    }
    
    echo -n "Creating config \"${PHPLDAPADMIN_CONFIG_FILE}\"... "
    # phpLDAPadmin cookie secret
    get_salt
    echo "[ DONE ]"

    echo -e "\n"
    echo "+-----------------------------------------------+"
    echo "|   Customizing from environment variables...   |"
    echo "+-----------------------------------------------+"
    echo -e "\n"
    sed -i "s|{{ PHPLDAPADMIN_CONFIG_BLOWFISH }}|${salt}|g" ${PHPLDAPADMIN_CONFIG_FILE}
    sed -i "s|{{ TZ }}|${TZ}|g" ${PHPLDAPADMIN_CONFIG_FILE}
    sed -i "s|{{ PHPLDAPADMIN_LANGUAGE }}|${PHPLDAPADMIN_LANGUAGE}|g" ${PHPLDAPADMIN_CONFIG_FILE}
    sed -i "s|{{ PHPLDAPADMIN_PASSWORD_HASH }}|${PHPLDAPADMIN_PASSWORD_HASH}|g" ${PHPLDAPADMIN_CONFIG_FILE}
    sed -i "s|{{ PHPLDAPADMIN_SERVER_NAME }}|${PHPLDAPADMIN_SERVER_NAME}|g" ${PHPLDAPADMIN_CONFIG_FILE}
    sed -i "s|{{ PHPLDAPADMIN_SERVER_HOST }}|${PHPLDAPADMIN_SERVER_HOST}|g" ${PHPLDAPADMIN_CONFIG_FILE}
    sed -i "s|{{ PHPLDAPADMIN_BIND_ID }}|${PHPLDAPADMIN_BIND_ID}|g" ${PHPLDAPADMIN_CONFIG_FILE}
    sed -i "s|{{ PHPLDAPADMIN_SEARCH_BASE }}|${PHPLDAPADMIN_SEARCH_BASE}|g" ${PHPLDAPADMIN_CONFIG_FILE}
    #touch $FIRST_START_DONE
  fi
fi

