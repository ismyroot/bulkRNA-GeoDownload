FROM quay.io/1733295510/base-image:V1.1

LABEL maintainer="1733295510 <1733295510@qq.com>"
LABEL org.opencontainers.image.title="bulkRNA-GeoDownload"
LABEL org.opencontainers.image.description="GEO microarray download/runtime image for Quarto: GEOquery + httr/jsonlite/rmarkdown + network diagnostics tools."

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8

ARG R_INSTALL_NCPUS=4
ENV R_INSTALL_NCPUS=${R_INSTALL_NCPUS}

USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
    cmake \
    curl \
    wget \
    dnsutils \
    iputils-ping \
    locales \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    zlib1g-dev \
 && sed -i '/zh_CN.UTF-8/s/^# //g' /etc/locale.gen \
 && locale-gen zh_CN.UTF-8 \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists/*

RUN R -e "nc <- suppressWarnings(as.integer(Sys.getenv('R_INSTALL_NCPUS', '4'))); \
  nc <- if (is.na(nc) || nc < 1L) 1L else nc; \
  options(Ncpus = nc); \
  install.packages(c('BiocManager','httr','jsonlite','knitr','rmarkdown'), repos = 'https://cloud.r-project.org', ask = FALSE)" \
 && R -e "BiocManager::install('GEOquery', ask = FALSE, update = FALSE)" \
 && R -e 'suppressPackageStartupMessages({ \
    library(GEOquery); \
    library(httr); \
    library(jsonlite); \
    library(knitr); \
    library(rmarkdown); \
  }); \
  cat("GeoDownload OK: GEOquery ", as.character(packageVersion("GEOquery")), \
      " httr ", as.character(packageVersion("httr")), \
      " jsonlite ", as.character(packageVersion("jsonlite")), \
      " rmarkdown ", as.character(packageVersion("rmarkdown")), "\n", sep="")' \
 && command -v wget \
 && command -v curl \
 && command -v nslookup \
 && command -v ping

WORKDIR /work
