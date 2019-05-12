#!/usr/bin/env bash
set -eo pipefail

# Colours
RED='\e[31m'
BLUE='\e[34m'
GREEN='\e[32m'
YELLOW='\e[33m'
PURPLE='\e[35m'
CYAN='\e[36m'
NC='\033[0m' # No Color

printf "${GREEN}FPM container is starting...${NC}\n"

# resolved holds all of our final values to be applied
declare -A resolved=()

# defaults holds all of our default values
declare -A defaults
defaults[PHP_MAX_EXECUTION_TIME]="300"
defaults[PHP_MAX_INPUT_TIME]="180"
defaults[PHP_MAX_INPUT_VARS]="1000"
defaults[PHP_MEMORY_LIMIT]="256M"
defaults[PHP_DISPLAY_ERRORS]="Off"
defaults[PHP_DISPLAY_STARTUP_ERRORS]="Off"
defaults[PHP_LOG_ERRORS]="On"
defaults[PHP_LOG_ERRORS_MAX_LEN]="1024"
defaults[PHP_IGNORE_REPEATED_ERRORS]="Off"
defaults[PHP_IGNORE_REPEATED_SOURCE]="Off"
defaults[PHP_REPORT_MEMLEAKS]="On"
defaults[PHP_POST_MAX_SIZE]="128M"
defaults[PHP_DEFAULT_CHARSET]="UTF8"
defaults[PHP_FILE_UPLOADS]="On"
defaults[PHP_UPLOAD_MAX_FILESIZE]="128M"
defaults[PHP_MAX_FILE_UPLOADS]="20"
defaults[PHP_ALLOW_URL_FOPEN]="On"
defaults[DOCROOT]="docroot"
# The following defaults are not read from the Tokaido config yaml
# They can only be modified by ENV var
defaults[WWW_PM_MAX_CHILDREN]="30"
defaults[WWW_PM_START_SERVERS]="5"
defaults[WWW_PM_MIN_SPARE_SERVERS]="5"
defaults[WWW_PM_MAX_SPARE_SERVERS]="5"
defaults[WWW_PM_PROCESS_IDLE_TIMEOUT]="10s"

# Set default "null" Tokaido values
declare -A tokaido
tokaido[WORKER_CONNECTIONS]="null"
tokaido[TYPES_HASH_MAX_SIZE]="null"
tokaido[CLIENT_MAX_BODY_SIZE]="null"
tokaido[KEEPALIVE_TIMEOUT]="null"
tokaido[FASTCGI_READ_TIMEOUT]="null"
tokaido[FASTCGI_BUFFERS]="null"
tokaido[FASTCGI_BUFFER_SIZE]="null"
tokaido[DRUPAL_ROOT]="null"
tokaido[WWW_PM_MAX_CHILDREN]="null"
tokaido[WWW_PM_START_SERVERS]="null"
tokaido[WWW_PM_MIN_SPARE_SERVERS]="null"
tokaido[WWW_PM_MAX_SPARE_SERVERS]="null"
tokaido[WWW_PM_PROCESS_IDLE_TIMEOUT]="null"

