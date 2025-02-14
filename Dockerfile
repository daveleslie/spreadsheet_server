FROM ubuntu:24.04

# Set environment variables to configure LibreOffice in headless mode
ENV DEBIAN_FRONTEND=noninteractive \
  LIBREOFFICE_PROFILE=/home/ubuntu/.config/libreoffice \
  HOME=/home/ubuntu

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

# Set the working directory and copy project files
WORKDIR /home/ubuntu/spreadsheet_server

COPY . .

# Create a virtual environment using virtualenv and install dependencies
RUN mkdir -p /home/ubuntu/.virtualenvs && \
  virtualenv --system-site-packages -p python3 /home/ubuntu/.virtualenvs/spreadsheet_server && \
  /home/ubuntu/.virtualenvs/spreadsheet_server/bin/pip install --no-cache-dir -r requirements.txt

# Expose the necessary port
EXPOSE 5555

# Use `tini` to manage processes cleanly
ENTRYPOINT ["/usr/bin/tini", "--"]

# Command to start both LibreOffice in headless mode and `spreadsheet_server`
CMD ["bash", "-c", "soffice --calc --headless --nologo --nofirststartwizard --accept='socket,host=0.0.0.0,port=2002;urp;' & \
  cd /home/ubuntu/spreadsheet_server && /home/ubuntu/.virtualenvs/spreadsheet_server/bin/python server.py"]
