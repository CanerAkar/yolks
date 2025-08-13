FROM ghcr.io/navidrome/navidrome:latest

# Remove the hardcoded entrypoint to allow Pterodactyl to use custom startup commands
ENTRYPOINT ["/bin/sh", "-c"]

# Set default command (can be overridden by Pterodactyl)
CMD ["/app/navidrome"]