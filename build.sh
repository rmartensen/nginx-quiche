#!/usr/bin/env bash

curl -O https://nginx.org/download/nginx-1.16.1.tar.gz
tar xzvf nginx-1.16.1.tar.gz

if [ ! -d quiche/.git ]; then
  git clone --recursive https://github.com/cloudflare/quiche
  git submodule update --recursive
else
  pushd quiche
  git pull
  git submodule update --recursive
  popd
fi

pushd nginx-1.16.1
patch -p01 < ../quiche/extras/nginx/nginx-1.16.patch

./configure                                 \
       --prefix=$PWD                           \
       --build="quiche-$(git --git-dir=../quiche/.git rev-parse --short HEAD)" \
       --with-http_ssl_module                  \
       --with-http_v2_module                   \
       --with-http_v3_module                   \
       --with-openssl=../quiche/deps/boringssl \
       --with-quiche=../quiche
make -j2
