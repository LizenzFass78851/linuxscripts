#!/bin/bash
bash clock-script.sh | xargs -0 printf '\033[8;50;100t'
