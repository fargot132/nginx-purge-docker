FROM nginx:1.25

ENV NGX_CACHE_PURGE_VERSION=2.5.3

ENV BUILD_DEPENDENCIES \
    build-essential \
    libssl-dev \
    libpcre3 \
    libpcre3-dev \
    zlib1g-dev \
    wget

RUN set -ex \
    # Install basic packages and build tools
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y ${BUILD_DEPENDENCIES} \
    # download and extract sources
    && NGINX_VERSION=`nginx -V 2>&1 | grep "nginx version" | awk -F/ '{ print $2}'` \
    && cd /tmp \
    && wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
    && wget https://github.com/nginx-modules/ngx_cache_purge/archive/$NGX_CACHE_PURGE_VERSION.tar.gz \
         -O ngx_cache_purge-$NGX_CACHE_PURGE_VERSION.tar.gz \
    && tar -xf nginx-$NGINX_VERSION.tar.gz \
    && mv nginx-$NGINX_VERSION nginx \
    && rm nginx-$NGINX_VERSION.tar.gz \
    && tar -xf ngx_cache_purge-$NGX_CACHE_PURGE_VERSION.tar.gz \
    && mv ngx_cache_purge-$NGX_CACHE_PURGE_VERSION ngx_cache_purge \
    && rm ngx_cache_purge-$NGX_CACHE_PURGE_VERSION.tar.gz \
    # configure and build
    && cd /tmp/nginx \
    && BASE_CONFIGURE_ARGS=`nginx -V 2>&1 | grep "configure arguments" | cut -d " " -f 3-` \
    && /bin/sh -c "./configure ${BASE_CONFIGURE_ARGS} --add-module=/tmp/ngx_cache_purge" \
    && make && make install \
    # cleanup
    && apt-get purge -y ${BUILD_DEPENDENCIES} \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/* /var/tmp/*

