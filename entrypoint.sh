#!/usr/bin/env bash
set -euo pipefail

################################################################################
#
# Setting Default Variable Values
# Tokaido enables us to set variable values at three levels. These levels
# are as follows, listed from highest-priority to lowest-priority
# 1 - As Config Variable in .tok/config.yml
# 2 - As Environment Variable exposed to the PHP container
# 3 - As default variable defined here
# 
# For example, if the variable fpm.max_exeuction_time is defined in .tok/config.yml
# then any value set as an environment variable (MAX_EXECUTION_TIME) won't be used
#
################################################################################

# Default Values
DEFAULT_PHP_MAX_EXECUTION_TIME="300"
DEFAULT_PHP_MAX_INPUT_TIME="180"
DEFAULT_PHP_MAX_INPUT_VARS="1000"
DEFAULT_PHP_MEMORY_LIMIT="256M"
DEFAULT_PHP_DISPLAY_ERRORS="Off"
DEFAULT_PHP_DISPLAY_STARTUP_ERRORS="Off"
DEFAULT_PHP_LOG_ERRORS="On"
DEFAULT_PHP_LOG_ERRORS_MAX_LEN="1024"
DEFAULT_PHP_IGNORE_REPEATED_ERRORS="Off"
DEFAULT_PHP_IGNORE_REPEATED_SOURCE="Off"
DEFAULT_PHP_REPORT_MEMLEAKS="On"
DEFAULT_PHP_POST_MAX_SIZE="64M"
DEFAULT_PHP_DEFAULT_CHARSET="UTF-8"
DEFAULT_PHP_FILE_UPLOADS="On"
DEFAULT_PHP_UPLOAD_MAX_FILESIZE="64M"
DEFAULT_PHP_MAX_FILE_UPLOADS="20"
DEFAULT_PHP_ALLOW_URL_FOPEN="On"
DEFAULT_DOCROOT="docroot"

# Config values, if set. Otherwise, yq will set to 'null'
TOK_PHP_MAX_EXECUTION_TIME="$(yq r /tokaido/site/.tok/config.yml fpm.maxexecutiontime)"
TOK_PHP_MAX_INPUT_TIME="$(yq r /tokaido/site/.tok/config.yml fpm.phpmaxinputtime)"
TOK_PHP_MAX_INPUT_VARS="$(yq r /tokaido/site/.tok/config.yml fpm.phpmaxinputvars)"
TOK_PHP_MEMORY_LIMIT="$(yq r /tokaido/site/.tok/config.yml fpm.phpmemorylimit)"
TOK_PHP_DISPLAY_ERRORS="$(yq r /tokaido/site/.tok/config.yml fpm.phpdisplayerrors)"
TOK_PHP_DISPLAY_STARTUP_ERRORS="$(yq r /tokaido/site/.tok/config.yml fpm.phpdisplaystartuperrors)"
TOK_PHP_LOG_ERRORS="$(yq r /tokaido/site/.tok/config.yml fpm.phplogerrors)"
TOK_PHP_LOG_ERRORS_MAX_LEN="$(yq r /tokaido/site/.tok/config.yml fpm.phplogerrorsmaxlen)"
TOK_PHP_IGNORE_REPEATED_ERRORS="$(yq r /tokaido/site/.tok/config.yml fpm.phpignorerepeatederrors)"
TOK_PHP_IGNORE_REPEATED_SOURCE="$(yq r /tokaido/site/.tok/config.yml fpm.phpignorerepeatedsource)"
TOK_PHP_REPORT_MEMLEAKS="$(yq r /tokaido/site/.tok/config.yml fpm.phpreportmemleaks)"
TOK_PHP_POST_MAX_SIZE="$(yq r /tokaido/site/.tok/config.yml fpm.phppostmaxsize)"
TOK_PHP_DEFAULT_CHARSET="$(yq r /tokaido/site/.tok/config.yml fpm.phpdefaultcharset)"
TOK_PHP_FILE_UPLOADS="$(yq r /tokaido/site/.tok/config.yml fpm.phpfileuploads)"
TOK_PHP_UPLOAD_MAX_FILESIZE="$(yq r /tokaido/site/.tok/config.yml fpm.phpuploadmaxfilesize)"
TOK_PHP_MAX_FILE_UPLOADS="$(yq r /tokaido/site/.tok/config.yml fpm.phpmaxfileuploads)"
TOK_PHP_ALLOW_URL_FOPEN="$(yq r /tokaido/site/.tok/config.yml fpm.phpallowurlfopen)"
TOK_DOCROOT="$(yq r /tokaido/site/.tok/config.yml drupal.path)"

