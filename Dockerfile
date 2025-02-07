ARG MINIFORGE_VERSION=22.9.0-2
FROM condaforge/mambaforge:${MINIFORGE_VERSION} AS builder
# Use mamba to install tools and dependencies into /usr/local
ARG SAMTOOLS_VERSION=1.21
RUN mamba create -qy -p /usr/local \
    -c conda-forge \
    -c bioconda \
    --strict-channel-priority \
    samtools==${SAMTOOLS_VERSION}

# Deploy the target tools into a base image
FROM ubuntu:20.04
COPY --from=builder /usr/local /usr/local
# Install gnuplot using apt instead of conda
RUN apt-get update && \
    apt-get install -y --no-install-recommends gnuplot-nox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add a new user/group called bldocker
RUN groupadd -g 500001 bldocker && \
    useradd -r -u 500001 -g bldocker bldocker
# Change the default user to bldocker from root
USER bldocker
LABEL maintainer="Rupert Hugh-White <rhughwhite@mednet.ucla.edu>" \
org.opencontainers.image.source=https://github.com/uclahs-cds/docker-SAMtools
