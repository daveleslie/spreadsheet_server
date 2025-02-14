# Use a minimal and compatible base image
FROM ubuntu:24.04

# Set environment variables to configure LibreOffice in headless mode
ENV DEBIAN_FRONTEND=noninteractive \
  LIBREOFFICE_PROFILE=/home/libreuser/.config/libreoffice \
  HOME=/home/libreuser

# Install necessary dependencies
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  tini \
  gcc \
  python3 \
  python3-dev \
  python3-pip \
  libreoffice-calc \
  python3-uno \
  python3-virtualenv \
  && rm -rf /var/lib/apt/lists/*

# Create a non-root user for security
RUN useradd -m -s /bin/bash libreuser

# Set the working directory and copy project files
WORKDIR /home/libreuser/spreadsheet_server

# Create volume mount points
RUN mkdir -p spreadsheets saved_spreadsheets log

# Ensure volume mount point directories are owned by the non-root user
RUN chown -R libreuser:libreuser spreadsheets saved_spreadsheets log

COPY . .

# Create a virtual environment using virtualenv and install dependencies
RUN mkdir -p /home/libreuser/.virtualenvs && \
  virtualenv --system-site-packages -p python3 /home/libreuser/.virtualenvs/spreadsheet_server && \
  /home/libreuser/.virtualenvs/spreadsheet_server/bin/pip install --no-cache-dir -r requirements.txt

# Ensure directories are owned by the non-root user
RUN chown -R libreuser:libreuser /home/libreuser/spreadsheet_server

# Switch to non-root user
USER libreuser

# Expose the necessary port (adjust if needed)
EXPOSE 5555

# Use `tini` to manage processes cleanly
ENTRYPOINT ["/usr/bin/tini", "--"]

# Command to start both LibreOffice in headless mode and `spreadsheet_server`
CMD ["bash", "-c", "soffice --calc --headless --nologo --nofirststartwizard --accept='socket,host=0.0.0.0,port=2002;urp;' & \
  cd /home/libreuser/spreadsheet_server && /home/libreuser/.virtualenvs/spreadsheet_server/bin/python server.py"]
