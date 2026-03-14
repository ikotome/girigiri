FROM ruby:3.3.6

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  postgresql-client \
  nodejs \
  && rm -rf /var/lib/apt/lists/*

ENV BUNDLE_PATH /usr/local/bundle
ENV BUNDLE_BIN /usr/local/bundle/bin
ENV PATH $BUNDLE_BIN:$PATH

RUN mkdir /girigiri
WORKDIR /girigiri

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]