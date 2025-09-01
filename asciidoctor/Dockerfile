
FROM ruby:3.3-slim

RUN apt-get update \
    && apt-get install -y build-essential fonts-dejavu \
                       graphviz openjdk-21-jre-headless \
                       imagemagick bash libmagick++-dev \
    && rm -rf /var/lib/apt/lists/*

RUN gem install asciidoctor asciidoctor-pdf asciidoctor-diagram \
    rouge coderay gruff

WORKDIR /extensions
COPY chart.rb /extensions/chart.rb

WORKDIR /work

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

SHELL [ "/bin/bash", "-c" ]
ENTRYPOINT [ "/entrypoint.sh" ]

