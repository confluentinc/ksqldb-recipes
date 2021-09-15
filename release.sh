#!/bin/bash

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "releasing branch $CURRENT_BRANCH to GH Pages"
mkdocs gh-deploy
