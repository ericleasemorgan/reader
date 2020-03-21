#!/usr/bin/env bash

mkdir json
find ./zips -name "*.json" | parallel mv {} .json
