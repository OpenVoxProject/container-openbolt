ARG BASE_IMAGE=docker.io/library/ruby:3.4-alpine

# Define gem versions once; each stage imports these global defaults below.
# renovate: depName=bundler datasource=rubygems
ARG RUBYGEM_BUNDLER=2.7.2
# renovate: depName=openbolt datasource=rubygems
ARG RUBYGEM_OPENBOLT=5.2.0

FROM $BASE_IMAGE AS builder

# Import the global gem version defaults into this stage.
ARG RUBYGEM_BUNDLER
ARG RUBYGEM_OPENBOLT

ENV RUBYGEM_BUNDLER=${RUBYGEM_BUNDLER}
ENV RUBYGEM_OPENBOLT=${RUBYGEM_OPENBOLT}

COPY openbolt/Gemfile /opt/openbolt/Gemfile

RUN apk update \
    && apk upgrade \
    && apk add --no-cache --update \
       alpine-sdk \
       yaml-dev \
       libffi-dev \
    && rm -rf /usr/local/lib/ruby/gems/*/gems/bundler-* \
    && rm -rf /usr/local/lib/ruby/gems/*/specifications/default/bundler-*.gemspec \
    && gem install bundler -v ${RUBYGEM_BUNDLER} \
    && cd /opt/openbolt \
    && bundle config set jobs $(nproc) \
    && bundle config set path /opt/openbolt/vendor/bundle \
    && bundle install --gemfile=/opt/openbolt/Gemfile \
    && bundle clean --force

###############################################################################

FROM $BASE_IMAGE AS final

LABEL org.label-schema.maintainer="Voxpupuli Team <voxpupuli@groups.io>" \
      org.label-schema.vendor="Voxpupuli" \
      org.label-schema.url="https://github.com/openvoxproject/container-openbolt" \
      org.label-schema.name="Vox Pupuli OpenBolt" \
      org.label-schema.license="AGPL-3.0-or-later" \
      org.label-schema.vcs-url="https://github.com/openvoxproject/container-openbolt" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.dockerfile="/Containerfile"

# Import the global gem version defaults into this stage.
ARG RUBYGEM_BUNDLER
ARG RUBYGEM_OPENBOLT

ENV RUBYGEM_BUNDLER=${RUBYGEM_BUNDLER}
ENV RUBYGEM_OPENBOLT=${RUBYGEM_OPENBOLT}

# Bundler needs to know where the Gemfile and gems are located.
ENV BUNDLE_GEMFILE=/opt/openbolt/Gemfile
ENV BUNDLE_PATH=/opt/openbolt/vendor/bundle
ENV BUNDLE_APP_CONFIG=/opt/openbolt/vendor/bundle

RUN apk update \
    && apk upgrade \
    && gem install bundler -v ${RUBYGEM_BUNDLER} \
    # CVE fixes are installed in the OpenBolt bundle, so remove vulnerable default gems.
    && rm -rf /usr/local/lib/ruby/gems/*/gems/cgi-* \
    && rm -rf /usr/local/lib/ruby/gems/*/specifications/default/cgi-*.gemspec \
    && rm -rf /usr/local/lib/ruby/gems/*/gems/stringio-* \
    && rm -rf /usr/local/lib/ruby/gems/*/specifications/default/stringio-*.gemspec \
    && rm -rf /usr/local/lib/ruby/gems/*/gems/rdoc-* \
    && rm -rf /usr/local/lib/ruby/gems/*/specifications/default/rdoc-*.gemspec \
    && rm -rf /usr/local/lib/ruby/gems/*/gems/racc-* \
    && rm -rf /usr/local/lib/ruby/gems/*/specifications/default/racc-*.gemspec \
    && rm -rf /usr/local/lib/ruby/gems/*/gems/drb-* \
    && rm -rf /usr/local/lib/ruby/gems/*/specifications/default/drb-*.gemspec \
    && rm -rf /usr/local/lib/ruby/gems/*/gems/csv-* \
    && rm -rf /usr/local/lib/ruby/gems/*/specifications/default/csv-*.gemspec \
    && rm -rf /usr/local/lib/ruby/gems/*/gems/minitest-* \
    && rm -rf /usr/local/lib/ruby/gems/*/specifications/minitest-*.gemspec \
    && addgroup -g 1001 -S openbolt \
    && adduser -u 1001 -S -G openbolt openbolt \
    && mkdir /data \
    && chown openbolt:openbolt /data

COPY --from=builder /opt/openbolt /opt/openbolt
RUN chown openbolt:openbolt /opt/openbolt/Gemfile.lock

COPY Containerfile /

WORKDIR /data
USER openbolt

ENTRYPOINT [ "bundle", "exec", "bolt" ]
CMD [ "-h" ]
