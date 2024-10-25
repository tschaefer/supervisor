# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.3.5
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Copy build tools
COPY rootfs /

# Install base packages
RUN install_packages curl libjemalloc2 libvips sqlite3

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN install_packages build-essential git pkg-config

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/


# Final stage for app image
FROM base

VOLUME /rails/storage

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Install supervisor pre-requisites
RUN install_packages git
RUN curl -fsL https://get.docker.com | sh && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1001 rails && \
    useradd rails --uid 1001 --gid 1001 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

# Install sudo and allow the rails user to run docker
RUN install_packages sudo && \
    echo "rails ALL=(ALL) NOPASSWD: /usr/bin/docker" > /etc/sudoers.d/rails && \
    chmod 0440 /etc/sudoers.d/rails

USER 1001:1001

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]

# # Add image label information
# LABEL org.opencontainers.image.description="The Docker GitOps service"
# LABEL org.opencontainers.image.licenses=MIT
# LABEL org.opencontainers.image.source=https://github.com/tschaefer/supervisor
