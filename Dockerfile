# Use the official Ruby image from Docker Hub
FROM ruby:2.6.6

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and Yarn
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    nodejs \
    yarn \
    && rm -rf /var/lib/apt/lists/*

# Create and set the working directory
RUN mkdir /app
WORKDIR /app

# Copy Gemfile, Gemfile.lock, and package.json to the working directory
COPY Gemfile Gemfile.lock package.json ./

# Install Bundler and project dependencies
RUN gem install bundler:2.1.4
RUN bundle install --jobs "$(nproc)" --retry 5

# Copy the rest of the application code to the working directory
COPY . .

# Expose port 3000 for the Rails server
EXPOSE 3000

# Command to start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
