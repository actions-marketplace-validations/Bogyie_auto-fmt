#!/bin/sh -l

GITHUB_TOKEN=$1
REPO=$2
BASE_REF=$3
HEAD_REF=$4

git clone "https://$GITHUB_TOKEN@github.com/$REPO repo"