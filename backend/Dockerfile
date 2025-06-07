# # syntax = docker/dockerfile:1

### Base: imagem Ruby mínima com ENV básica
ARG RUBY_VERSION=3.2.8
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

# Receber o SECRET_KEY_BASE como build-arg e o expõe como ENV
ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE} 

# Instala dependências essenciais para runtime Rails
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
ENV BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"


### Build: instala as gems e prepara a aplicação
FROM base AS build

# Dependências adicionais pra compilação das gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips pkg-config

# Copia os arquivos de dependência e instala as gems
COPY Gemfile* ./
RUN bundle config set --local frozen false
RUN bundle install --jobs 4 --retry 3

RUN rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Precompile do bootsnap
RUN bundle exec bootsnap precompile --gemfile

# Copia o restante da aplicação
COPY . .

# Precompile adicional para código Ruby e assets
RUN bundle exec bootsnap precompile app/ lib/

# Precompilar os assets pra produção
RUN RAILS_ENV=production SECRET_KEY_BASE=${SECRET_KEY_BASE} \
    ./bin/rails assets:precompile --trace 2>&1 | tee /tmp/assets_precompile.log


### Final: imagem enxuta com app pronta para produção
FROM base


# Copia gems e aplicação do build
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Cria um usuário não-root pensando na segurança e também dá permissão às pastas necessárias
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp config
USER rails:rails

# Entrypoint prepara o banco
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expõe a porta e FINALMENTE inicia o servidor
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
