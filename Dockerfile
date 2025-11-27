# Use pre-built base image
FROM ghcr.io/felixtcp/asoiafdle-base:latest AS build

# Set working directory
WORKDIR /home/opam/app

# Copy the rest of the source code
COPY --chown=opam:opam . .

# Decrypt the secret file
ARG DAILY_SELECTOR_KEY
RUN if [ -f lib/utils/daily_selector.ml.enc ]; then \
    openssl enc -aes-256-cbc -d -pbkdf2 \
    -in lib/utils/daily_selector.ml.enc \
    -out lib/utils/daily_selector.ml \
    -k "${DAILY_SELECTOR_KEY}"; \
    fi

# Build the project
RUN opam exec -- dune build

# Build Tailwind CSS
# Ensure the binary is executable
RUN chmod +x tailwindcss-linux-x64 && \
    ./tailwindcss-linux-x64 -i static/app.css -o static/output.css --minify

# Runtime stage
FROM debian:12-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libev4 \
    libsqlite3-0 \
    libssl3 \
    libgmp10 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy binary from build stage
# Note: Dune builds the executable as main.exe because (name main) in bin/dune
COPY --from=build /home/opam/app/_build/default/bin/main.exe /app/asoiafdle

# Copy static assets
COPY --from=build /home/opam/app/static /app/static

# Copy resources (characters.json, etc.)
COPY --from=build /home/opam/app/resources /app/resources

# Copy database schema (needed for auto-migration on startup)
COPY --from=build /home/opam/app/schema.sql /app/schema.sql

# Expose the port the app runs on
EXPOSE 8080

# Set the entrypoint
CMD ["./asoiafdle"]
