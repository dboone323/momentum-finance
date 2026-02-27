# syntax=docker/dockerfile:1.5
# momentum-finance - Linux source image for split-platform CI

FROM swift:6.2 AS builder

WORKDIR /src

# Resolve dependencies for Linux-side validation; app compilation remains on macOS CI.
COPY Package.* ./
RUN --mount=type=cache,target=/root/.swiftpm,id=swiftpm \
    swift package resolve

COPY . .

FROM swift:6.2-slim

LABEL maintainer="tools-automation"
LABEL description="Momentum Finance source workspace (Linux tooling image)"
LABEL org.opencontainers.image.source="https://github.com/tools-automation/momentum-finance"
LABEL org.opencontainers.image.documentation="https://github.com/tools-automation/momentum-finance/wiki"

WORKDIR /workspace

RUN groupadd -r financeuser && useradd -r -g financeuser -u 1001 financeuser

COPY --from=builder --chown=financeuser:financeuser /src /workspace

USER financeuser

HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
    CMD test -f /workspace/Package.swift || exit 1

CMD ["/bin/sh", "-lc", "echo 'momentum-finance source container ready (macOS builds app binaries)'; sleep infinity"]
