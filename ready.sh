#!/usr/bin/env bash

http_code=`curl -s -o /dev/null -w "%{http_code}" http://localhost:8888/api`
[[ "$http_code" -lt "200" || "$http_code" -gt "299" ]] && exit 1

exit 0
