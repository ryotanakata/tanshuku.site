ARG RUBY_VERSION=3.3.0
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

FROM base AS build

# 必要なパッケージをインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential curl git libpq-dev libvips pkg-config python-is-python3

# Node.js インストール
ARG NODE_VERSION=20.11.0
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    rm -rf /tmp/node-build-master

# Ruby Gems インストール
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Node modules インストール
COPY package.json package-lock.json ./
RUN npm ci

# アプリケーションコードをコピー
COPY . .

# master.keyを明示的にコピー（Railway環境変数フォールバック用）
COPY config/master.key /rails/config/master.key

# Bootsnap プリコンパイル
RUN bundle exec bootsnap precompile app/ lib/

# Vite アセットビルド（重要！）
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# 本番用イメージ
FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# 作業ディレクトリを設定
WORKDIR /rails

# 必要なディレクトリを作成
RUN mkdir -p log storage tmp db

# セキュリティのため非rootユーザーで実行
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails /rails
USER rails:rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
CMD ["./bin/rails", "server"]