# If there is a tokaido config, look up any values
if [ -f /tokaido/site/.tok/config.yml ]; then
    tokaido[PHP_MAX_EXECUTION_TIME]="$(yq r /tokaido/site/.tok/config.yml fpm.maxexecutiontime)"
    tokaido[PHP_MAX_INPUT_TIME]="$(yq r /tokaido/site/.tok/config.yml fpm.phpmaxinputtime)"
    tokaido[PHP_MAX_INPUT_VARS]="$(yq r /tokaido/site/.tok/config.yml fpm.phpmaxinputvars)"
    tokaido[PHP_MEMORY_LIMIT]="$(yq r /tokaido/site/.tok/config.yml fpm.phpmemorylimit)"
    tokaido[PHP_DISPLAY_ERRORS]="$(yq r /tokaido/site/.tok/config.yml fpm.phpdisplayerrors)"
    tokaido[PHP_DISPLAY_STARTUP_ERRORS]="$(yq r /tokaido/site/.tok/config.yml fpm.phpdisplaystartuperrors)"
    tokaido[PHP_LOG_ERRORS]="$(yq r /tokaido/site/.tok/config.yml fpm.phplogerrors)"
    tokaido[PHP_LOG_ERRORS_MAX_LEN]="$(yq r /tokaido/site/.tok/config.yml fpm.phplogerrorsmaxlen)"
    tokaido[PHP_IGNORE_REPEATED_ERRORS]="$(yq r /tokaido/site/.tok/config.yml fpm.phpignorerepeatederrors)"
    tokaido[PHP_IGNORE_REPEATED_SOURCE]="$(yq r /tokaido/site/.tok/config.yml fpm.phpignorerepeatedsource)"
    tokaido[PHP_REPORT_MEMLEAKS]="$(yq r /tokaido/site/.tok/config.yml fpm.phpreportmemleaks)"
    tokaido[PHP_POST_MAX_SIZE]="$(yq r /tokaido/site/.tok/config.yml fpm.phppostmaxsize)"
    tokaido[PHP_DEFAULT_CHARSET]="$(yq r /tokaido/site/.tok/config.yml fpm.phpdefaultcharset)"
    tokaido[PHP_FILE_UPLOADS]="$(yq r /tokaido/site/.tok/config.yml fpm.phpfileuploads)"
    tokaido[PHP_UPLOAD_MAX_FILESIZE]="$(yq r /tokaido/site/.tok/config.yml fpm.phpuploadmaxfilesize)"
    tokaido[PHP_MAX_FILE_UPLOADS]="$(yq r /tokaido/site/.tok/config.yml fpm.phpmaxfileuploads)"
    tokaido[PHP_ALLOW_URL_FOPEN]="$(yq r /tokaido/site/.tok/config.yml fpm.phpallowurlfopen)"
    tokaido[DOCROOT]="$(yq r /tokaido/site/.tok/config.yml drupal.path)"
fi

