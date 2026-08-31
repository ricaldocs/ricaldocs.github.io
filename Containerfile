FROM docker.io/ruby:3.4.8-alpine

# Install dependencies
RUN apk add --no-cache build-base git bash

# Set environment variables
ENV GEM_HOME=/usr/local/bundle
ENV PATH=/usr/local/bundle/bin:$PATH
ENV BUNDLE_SILENCE_ROOT_WARNING=1

# Install Jekyll and Bundler
RUN gem install jekyll bundler

# Configure git safe directory
RUN git config --global --add safe.directory /srv/jekyll

# Set working directory
WORKDIR /srv/jekyll

# Expose port
EXPOSE 4000

# Default command
CMD ["jekyll", "--help"]