# Iterate over the variable configurations to get the highest-precedence value
if [ "${TOK_PHP_MAX_EXECUTION_TIME}" != "null" ]; then
    # Tokaido config values have highest precedence, so we'll just use that
    PHP_MAX_EXECUTION_TIME="${TOK_PHP_MAX_EXECUTION_TIME}"
else
    # Use an env var value, or our default if none is set
    PHP_MAX_EXECUTION_TIME="${PHP_MAX_EXECUTION_TIME:-$DEFAULT_PHP_MAX_EXECUTION_TIME}"
fi

if [ "${TOK_PHP_MAX_INPUT_TIME}" != "null" ]; then
    PHP_MAX_INPUT_TIME="${TOK_PHP_MAX_INPUT_TIME}"
else
    PHP_MAX_INPUT_TIME="${PHP_MAX_INPUT_TIME:-$DEFAULT_PHP_MAX_INPUT_TIME}"
fi

if [ "${TOK_PHP_MAX_INPUT_VARS}" != "null" ]; then
    PHP_MAX_INPUT_VARS="${TOK_PHP_MAX_INPUT_VARS}"
else
    PHP_MAX_INPUT_VARS="${PHP_MAX_INPUT_VARS:-$DEFAULT_PHP_MAX_INPUT_VARS}"
fi

if [ "${TOK_PHP_MEMORY_LIMIT}" != "null" ]; then
    PHP_MEMORY_LIMIT="${TOK_PHP_MEMORY_LIMIT}"
else
    PHP_MEMORY_LIMIT="${PHP_MEMORY_LIMIT:-$DEFAULT_PHP_MEMORY_LIMIT}"
fi

if [ "${TOK_PHP_DISPLAY_ERRORS}" != "null" ]; then
    PHP_DISPLAY_ERRORS="${TOK_PHP_DISPLAY_ERRORS}"
else
    PHP_DISPLAY_ERRORS="${PHP_DISPLAY_ERRORS:-$DEFAULT_PHP_DISPLAY_ERRORS}"
fi

if [ "${TOK_PHP_DISPLAY_STARTUP_ERRORS}" != "null" ]; then
    PHP_DISPLAY_STARTUP_ERRORS="${TOK_PHP_DISPLAY_STARTUP_ERRORS}"
else
    PHP_DISPLAY_STARTUP_ERRORS="${PHP_DISPLAY_STARTUP_ERRORS:-$DEFAULT_PHP_DISPLAY_STARTUP_ERRORS}"
fi

if [ "${TOK_PHP_LOG_ERRORS}" != "null" ]; then
    PHP_LOG_ERRORS="${TOK_PHP_LOG_ERRORS}"
else
    PHP_LOG_ERRORS="${PHP_LOG_ERRORS:-$DEFAULT_PHP_LOG_ERRORS}"
fi

if [ "${TOK_PHP_LOG_ERRORS_MAX_LEN}" != "null" ]; then
    PHP_LOG_ERRORS_MAX_LEN="${TOK_PHP_LOG_ERRORS_MAX_LEN}"
else
    PHP_LOG_ERRORS_MAX_LEN="${PHP_LOG_ERRORS_MAX_LEN:-$DEFAULT_PHP_LOG_ERRORS_MAX_LEN}"
fi

if [ "${TOK_PHP_IGNORE_REPEATED_ERRORS}" != "null" ]; then
    PHP_IGNORE_REPEATED_ERRORS="${TOK_PHP_IGNORE_REPEATED_ERRORS}"
else
    PHP_IGNORE_REPEATED_ERRORS="${PHP_IGNORE_REPEATED_ERRORS:-$DEFAULT_PHP_IGNORE_REPEATED_ERRORS}"
fi

if [ "${TOK_PHP_IGNORE_REPEATED_SOURCE}" != "null" ]; then
    PHP_IGNORE_REPEATED_SOURCE="${TOK_PHP_IGNORE_REPEATED_SOURCE}"
else
    PHP_IGNORE_REPEATED_SOURCE="${PHP_IGNORE_REPEATED_SOURCE:-$DEFAULT_PHP_IGNORE_REPEATED_SOURCE}"
fi

if [ "${TOK_PHP_REPORT_MEMLEAKS}" != "null" ]; then
    PHP_REPORT_MEMLEAKS="${TOK_PHP_REPORT_MEMLEAKS}"
else
    PHP_REPORT_MEMLEAKS="${PHP_REPORT_MEMLEAKS:-$DEFAULT_PHP_REPORT_MEMLEAKS}"
fi

if [ "${TOK_PHP_POST_MAX_SIZE}" != "null" ]; then
    PHP_POST_MAX_SIZE="${TOK_PHP_POST_MAX_SIZE}"