if [[ $(ls -l /tokaido/config/custom-env-vars/* 2>/dev/null) ]]; then
    printf "${YELLOW}Importing custom env vars from /tokaido/config/custom-env-vars/*${NC}\n"
    for e in /tokaido/config/custom-env-vars/*;
    do
        v=$(cat $e)
        printf "  ${YELLOW}Setting ENV $e to $BLUE[$v]$NC\n"
        export ${e##*/}="$v"
    done
fi

printf "${YELLOW}FPM will run with the following configuration values and sources:${NC}\n"
for i in "${!defaults[@]}"
do
    if [ -n "${!i}" ]; then
        # An ENV var exists for this setting, so we'll use it
        resolved["$i"]="${!i}"
        printf "  ${CYAN}$i${NC}"
        printf "\033[50D\033[43C :: ${YELLOW}Use Env value${NC}"
        printf "\033[50D\033[69C :: ${BLUE}$resolved[${!i}]${NC}\n"
        continue
    elif [ ${tokaido[$i]} != "null" ] && [ ! -z ${tokaido[$i]} ]; then
        # No ENV var exists - check if a Tokaido value exists
        resolved["$i"]="${tokaido[$i]}"
        printf "  ${CYAN}$i${NC}"
        printf "\033[50D\033[43C :: ${GREEN}Use Tokaido value${NC}"
        printf "\033[50D\033[65C :: ${BLUE}[${resolved[$i]}]${NC}\n"
        continue
    fi

    # No env var or tokaido var exists, so we use the default
    resolved["$i"]="${defaults[$i]}"
    printf "  ${CYAN}$i${NC}"
    printf "\033[50D\033[43C :: ${PURPLE}Use Default value${NC}"
    printf "\033[50D\033[65C :: ${BLUE}[${resolved[$i]}]${NC}\n"
done

# Use Crudini to set the resolved values
crudini --set /etc/php/7.2/fpm/php.ini PHP max_execution_time ${resolved[PHP_MAX_EXECUTION_TIME]}
crudini --set /etc/php/7.2/fpm/php.ini PHP max_input_time ${resolved[PHP_MAX_INPUT_TIME]}
crudini --set /etc/php/7.2/fpm/php.ini PHP max_input_vars ${resolved[PHP_MAX_INPUT_VARS]}
crudini --set /etc/php/7.2/fpm/php.ini PHP memory_limit ${resolved[PHP_MEMORY_LIMIT]}
crudini --set /etc/php/7.2/fpm/php.ini PHP display_errors ${resolved[PHP_DISPLAY_ERRORS]}
crudini --set /etc/php/7.2/fpm/php.ini PHP display_startup_errors ${resolved[PHP_DISPLAY_STARTUP_ERRORS]}
crudini --set /etc/php/7.2/fpm/php.ini PHP log_errors ${resolved[PHP_LOG_ERRORS]}
crudini --set /etc/php/7.2/fpm/php.ini PHP log_errors_max_len ${resolved[PHP_LOG_ERRORS_MAX_LEN]}
crudini --set /etc/php/7.2/fpm/php.ini PHP ignore_repeated_errors ${resolved[PHP_IGNORE_REPEATED_ERRORS]}
crudini --set /etc/php/7.2/fpm/php.ini PHP ignore_repeated_source ${resolved[PHP_IGNORE_REPEATED_SOURCE]}
crudini --set /etc/php/7.2/fpm/php.ini PHP report_memleaks ${resolved[PHP_REPORT_MEMLEAKS]}
crudini --set /etc/php/7.2/fpm/php.ini PHP post_max_size ${resolved[PHP_POST_MAX_SIZE]}
crudini --set /etc/php/7.2/fpm/php.ini PHP default_charset ${resolved[PHP_DEFAULT_CHARSET]}
crudini --set /etc/php/7.2/fpm/php.ini PHP file_uploads ${resolved[PHP_FILE_UPLOADS]}
crudini --set /etc/php/7.2/fpm/php.ini PHP upload_max_filesize ${resolved[PHP_UPLOAD_MAX_FILESIZE]}
crudini --set /etc/php/7.2/fpm/php.ini PHP max_file_uploads ${resolved[PHP_MAX_FILE_UPLOADS]}
crudini --set /etc/php/7.2/fpm/php.ini PHP allow_url_fopen ${resolved[PHP_ALLOW_URL_FOPEN]}

# Worker pool settings can only be configured via environment variables, not via .tok/config.yml
crudini --set /etc/php/7.2/fpm/pool.d/www.conf www pm.max_children ${resolved[WWW_PM_MAX_CHILDREN]}
crudini --set /etc/php/7.2/fpm/pool.d/www.conf www pm.start_servers ${resolved[WWW_PM_START_SERVERS]}
crudini --set /etc/php/7.2/fpm/pool.d/www.conf www pm.min_spare_servers ${resolved[WWW_PM_MIN_SPARE_SERVERS]}
crudini --set /etc/php/7.2/fpm/pool.d/www.conf www pm.max_spare_servers ${resolved[WWW_PM_MAX_SPARE_SERVERS]}
crudini --set /etc/php/7.2/fpm/pool.d/www.conf www pm.process_idle_timeout ${resolved[WWW_PM_PROCESS_IDLE_TIMEOUT]}

# Load any environment variables (this will override any set by Docker)
if [[ -f /tokaido/config/.env ]]; then
    printf "Importing environment variables from /tokaido/config/.env\n"
    set -o allexport
    source /tokaido/config/.env \
    set +o allexport
fi

# Configure NewRelic if provided a NewRelic API Key
if [ ${NEWRELIC_LICENSE_KEY+x} ]; then
  printf "${YELLOW}Enabling NewRelic Support${NC}\n"
  crudini --set /etc/php/7.2/fpm/conf.d/20-newrelic.ini newrelic newrelic.enabled true
  crudini --set /etc/php/7.2/fpm/conf.d/20-newrelic.ini newrelic newrelic.license "$NEWRELIC_LICENSE_KEY"
  crudini --set /etc/php/7.2/fpm/conf.d/20-newrelic.ini newrelic newrelic.logfile "/dev/stdout"
  crudini --set /etc/php/7.2/fpm/conf.d/20-newrelic.ini newrelic newrelic.appname "$NEWRELIC_APP_NAME"
  crudini --set /etc/php/7.2/fpm/conf.d/20-newrelic.ini newrelic newrelic.daemon.logfile "/dev/stdout"
else
  # ensure newrelic module is never loaded
  printf "Disabling NewRelic Support - NEWRELIC_LICENSE_KEY not set\n"
  rm /etc/php/7.2/fpm/conf.d/20-newrelic.ini 2>/dev/null || true
fi

# Configure XDebug if it's in use. Xdebug settings can only come via env vars
if [ ${XDEBUG_REMOTE_ENABLE+x} ]; then
    printf "${YELLOW}Enabling XDebug Support${NC}\n"
    XDEBUG_REMOTE_ENABLE="ON"
    XDEBUG_REMOTE_CONNECT_BACK=${XDEBUG_REMOTE_CONNECT_BACK:-"Off"}
    XDEBUG_REMOTE_HOST=${XDEBUG_REMOTE_HOST:-"localhost"}
    XDEBUG_REMOTE_HANDLER=${XDEBUG_REMOTE_HANDLER:-"dbgp"}
    XDEBUG_REMOTE_PORT=${XDEBUG_REMOTE_PORT:-"9000"}
    XDEBUG_REMOTE_AUTOSTART=${XDEBUG_REMOTE_AUTOSTART:-"On"}
    XDEBUG_EXTENDED_INFO=${XDEBUG_EXTENDED_INFO:-"On"}

    crudini --set /etc/php/7.2/fpm/conf.d/20-xdebug.ini xdebug xdebug.remote_enable ${XDEBUG_REMOTE_ENABLE}
    crudini --set /etc/php/7.2/fpm/conf.d/20-xdebug.ini xdebug xdebug.remote_connect_back ${XDEBUG_REMOTE_CONNECT_BACK}
    crudini --set /etc/php/7.2/fpm/conf.d/20-xdebug.ini xdebug xdebug.remote_host ${XDEBUG_REMOTE_HOST}
    crudini --set /etc/php/7.2/fpm/conf.d/20-xdebug.ini xdebug xdebug.remote_handler ${XDEBUG_REMOTE_HANDLER}
    crudini --set /etc/php/7.2/fpm/conf.d/20-xdebug.ini xdebug xdebug.remote_port ${XDEBUG_REMOTE_PORT}
    crudini --set /etc/php/7.2/fpm/conf.d/20-xdebug.ini xdebug xdebug.remote_autostart ${XDEBUG_REMOTE_AUTOSTART}
    crudini --set /etc/php/7.2/fpm/conf.d/20-xdebug.ini xdebug xdebug.extended_info ${XDEBUG_EXTENDED_INFO}
else
    printf "Disabling XDebug support\n"
    rm /etc/php/7.2/fpm/conf.d/20-xdebug.ini 2>/dev/null || true
fi

# Run post-deploy hooks if we're in a production environment
if [[ ! -z "$TOK_PROVIDER" ]]; then
    printf "${YELLOW}Running discovered post-deploy hooks from /tokaido/site/.tok/hooks/post-deploy/*.sh${NC}\n"
    for f in /tokaido/site/.tok/hooks/post-deploy/*.sh;
    do
        bash "$f" || true;
    done
fi

printf "${GREEN}Starting PHP FPM 7.2...\n${NC}"
/usr/sbin/php-fpm7.2 -F