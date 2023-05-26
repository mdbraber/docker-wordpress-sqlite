
# WordPress Docker Container

Lightweight WordPress container with [SQLite database integration](https://github.com/WordPress/sqlite-database-integration), Nginx 1.22 and PHP-FPM 8.1 based on Alpine Linux.

_WordPress version currently installed:_ **6.2.2**
_SQLite database integration plugin:_ **1.2.2**

* Optimized for 100 concurrent users
* Optimized to only use resources when there's traffic (by using PHP-FPM's ondemand PM)
* Works with Amazon Cloudfront or CloudFlare as SSL terminator and CDN
* Multi-platform, supporting AMD4, ARMv6, ARMv7, ARM64
* Built on the lightweight Alpine Linux distribution
* Small Docker image size (+/-90MB)
* Uses PHP 8.0 for better performance, lower cpu usage & memory footprint
* Can safely be updated without losing data
* [SQLite database integration](https://github.com/WordPress/sqlite-database-integration) (no MySQL needed to get started; also not installed!)
* Fully configurable because wp-config.php uses the environment variables you can pass as an argument to the container


![nginx 1.22](https://img.shields.io/badge/nginx-1.22-brightgreen.svg)
![php 8.1](https://img.shields.io/badge/php-8.1-brightgreen.svg)
![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)

## Usage
See [docker-compose.example.yml](https://github.com/mdbraber/docker-wordpress/blob/master/docker-compose.example.yml) how to use it in your own environment.

    docker-compose up

Or
    docker build -t mdbraber/docker-wordpress-sqlite .

    docker run -d -p 80:80 -v /local/folder:/var/www/wp-content \
    -e "DB_HOST=db" \
    -e "DB_NAME=wordpress" \
    -e "DB_USER=wp" \
    -e "DB_PASSWORD=secret" \
    -e "FS_METHOD=direct" \
    mdbraber/docker-wordpress-sqlite

### WP-CLI

This image includes [wp-cli](https://wp-cli.org/) which can be used like this:

    docker exec <your container name> /usr/local/bin/wp --path=/usr/src/wordpress <your command>


## Inspired by

* https://github.com/TrafeX/docker-wordpress

