FROM postgres:11

RUN apt-get update \
 && apt-get -y install python3 postgresql-plpython3-11 \
 && apt-get clean \
 && rm -rf /var/cache/apt/* /var/lib/apt/lists/*