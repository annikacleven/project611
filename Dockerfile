FROM rocker/verse
#RUN apt update && apt install -y man-db && rm -rf /var/lib/apt/lists/*
#RUN yes|unminimize

#ARG USER_ID
#RUN usermod -u $USER_ID rstudio 
#&& groupmod -g $GROUP_ID rstudio
#RUN chown -R rstudio:rstudio /home/rstudio

#INSTALL packages
RUN R -e "install.packages(c('lubridate','glmnet','caTools', 'gbm', 'kableExtra'))"

#python 
RUN apt update -y && apt install -y python3-pip
RUN pip3 install jupyter jupyterlab

#sql
#RUN wget https://sqlite.org/snapshot/sqlite-snapshot-202110132029.tar.gz
#RUN tar xvf sqlite-snapshot-202110132029.tar.gz
#WORKDIR sqlite-snapshot-202110132029
#RUN ./configure && make && make install
#WORKDIR /
