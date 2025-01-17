#!/usr/bin/env bash

set -e
SPDK_DIR=$1

$SPDK_DIR/configure --with-shared --without-isal

sudo $SPDK_DIR/scripts/setup.sh

make -C $SPDK_DIR -j$(nproc)

export SPDK_HEADER_DIR="$SPDK_DIR/include"
export SPDK_LIB_DIR="$SPDK_DIR/build/lib"
export DPDK_LIB_DIR="$SPDK_DIR/dpdk/build/lib"

# The default target is to make both the app and bdev and link them against the combined SPDK shared library libspdk.so.
make hello_world_bdev_shared_combo

sudo LD_LIBRARY_PATH=$SPDK_LIB_DIR:$DPDK_LIB_DIR:"./passthru" ./hello_world/hello_bdev -c ./hello_world/bdev_external.conf -b TestPT

make clean

# Make just the application linked against the combined SPDK shared library libspdk.so.
make hello_world_no_bdev_shared_combo

sudo LD_LIBRARY_PATH=$SPDK_LIB_DIR:$DPDK_LIB_DIR ./hello_world/hello_bdev -c ./hello_world/bdev.conf -b Malloc0

make clean

# Make both the application and bdev against individual SPDK shared libraries.
make hello_world_bdev_shared_iso

sudo LD_LIBRARY_PATH=$SPDK_LIB_DIR:$DPDK_LIB_DIR:"./passthru" ./hello_world/hello_bdev -c ./hello_world/bdev_external.conf -b TestPT

make clean

# Make just the application linked against individual SPDK shared libraries.
make hello_world_no_bdev_shared_iso

sudo LD_LIBRARY_PATH=$SPDK_LIB_DIR:$DPDK_LIB_DIR ./hello_world/hello_bdev -c ./hello_world/bdev.conf -b Malloc0

make clean

make -C $SPDK_DIR clean
$SPDK_DIR/configure --without-shared --without-isal
make -C $SPDK_DIR -j$(nproc)

# Make both the application and bdev against individual SPDK archives.
make hello_world_bdev_static

sudo LD_LIBRARY_PATH=$SPDK_LIB_DIR:$DPDK_LIB_DIR:"./passthru" ./hello_world/hello_bdev -c ./hello_world/bdev_external.conf -b TestPT

make clean

# Make just the application linked against individual SPDK archives.
make hello_world_no_bdev_static

sudo LD_LIBRARY_PATH=$SPDK_LIB_DIR:$DPDK_LIB_DIR ./hello_world/hello_bdev -c ./hello_world/bdev.conf -b Malloc0

make clean
