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
RUN --mount=type=cache,target=/root/.swiftpm swift build -c release

########## Runtime stage ##########
FROM swift:6.2-slim AS runtime
LABEL maintainer="tools-automation"
LABEL description="MomentumFinance runtime"

WORKDIR /app

# Create a non-root user
RUN groupadd -r swiftuser && useradd -r -g swiftuser -d /home/swiftuser -m swiftuser

# Copy built artifact from builder (use --chown to avoid chown -R)
COPY --from=builder --chown=swiftuser:swiftuser /src/.build/release/MomentumFinance /app/MomentumFinance

USER swiftuser

# Health check (adjust command to your service readiness probe)
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
  CMD ["/bin/sh", "-c", "test -x /app/MomentumFinance && /app/MomentumFinance --health || exit 1"]

CMD ["/app/MomentumFinance"]

# NOTE: For production, consider using a smaller runtime (distroless) and pin base image digests for reproducibility.
