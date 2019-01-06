Introduction
============

This container provides a PHP FPM instance for use in the Tokaido hosting
platform. It is intended to be used alongside the other Tokaido containers.

## Default Values

You can dynamically change the configuration of my PHP settings by supplying
new values for the following environment varibles:

| Environment Variable        | Set In   | Default Value                    |
|-----------------------------|----------|----------------------------------|
| PHP_MAX_EXECUTION_TIME      | php.ini  | 300 (seconds)                    |
| PHP_MAX_INPUT_TIME          | php.ini  | 180 (seconds)                    |
| PHP_MEMORY_LIMIT            | php.ini  | 256MB                            |
| PHP_DISPLAY_ERRORS          | php.ini  | Off                              |
| PHP_DISPLAY_STARTUP_ERRORS  | php.ini  | Off                              |
| PHP_LOG_ERRORS              | php.ini  | On                               |
| PHP_LOG_ERRORS_MAX_LEN      | php.ini  | 1024                             |
| PHP_IGNORE_REPEATED_ERRORS  | php.ini  | Off                              |
| PHP_IGNORE_REPEATED_SOURCE  | php.ini  | Off                              |
| PHP_REPORT_MEMLEAKS         | php.ini  | On                               |
| PHP_POST_MAX_SIZE           | php.ini  | 64M                              |
| PHP_DEFAULT_CHARSET         | php.ini  | UTF-8                            |
| PHP_FILE_UPLOADS            | php.ini  | On                               |
| PHP_UPLOAD_MAX_FILESIZE     | php.ini  | 64M                              |
| PHP_MAX_FILE_UPLOADS        | php.ini  | 20                               |
| PHP_ALLOW_URL_FOPEN         | php.ini  | On                               |
| XDEBUG_REMOTE_ENABLE        | php.ini  | Off                              | 
| WWW_PM_MAX_CHILDREN         | www.conf | 30                               |
| WWW_PM_START_SERVERS        | www.conf | 5                                |
| WWW_PM_MIN_SPARE_SERVERS    | www.conf | 5                                |
| WWW_PM_MAX_SPARE_SERVERS    | www.conf | 5                                |
| WWW_REQUEST_SLOWLOG_TIMEOUT | www.conf | 10s                              |
| WWW_PM_PROCESS_IDLE_TIMEOUT | www.conf | 10s                              |

> Note that XDEBUG_REMOTE_ENABLE is set to "On" by the Tokaido CLI for local
dev environments. 

##### Fixed Values
Some PHP default settings are changed for Tokaido, and aren't intended to be
changed back. Short of forking this image, you can't change these values
but their new values are here for your reference. 

If you feel like we should change any of these values, please raise an issue as
we'd be happy to discuss. 

| PHP Variable               | Set In       | Fixed Value                     |
|----------------------------|--------------|---------------------------------|
| error_log                  | php.ini      | /tokaido/logs/fpm/error.log     |
| access_log                 | php.ini      | /tokaido/logs/fpm/access.log    |
| slow_log                   | php.ini      | /tokaido/logs/fpm/slow.log      |
| cgi.fix_pathinfo           | php.ini      | 0                               |
| html_errors                | php.ini      | Off                             |
| user                       | www.conf     | tok                             |
| group                      | www.conf     | web                             |
| catch_workers_output       | www.conf     | yes                             |
| clear_env                  | www.conf     | no                              |
| listen                     | www.conf     | 9000                            |
| error_log                  | php-fpm.conf | /proc/self/fd/2                 |

## Running

If you want to run this container locally (to check it out, debug, or whatever)
you can do so by running:

`docker run -it -u1001 -v /path/to/your/site:/tokaido/site tokaido/fpm`

The container will fail if it can't find a Drupal site in `/tokaido/site/docroot`. 
If you're lacking this, you can mock the directory and force the container to
run with:

`docker run -it -u1001 -v /tmp:/tokaido/site/docroot tokaido/fpm`