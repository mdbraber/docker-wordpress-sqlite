#!/bin/bash

# terminate on errors
set -e

# Check if volume is empty
if [ ! "$(ls -A "/var/www/wp-content" 2>/dev/null)" ]; then
    echo 'Setting up wp-content volume'
    # Copy wp-content from Wordpress src to volume
    cp -r /usr/src/wordpress/wp-content /var/www/
    chown -R nobody.nobody /var/www

    # Generate secrets
    curl -f https://api.wordpress.org/secret-key/1.1/salt/ >> /usr/src/wordpress/wp-secrets.php
else
    # Copy sqlite-database-integration plugin
    cp -r /usr/src/wordpress/wp-content/plugins/sqlite-database-integration /var/www/wp-content/plugins
    chown -R nobody.nobody /var/www/wp-content/plugins/sqlite-database-integration
    cp /usr/src/wordpress/wp-content/db.php /var/www/wp-content
    chown nobody.nobody /var/www/wp-content/db.php

    # Copy WP Super Cache plugin
    cp -r /usr/src/wordpress/wp-content/plugins/wp-super-cache /var/www/wp-content/plugins
    chown -R nobody.nobody /var/www/wp-content/plugins/wp-super-cache


fi
exec "$@"
