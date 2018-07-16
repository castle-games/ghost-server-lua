FROM alpine:3.8

# Set environment
ENV OPENRESTY_VERSION=1.13.6.1 \
    OPENRESTY_PREFIX=/usr/local/openresty \
    LUAROCKS_VERSION=2.4.4 \
    LAPIS_VERSION=1.7.0
ENV LAPIS_OPENRESTY=${OPENRESTY_PREFIX}/nginx/sbin/nginx \
    PATH=${OPENRESTY_PREFIX}/bin:${OPENRESTY_PREFIX}/luajit/bin:${OPENRESTY_PREFIX}/nginx/sbin:${PATH}
ENV MOONSCRIPT_VERSION=0.5.0

# Set Build Deps
ENV BUILD_DEPS \
        ca-certificates \
        make \
        perl \
        zlib-dev

# Set Persistent Deps
ENV PERSISTENT_DEPS \
        g++ \
        openssl-dev \
        pcre-dev \
        wget \
        unzip

# Install dep packages
RUN set -xe && \
        apk add --no-cache --virtual .build-deps ${BUILD_DEPS} && \
        apk add --no-cache --virtual .persistent-deps ${PERSISTENT_DEPS} && \
        update-ca-certificates && \
        echo "Installed dependency packages with apk."


# Install OpenResty
RUN set -xe && \
        wget https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz && \
        tar xf openresty-${OPENRESTY_VERSION}.tar.gz && \
        cd openresty-${OPENRESTY_VERSION} && \
        ./configure \
            --prefix=${OPENRESTY_PREFIX} \
            --with-luajit \
            --with-http_realip_module \
            --with-http_stub_status_module \
        && make && make install && \
        cd .. && rm -rf openresty-${OPENRESTY_VERSION}.tar.gz openresty-${OPENRESTY_VERSION} && \
        echo "Installed OpenResty."

# Symlinks
RUN set -xe && \
    ln -sf ${OPENRESTY_PREFIX}/luajit/bin/luajit ${OPENRESTY_PREFIX}/luajit/bin/lua && \
    ln -sf ${OPENRESTY_PREFIX}/luajit/bin/luajit /usr/local/bin/luajit && \
    ln -sf /usr/local/bin/lua /usr/local/bin/lua && \
    echo "Made symlinks."

# Install LuaRocks
RUN set -xe && \
        wget https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz && \
        tar xf luarocks-${LUAROCKS_VERSION}.tar.gz && \
        cd luarocks-${LUAROCKS_VERSION} && \
        ./configure \
            --with-lua=${OPENRESTY_PREFIX}/luajit \
            --with-lua-include=${OPENRESTY_PREFIX}/luajit/include/luajit-2.1 \
        && make build && make install && \
        cd .. && rm -rf luarocks-${LUAROCKS_VERSION}.tar.gz luarocks-${LUAROCKS_VERSION} && \
        echo "Installed LuaRocks."

# Remove deps
RUN set -xe && \
        apk del .build-deps && \
        echo "Removed build deps."

#Install lapis and moonscript
RUN set -xe && \
        luarocks install lapis ${LAPIS_VERSION} && luarocks install moonscript ${MOONSCRIPT_VERSION} && \
        echo "Installed lapis and moonscript."

# Install readline and luaprompt for repl
RUN set -xe && \
        apk add readline-dev && \
        luarocks install luaprompt && \
        echo "Installed luaprompt."

# Install postgres client
RUN set -xe && \
        apk add postgresql-client && \
        apk add  pgcli --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted && \
        echo "Installed psql and pgcli."

# cd ${OPENRESTY_PREFIX}/nginx/conf && mv nginx.conf nginx.conf.bk && lapis new && moonc *.moon && \

# # Set work directory
# WORKDIR ${OPENRESTY_PREFIX}/nginx/conf
WORKDIR /ghost-server
ENV PATH=${PATH}:/ghost-server/lua_modules/bin

# Add git
RUN apk add git

# Expose ports
EXPOSE 8080
EXPOSE 80

# Install bash
RUN apk add bash
RUN ln -sf /ghost-server/bashrc ${HOME}/.bashrc

# Install vim
RUN apk add vim

ENTRYPOINT [ "./container-commands" ]
CMD []