else
    PHP_POST_MAX_SIZE="${PHP_POST_MAX_SIZE:-$DEFAULT_PHP_POST_MAX_SIZE}"
fi

if [ "${TOK_PHP_DEFAULT_CHARSET}" != "null" ]; then
    PHP_DEFAULT_CHARSET="${TOK_PHP_DEFAULT_CHARSET}"
else
    PHP_DEFAULT_CHARSET="${PHP_DEFAULT_CHARSET:-$DEFAULT_PHP_DEFAULT_CHARSET}"
fi

if [ "${TOK_PHP_FILE_UPLOADS}" != "null" ]; then
    PHP_FILE_UPLOADS="${TOK_PHP_FILE_UPLOADS}"
else
    PHP_FILE_UPLOADS="${PHP_FILE_UPLOADS:-$DEFAULT_PHP_FILE_UPLOADS}"
fi

if [ "${TOK_PHP_UPLOAD_MAX_FILESIZE}" != "null" ]; then
    PHP_UPLOAD_MAX_FILESIZE="${TOK_PHP_UPLOAD_MAX_FILESIZE}"
else
    PHP_UPLOAD_MAX_FILESIZE="${PHP_UPLOAD_MAX_FILESIZE:-$DEFAULT_PHP_UPLOAD_MAX_FILESIZE}"
fi

if [ "${TOK_PHP_MAX_FILE_UPLOADS}" != "null" ]; then
    PHP_MAX_FILE_UPLOADS="${TOK_PHP_MAX_FILE_UPLOADS}"
else
    PHP_MAX_FILE_UPLOADS="${PHP_MAX_FILE_UPLOADS:-$DEFAULT_PHP_MAX_FILE_UPLOADS}"
fi

if [ "${TOK_PHP_ALLOW_URL_FOPEN}" != "null" ]; then
    PHP_ALLOW_URL_FOPEN="${TOK_PHP_ALLOW_URL_FOPEN}"
else
    PHP_ALLOW_URL_FOPEN="${PHP_ALLOW_URL_FOPEN:-$DEFAULT_PHP_ALLOW_URL_FOPEN}"
fi

if [ "${TOK_DOCROOT}" != "null" ]; then
    DOCROOT="${TOK_DOCROOT}"
else
    DOCROOT="${DOCROOT:-$DEFAULT_DOCROOT}"
fi

# TOK_PROVIDER is a special value that can only be provided 
# as environment variables, not via the .tok/config.yml file. 
# It set, it tells this container it is running in a production environment

TOK_PROVIDER=${TOK_PROVIDER:-}

if ! [[ -d /tokaido/site/${DOCROOT} ]]; then
    echo "ERROR: Could not find a site in /tokaido/site/${DOCROOT}. Exiting."
    exit
fi

cd /tokaido/site/${DOCROOT} 

# Output all our resolved values for logging to catch
echo "config value 'PHP_MAX_INPUT_TIME'         :: ${PHP_MAX_INPUT_TIME}"
echo "config value 'PHP_MAX_INPUT_VARS'         :: ${PHP_MAX_INPUT_VARS}"
echo "config value 'PHP_MEMORY_LIMIT'           :: ${PHP_MEMORY_LIMIT}"
echo "config value 'PHP_DISPLAY_ERRORS'         :: ${PHP_DISPLAY_ERRORS}"
echo "config value 'PHP_DISPLAY_STARTUP_ERRORS' :: ${PHP_DISPLAY_STARTUP_ERRORS}"
echo "config value 'PHP_LOG_ERRORS'             :: ${PHP_LOG_ERRORS}"
echo "config value 'PHP_LOG_ERRORS_MAX_LEN'     :: ${PHP_LOG_ERRORS_MAX_LEN}"
echo "config value 'PHP_IGNORE_REPEATED_ERRORS' :: ${PHP_IGNORE_REPEATED_ERRORS}"
echo "config value 'PHP_IGNORE_REPEATED_SOURCE' :: ${PHP_IGNORE_REPEATED_SOURCE}"
echo "config value 'PHP_REPORT_MEMLEAKS'        :: ${PHP_REPORT_MEMLEAKS}"
echo "config value 'PHP_POST_MAX_SIZE'          :: ${PHP_POST_MAX_SIZE}"
echo "config value 'PHP_DEFAULT_CHARSET'        :: ${PHP_DEFAULT_CHARSET}"
echo "config value 'PHP_FILE_UPLOADS'           :: ${PHP_FILE_UPLOADS}"
echo "config value 'PHP_UPLOAD_MAX_FILESIZE'    :: ${PHP_UPLOAD_MAX_FILESIZE}"
echo "config value 'PHP_MAX_FILE_UPLOADS'       :: ${PHP_MAX_FILE_UPLOADS}"
echo "config value 'PHP_ALLOW_URL_FOPEN'        :: ${PHP_ALLOW_URL_FOPEN}"
echo "config value 'DOCROOT'                    :: ${DOCROOT}"

