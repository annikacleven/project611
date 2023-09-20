#!/bin/bash

#docker build . --build-arg=USER_ID$(id -u) --build-arg GROUP_ID=$(id -g) -t project611
docker build --build-arg USER_ID=$(id -u)  -t my_image .
#docker run --rm -v $(pwd):/home/rstudio/work -p 8787:8787 -it project611
docker run -v $(pwd):/home/rstudio/work -p 8667:8787 -it project611
