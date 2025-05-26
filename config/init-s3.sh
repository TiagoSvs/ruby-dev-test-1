#!/bin/bash
set -e

aws --endpoint-url=http://localhost:4566 s3 mb s3://meu-bucket-teste