# Set PHP configuration variables
crudini --set /etc/php/7.2/fpm/php.ini PHP max_execution_time ${PHP_MAX_EXECUTION_TIME}
crudini --set /etc/php/7.2/fpm/php.ini PHP max_input_time ${PHP_MAX_INPUT_TIME}
crudini --set /etc/php/7.2/fpm/php.ini PHP max_input_vars ${PHP_MAX_INPUT_VARS}
crudini --set /etc/php/7.2/fpm/php.ini PHP memory_limit ${PHP_MEMORY_LIMIT}
crudini --set /etc/php/7.2/fpm/php.ini PHP display_errors ${PHP_DISPLAY_ERRORS}
crudini --set /etc/php/7.2/fpm/php.ini PHP display_startup_errors ${PHP_DISPLAY_STARTUP_ERRORS}
crudini --set /etc/php/7.2/fpm/php.ini PHP log_errors ${PHP_LOG_ERRORS}
crudini --set /etc/php/7.2/fpm/php.ini PHP log_errors_max_len ${PHP_LOG_ERRORS_MAX_LEN}
crudini --set /etc/php/7.2/fpm/php.ini PHP ignore_repeated_errors ${PHP_IGNORE_REPEATED_ERRORS}
crudini --set /etc/php/7.2/fpm/php.ini PHP ignore_repeated_source ${PHP_IGNORE_REPEATED_SOURCE}
crudini --set /etc/php/7.2/fpm/php.ini PHP report_memleaks ${PHP_REPORT_MEMLEAKS}
crudini --set /etc/php/7.2/fpm/php.ini PHP post_max_size ${PHP_POST_MAX_SIZE}
crudini --set /etc/php/7.2/fpm/php.ini PHP default_charset ${PHP_DEFAULT_CHARSET}
crudini --set /etc/php/7.2/fpm/php.ini PHP file_uploads ${PHP_FILE_UPLOADS}
crudini --set /etc/php/7.2/fpm/php.ini PHP upload_max_filesize ${PHP_UPLOAD_MAX_FILESIZE}
crudini --set /etc/php/7.2/fpm/php.ini PHP max_file_uploads ${PHP_MAX_FILE_UPLOADS}
crudini --set /etc/php/7.2/fpm/php.ini PHP allow_url_fopen ${PHP_ALLOW_URL_FOPEN}

# Worker pool settings can only be configured via environment variables, not via .tok/config.yml
crudini --set /etc/php/7.2/fpm/pool.d/www.conf www pm.max_children ${WWW_PM_MAX_CHILDREN:-30}
crudini --set /etc/php/7.2/fpm/pool.d/www.conf www pm.start_servers ${WWW_PM_START_SERVERS:-5}
crudini --set /etc/php/7.2/fpm/pool.d/www.conf www pm.min_spare_servers ${WWW_PM_MIN_SPARE_SERVERS:-5}
crudini --set /etc/php/7.2/fpm/pool.d/www.conf www pm.max_spare_servers ${WWW_PM_MAX_SPARE_SERVERS:-5}
crudini --set /etc/php/7.2/fpm/pool.d/www.conf www pm.process_idle_timeout ${WWW_PM_PROCESS_IDLE_TIMEOUT:-10s}

# Ensure starting log files can be read by all users
touch /tokaido/logs/fpm/access.log /tokaido/logs/fpm/slow.log 
chmod 640 /tokaido/logs/fpm/access.log /tokaido/logs/fpm/slow.log 
    
# Ensure global Composer packages are secure
find /home/tok -type f,d -perm /g+w,o+w -a -print0 | xargs -r -0 chmod 750

# Load any environment variables (this will override any set by Docker)
if [[ -f /tokaido/config/.env ]]; then
    set -o allexport
    source /tokaido/config/.env \
    set +o allexport
fi

# If a custom environment variable path exists, then inject those values
if [[ $(ls -l /tokaido/config/custom-env-vars/* 2>/dev/null) ]]; then    
    for e in /tokaido/config/custom-env-vars/*; 
    do
        echo "setting custom environment variable $e"
        export ${e##*/}="$(cat $e)"
    done
fi

# Run post-deploy hooks if we're in a production environment
if [[ ! -z "$TOK_PROVIDER" ]]; then    
    for f in /tokaido/site/.tok/hooks/post-deploy/*.sh; 
    do
        bash "$f" || true; 
    done    
fi
/usr/sbin/php-fpm7.2 -F