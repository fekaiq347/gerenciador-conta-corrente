# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.2.8
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

# Receber o SECRET_KEY_BASE como build-arg e o expõe como ENV
ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE} 

# Install packages needed for deployment
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    libyaml-dev \
    nodejs \
    postgresql-client \
    git \
    vim-tiny && \
    rm -rf /var/lib/apt/lists/*


# Rails app lives here
WORKDIR /rails

# Set production environment
# ENV RAILS_ENV="production" \
ENV BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"


# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips pkg-config

# Install application gems
COPY Gemfile* ./
RUN bundle config set --local frozen false
RUN bundle install --jobs 4 --retry 3

RUN rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

RUN bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN RAILS_ENV=production SECRET_KEY_BASE=${SECRET_KEY_BASE} \
    ./bin/rails assets:precompile --trace 2>&1 | tee /tmp/assets_precompile.log


# Final stage for app image
FROM base


# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails /usr/local/bundle /rails/db /rails/log /rails/storage /rails/tmp /rails/config
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
