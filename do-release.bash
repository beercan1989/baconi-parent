#!/bin/bash
set -e

mvn --batch-mode release:clean release:prepare release:perform
