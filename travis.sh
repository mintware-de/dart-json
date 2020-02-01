#!/bin/bash

# Fast fail the script on failures.
set -e

# Run the tests.
dart test/tests.dart

# Install dart_coveralls; gather and send coverage data.
if [ "$REPO_TOKEN" ]; then
  pub global activate dart_coveralls
  pub global run dart_coveralls report \
    --token $REPO_TOKEN \
    --retry 2 \
    --exclude-test-files \
    test/tests.dart
fi