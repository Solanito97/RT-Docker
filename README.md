# Request Tracker (RT) in Docker

This repository contains a custom solution to install [Request Tracker (RT)](https://bestpractical.com/request-tracker) using Docker and Docker Compose. Since there is no official RT Docker image available, this setup uses a custom container based on Ubuntu 24.04 running RT 5.0.4 along with a MariaDB container for the database.

## Repository Contents

- **Dockerfile**  
  Defines the custom image that installs and configures RT on Ubuntu 24.04. It includes steps to download, build, and install RT, as well as copying configuration files.

- **docker-compose.yml**  
  Defines two services:
  - `rt`: The container running Request Tracker and Apache.
  - `db`: The container running MariaDB for RT's database.

- **entrypoint.sh**  
  A script executed when the RT container starts. It waits for the database to become available, checks if the RT database already exists (and skips initialization if it does), and then starts Apache.

- **rt-apache.conf**  
  The Apache configuration file tailored for RT. It sets the DocumentRoot and configures Apache to handle RT requests using mod_perl.

- **RT_SiteConfig.pm**  
  The main RT configuration file. This is where important settings are defined, such as database connection details and email options. Customize this file as needed.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop) installed on your system (this example uses Windows 11).
- Docker Desktop configured to use WSL 2 (Ubuntu 24.04 is recommended in WSL).
- Basic knowledge of Docker and command-line usage.

## Installation

1. **Clone the Repository**

   Clone the repository to your local system:
   ```bash
   git clone https://github.com/Solanito97/RT-Docker
   cd rt-docker
