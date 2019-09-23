FROM postgres:11

WORKDIR /tmp

# Mecab とビルドツールをインストール
RUN apt-get update && apt-get install -y \
  gcc make patch git sudo curl \
  mecab libmecab-dev mecab-ipadic-utf8 \
  postgresql-server-dev-11 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# textsearch_ja のインストール
RUN git clone https://github.com/oknj/textsearch_ja.git
RUN cd textsearch_ja && make && make install
RUN ln -s /usr/share/postgresql/11/extension/textsearch_ja--42.sql \
  /docker-entrypoint-initdb.d/000-textsearch_ja.sql
RUN echo "CREATE EXTENSION textsearch_ja;" > /docker-entrypoint-initdb.d/001-textsearch_ja-load.sql

# NEologd のインストール
# NEologd を試すには以下のコメントを外す。
# イメージサイズが１Gほど増えるので注意
#RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git
#RUN mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd -n -y -p /var/lib/mecab/dic/mecab-ipadic-neologd \
#  && rm -rf mecab-ipadic-neologd
#RUN echo "dicdir = /var/lib/mecab/dic/mecab-ipadic-neologd" > /etc/mecabrc
