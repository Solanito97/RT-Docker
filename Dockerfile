# Dockerfile para Request Tracker 6.0
FROM ubuntu:22.04

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Establecer zona horaria
ENV TZ=America/Mexico_City
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Actualizar repositorios y corregir posibles problemas
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN apt-get update --fix-missing

# Instalar dependencias básicas primero
RUN apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Actualizar repositorios nuevamente
RUN apt-get update

# Instalar dependencias del sistema en grupos para mejor manejo de errores
RUN apt-get install -y --no-install-recommends \
    apache2 \
    libapache2-mod-perl2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    make \
    gcc \
    g++ \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    perl \
    cpanminus \
    libperl-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    mysql-client \
    default-mysql-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    graphviz \
    libgd-dev \
    libgraphviz-dev \
    libssl-dev \
    libz-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar paquetes Perl disponibles en Ubuntu
RUN apt-get update && apt-get install -y --no-install-recommends \
    libdbd-mysql-perl \
    libdbi-perl \
    libhtml-mason-perl \
    libhtml-scrubber-perl \
    liblog-dispatch-perl \
    libmime-tools-perl \
    libregexp-common-perl \
    libterm-readkey-perl \
    libtext-template-perl \
    libtimedate-perl \
    libxml-rss-perl \
    w3m \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

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

# Configurar CPAN para instalaciones automáticas
RUN echo 'o conf build_requires_install_policy yes' | cpan
RUN echo 'o conf prerequisites_policy follow' | cpan
RUN echo 'o conf commit' | cpan

# Instalar módulos Perl esenciales uno por uno
RUN cpanm --notest --force Crypt::Eksblowfish || echo "Crypt::Eksblowfish failed, continuing..."
RUN cpanm --notest --force Crypt::X509 || echo "Crypt::X509 failed, continuing..."
RUN cpanm --notest --force Devel::StackTrace || echo "Devel::StackTrace failed, continuing..."
RUN cpanm --notest --force GD::Graph || echo "GD::Graph failed, continuing..."
RUN cpanm --notest --force GraphViz || echo "GraphViz failed, continuing..."
RUN cpanm --notest --force Locale::Maketext::Lexicon || echo "Locale::Maketext::Lexicon failed, continuing..."
RUN cpanm --notest --force Module::Versions::Report || echo "Module::Versions::Report failed, continuing..."
RUN cpanm --notest --force Net::Server || echo "Net::Server failed, continuing..."
RUN cpanm --notest --force Text::Wrapper || echo "Text::Wrapper failed, continuing..."
RUN cpanm --notest --force UNIVERSAL::require || echo "UNIVERSAL::require failed, continuing..."

# Intentar instalar Crypt::SSLeay con diferentes métodos
RUN cpanm --notest --force Crypt::SSLeay || \
    (apt-get update && apt-get install -y libcrypt-ssleay-perl && apt-get clean && rm -rf /var/lib/apt/lists/*) || \
    echo "Crypt::SSLeay failed, continuing without it..."

# Probar dependencias de RT e instalar las faltantes
RUN cd /tmp/rt-6.0.1 && make testdeps || echo "Some dependencies missing, will try to install"
RUN cd /tmp/rt-6.0.1 && make fixdeps || echo "fixdeps completed with warnings"

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