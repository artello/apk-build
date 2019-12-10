#!/bin/sh

APPNAME=$1
VERSION=$2
BUILD=$3

cat << EOF
pkgname=$APPNAME
pkgver=$VERSION
pkgrel=$BUILD
pkgdesc="Studio App"
arch="x86_64"
options="!check"
pkgusers="studio"
pkggroups="studio"
license="MIT"

depends="
  bash
  curl
"

makedepends="
  elixir
  erlang-crypto
  erlang-syntax-tools
  erlang-hipe
  erlang-parsetools
  erlang-runtime-tools
  erlang-observer
  erlang-tools
  erlang-xmerl
  erlang-eunit
  nodejs
  yarn
"

install="
  $pkgname.pre-install
  $pkgname.post-install
  $pkgname.post-upgrade
  $pkgname.pre-deinstall
"

source="
  $pkgname-$pkgver.tar
  studio.initd
  service/run
  bin/config_$pkgname
"

root=../../..

snapshot() {
  abuild clean
  abuild deps

  cd $startdir
  tar --exclude='.apk' -cf "$pkgname-$pkgver.tar" ${root} 

  abuild checksum
}

build() {
  echo "--- Compiling Assets"
  cd "$srcdir/assets"
  yarn install
  yarn run build

  echo "--- Installing Production Deps"
  cd "$srcdir"
  mix local.hex --force
  mix local.rebar --force
  MIX_ENV=prod mix do deps.get --only prod, compile

  echo "--- Building Production Release"
  MIX_ENV=prod mix release --env=prod
}

check() {
  abuild clean
  abuild deps

  export MIX_ENV=test

  echo "--- Preparing for Tests"
  cd "$root"

  mix local.hex --force
  mix local.rebar --force
  mix deps.get --only test

  echo "--- Running Tests"
  mix ecto.drop
  mix ecto.create
  mix ecto.migrate
}

package() {
  mkdir -p "$pkgdir"

  echo "--- Packaging"
	cd "$pkgdir"

  install -dm755 -o $pkgusers -g $pkggroups ./var/lib/"$pkgname"/
  install -dm755 -g $pkggroups ./var/www/localhost/htdocs/console/

  mv -v "$srcdir"/_build/prod/rel/"$pkgname"/* ./var/lib/"$pkgname"/

  install -Dm755 "$srcdir"/$pkgname.initd ./etc/init.d/$pkgname
  install -Dm755 "$srcdir"/run ./var/lib/$pkgname/service/run
  install -Dm755 "$srcdir"/config_$pkgname ./usr/bin/config_$pkgname
}
EOF