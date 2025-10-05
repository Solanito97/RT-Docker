# Dockerfile para Request Tracker 6.0
FROM ubuntu:22.04

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Establecer zona horaria
ENV TZ=America/Mexico_City
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-perl2 \
    build-essential \
    cpanminus \
    curl \
    git \
    graphviz \
    libcrypt-eksblowfish-perl \
    libcrypt-ssleay-perl \
    libcrypt-x509-perl \
    libdbd-mysql-perl \
    libdbi-perl \
    libdevel-stacktrace-perl \
    libgd-dev \
    libgd-graph-perl \
    libgraphviz-perl \
    libhtml-mason-perl \
    libhtml-scrubber-perl \
    liblocale-maketext-lexicon-perl \
    liblog-dispatch-perl \
    libmime-tools-perl \
    libmodule-versions-report-perl \
    libnet-server-perl \
    libregexp-common-perl \
    libterm-readkey-perl \
    libtext-template-perl \
    libtext-wrapper-perl \
    libtime-modules-perl \
    libtimedate-perl \
    libuniversal-require-perl \
    libxml-rss-perl \
    make \
    mysql-client \
    perl \
    starman \
    w3m \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario rt
RUN useradd -r -s /bin/bash -d /opt/rt6 rt

# Descargar y compilar Request Tracker 6.0
WORKDIR /tmp
RUN wget https://download.bestpractical.com/pub/rt/release/rt-6.0.1.tar.gz
RUN tar -xzf rt-6.0.1.tar.gz
WORKDIR /tmp/rt-6.0.1

# Configurar y compilar RT
RUN ./configure \
    --prefix=/opt/rt6 \
    --with-web-user=www-data \
    --with-web-group=www-data \
    --with-rt-group=rt \
    --with-db-type=mysql \
    --with-db-host=mysql \
    --with-db-rt-user=rt_user \
    --with-db-rt-pass=rt_password \
    --with-db-database=rt6 \
    --enable-graphviz \
    --enable-gd \
    --with-web-handler=fastcgi

# Instalar dependencias Perl
RUN make testdeps && make fixdeps

# Compilar e instalar RT
RUN make install

# Configurar permisos
RUN chown -R rt:rt /opt/rt6/var
RUN chgrp -R www-data /opt/rt6/var
RUN chmod -R g+w /opt/rt6/var

# Configurar Apache
COPY apache/rt.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite
RUN a2enmod fastcgi
RUN a2enmod alias

# Copiar script de inicialización
COPY scripts/init-rt.sh /usr/local/bin/init-rt.sh
RUN chmod +x /usr/local/bin/init-rt.sh

# Copiar configuración base
COPY config/RT_SiteConfig.pm /opt/rt6/etc/RT_SiteConfig.pm

# Exponer puerto
EXPOSE 80

# Script de entrada
CMD ["/usr/local/bin/init-rt.sh"]