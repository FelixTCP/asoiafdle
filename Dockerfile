# Build stage
FROM ocaml/opam:debian-12-ocaml-5.1 AS build

# Install system dependencies
# libev-dev: for Dream (lwt_ppx/libev)
# libsqlite3-dev: for caqti-driver-sqlite3
# pkg-config: for finding libraries
# libssl-dev: for SSL support
# libgmp-dev: for zarith/mirage-crypto if needed
RUN sudo apt-get update && sudo apt-get install -y \
    libev-dev \
    libsqlite3-dev \
    pkg-config \
    libssl-dev \
    libgmp-dev \
    libffi-dev

# Set working directory
WORKDIR /home/opam/app

# Copy opam files first to cache dependencies
COPY --chown=opam:opam dune-project asoiafdle.opam ./

# Install dependencies
ENV OPAMSOLVERTIMEOUT=600
ENV OPAMJOBS=4
RUN sudo apt-get update && opam update
RUN opam install . --deps-only --jobs=4

# Copy the rest of the source code
COPY --chown=opam:opam . .

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

# Copy database schema (needed for auto-migration on startup)
COPY --from=build /home/opam/app/schema.sql /app/schema.sql

# Expose the port the app runs on
EXPOSE 8080

# Set the entrypoint
CMD ["./asoiafdle"]
