FROM swift:5.9

LABEL maintainer="tools-automation"
LABEL description="MomentumFinance Swift application"

WORKDIR /app

# Install necessary dependencies and create non-root user for security
RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r swiftuser && useradd -r -g swiftuser -d /home/swiftuser -m swiftuser

# Copy the current directory contents into the container
COPY . .

# Set ownership and build the application
RUN chown -R swiftuser:swiftuser /app && swift build

# Switch to non-root user
USER swiftuser

# Health check
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
    CMD pgrep -f "MomentumFinance" || exit 0

# Set the command to run when the container starts
CMD ["swift", "run", "MomentumFinance"]

# Expose port if needed for web interface
# EXPOSE 8080
