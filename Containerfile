ARG BASE_IMAGE=docker.io/library/ruby:3.2-alpine

FROM $BASE_IMAGE AS builder

# Gems have to be ARG and ENV because they are used as reference in the Gemfile
ARG RUBYGEM_BUNDLER
ARG RUBYGEM_OPENBOLT

ENV RUBYGEM_BUNDLER=${RUBYGEM_BUNDLER:-2.7.2}
ENV RUBYGEM_OPENBOLT=${RUBYGEM_OPENBOLT:-5.2.0}

COPY openbolt/Gemfile /

RUN apk update \
    && apk upgrade \
    && apk add --no-cache --update alpine-sdk yaml-dev \
    && rm -rf /usr/local/lib/ruby/gems/*/gems/bundler-* \
    && rm -rf /usr/local/lib/ruby/gems/*/specifications/default/bundler-*.gemspec \
    && gem install bundler -v ${RUBYGEM_BUNDLER} \
    && bundle config set path.system true \
    && bundle config set jobs $(nproc) \
    && bundle install --gemfile=/Gemfile \
    && bundle clean --force \
    && rm -rf /usr/local/lib/ruby/gems/*/cache/* \
    && rm -rf /usr/local/lib/ruby/gems/*/gems/cgi-* \
    && rm -rf /usr/local/lib/ruby/gems/*/specifications/default/cgi-*.gemspec \
    && rm -rf /usr/local/lib/ruby/gems/*/gems/stringio-* \
    && rm -rf /usr/local/lib/ruby/gems/*/specifications/default/stringio-*.gemspec \
    && rm -rf /usr/local/lib/ruby/gems/*/gems/rdoc-* \
    && rm -rf /usr/local/lib/ruby/gems/*/specifications/default/rdoc-*.gemspec \
    && rm -rf /usr/local/lib/ruby/gems/*/gems/rexml-* \
    && rm -rf /usr/local/lib/ruby/gems/*/specifications/rexml-*.gemspec \
    && rm -rf /usr/local/lib/ruby/gems/*/gems/racc-* \
    && rm -rf /usr/local/lib/ruby/gems/*/specifications/default/racc-*.gemspec \
    && rm -rf /usr/local/lib/ruby/gems/*/gems/drb-* \
    && rm -rf /usr/local/lib/ruby/gems/*/specifications/default/drb-*.gemspec \
    && rm -rf /usr/local/lib/ruby/gems/*/gems/csv-* \
    && rm -rf /usr/local/lib/ruby/gems/*/specifications/default/csv-*.gemspec \
    && rm -rf /usr/local/lib/ruby/gems/*/gems/minitest-* \
    && rm -rf /usr/local/lib/ruby/gems/*/specifications/minitest-*.gemspec

###############################################################################

FROM $BASE_IMAGE AS final

LABEL org.label-schema.maintainer="Voxpupuli Team <voxpupuli@groups.io>" \
      org.label-schema.vendor="Voxpupuli" \
      org.label-schema.url="https://github.com/openvoxproject/container-openbolt^" \
      org.label-schema.name="Vox Pupuli OpenBolt" \
      org.label-schema.license="AGPL-3.0-or-later" \
      org.label-schema.vcs-url="https://github.com/openvoxproject/container-openbolt" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.dockerfile="/Containerfile"

RUN apk update \
    && apk upgrade \
    && rm -rf /usr/local/lib/ruby/gems \
    && addgroup -g 1001 -S openbolt \
    && adduser -u 1001 -S -G openbolt openbolt \
    && rm -rf /usr/local/lib/ruby/gems \
    && mkdir /data \
    && chown openbolt:openbolt /data

COPY --from=builder /usr/local/lib/ruby/gems /usr/local/lib/ruby/gems
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /Gemfile.lock /Gemfile.lock
COPY Containerfile /
COPY openbolt/Gemfile /

WORKDIR /data
USER openbolt

ENTRYPOINT [ "bolt" ]
CMD [ "-h" ]
