FROM swift:6.2

WORKDIR /app

# Install necessary dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN groupadd -r swiftuser && useradd -r -g swiftuser -d /home/swiftuser -m swiftuser

# Copy the current directory contents into the container
COPY . .

# Set ownership and build the application
RUN chown -R swiftuser:swiftuser /app && swift build

# Switch to non-root user
USER swiftuser

# Set the command to run when the container starts
CMD ["swift", "run", "MomentumFinance"]

# Expose port if needed for web interface
# EXPOSE 8080
