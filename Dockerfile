# syntax=docker/dockerfile:1.5

FROM swift:6.2 AS builder
LABEL maintainer="tools-automation"
LABEL description="MomentumFinance build stage"

WORKDIR /src

# Install build-only dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy manifest files first to leverage build cache
COPY Package.* ./
RUN --mount=type=cache,target=/root/.swiftpm swift package resolve

# Copy sources and build using SwiftPM cache
COPY . .
RUN --mount=type=cache,target=/root/.swiftpm swift build -c release --target MomentumFinanceCore

########## Runtime stage ##########
FROM swift:6.2-slim AS runtime
LABEL maintainer="tools-automation"
LABEL description="MomentumFinanceCore build artifacts"

WORKDIR /app

# Create a non-root user
RUN groupadd -r swiftuser && useradd -r -g swiftuser -d /home/swiftuser -m swiftuser

# Copy build artifacts from the Linux-compatible target
COPY --from=builder --chown=swiftuser:swiftuser /src/.build/release /app/.build/release

USER swiftuser

# Health check verifies build artifacts are present
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
  CMD ["/bin/sh", "-c", "test -d /app/.build/release || exit 1"]

CMD ["/bin/sh", "-lc", "ls -1 /app/.build/release | head -n 20"]

# NOTE: For production, consider using a smaller runtime (distroless) and pin base image digests for reproducibility.
