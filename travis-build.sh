#!/bin/bash

set -e # exit the script automatically

BUILD_DIR=${TRAVIS_BUILD_DIR:-$(pwd)}

# Set command and targets
if [[ $NME ]]; then
    COMMAND=nme
    TARGETS="neko cpp"
fi
if [[ $LIME ]]; then
    COMMAND=lime
    TARGETS="neko cpp html5"
fi

# build example project
if [[ $COMMAND ]]; then
    for TARGET in $TARGETS; do
        echo "Building example with" $TARGET "using" $COMMAND
        cd $BUILD_DIR/example
        haxelib run $COMMAND build $TARGET || exit 1
    done
fi