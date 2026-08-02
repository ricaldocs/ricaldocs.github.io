FROM ruby:3.4.8-alpine

RUN apk add --no-cache build-base git

ENV GEM_HOME=/usr/local/bundle
ENV PATH=/usr/local/bundle/bin:$PATH

RUN gem install jekyll bundler

WORKDIR /srv/jekyll

EXPOSE 4000

CMD ["jekyll", "--help"]