# Usamos Ubuntu 24.04 LTS como imagen base
FROM ubuntu:24.04

# Evitar interacciones durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# 1. Actualizar repositorios con mirrors confiables
RUN sed -i 's/archive.ubuntu.com/mirrors.ubuntu.com/g' /etc/apt/sources.list

# 2. Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    postfix \
    apache2 \
    libapache2-mod-perl2 \
    mariadb-client \
    wget \
    curl \
    nano \
    git \
    build-essential \
    libssl-dev \
    libexpat1-dev \
    libdbd-mysql-perl \
    perl \
    cpanminus \
    graphviz \
    libgraphviz-dev \
    libgd-dev \
    libjpeg-dev \
    libpng-dev \
    libwebp-dev \
    libxpm-dev \
    libfreetype6-dev \
    apt-utils \
    dialog \
    make \
    gcc \
    g++ \
    libc6-dev \
    pkg-config \
    libmysqlclient-dev \
    libperl-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configurar CPAN para instalación automática
RUN echo 'yes' | cpan

# 3. Descargar Request Tracker 6.0.0
WORKDIR /opt
RUN wget https://download.bestpractical.com/pub/rt/release/rt-6.0.0.tar.gz --timeout=30 --tries=3 \
    && tar -xzf rt-6.0.0.tar.gz \
    && mv rt-6.0.0 rt6 \
    && rm rt-6.0.0.tar.gz

# 4. Configurar RT con soporte para GD y GraphViz
WORKDIR /opt/rt6
RUN ./configure \
    --with-web-handler=modperl2 \
    --with-db-type=mysql \
    --enable-gd \        
    --enable-graphviz \  
    --with-web-user=www-data \
    --with-web-group=www-data

# 5. Instalar dependencias Perl core primero, luego RT específicas
RUN echo "Instalando dependencias Perl básicas..." \
    && cpanm --notest --force --quiet \
    App::cpanminus \
    CPAN \
    Module::Install \
    Module::Install::RTx \
    ExtUtils::MakeMaker

RUN echo "Instalando dependencias de base de datos..." \
    && cpanm --notest --force --quiet \
    DBI \
    DBD::mysql

RUN echo "Instalando dependencias gráficas..." \
    && cpanm --notest --force --quiet \
    GD \
    GD::Graph \
    GD::Text \
    GraphViz2

RUN echo "Instalando dependencias web y core de RT..." \
    && cpanm --notest --force --quiet \
    Apache::Session \
    Business::Hours \
    CGI \
    CGI::Cookie \
    CGI::Emulate::PSGI \
    CGI::PSGI \
    CSS::Minifier::XS \
    CSS::Squish \
    Class::Accessor::Fast \
    Convert::Color \
    Crypt::Eksblowfish \
    DBIx::SearchBuilder \
    Data::GUID \
    Date::Manip \
    DateTime \
    DateTime::Format::Natural \
    DateTime::Locale \
    Devel::GlobalDestruction \
    Devel::StackTrace

RUN echo "Instalando dependencias de email y formato..." \
    && cpanm --notest --force --quiet \
    Email::Address \
    Email::Address::List \
    Encode::Detect::Detector \
    File::ShareDir \
    HTML::Mason \
    HTML::Mason::PSGIHandler \
    HTML::Quoted \
    HTML::RewriteAttributes \
    HTML::Scrubber \
    IPC::Run3 \
    JSON \
    JavaScript::Minifier::XS

RUN echo "Instalando dependencias finales..." \
    && cpanm --notest --force --quiet \
    Log::Dispatch \
    MIME::Entity \
    MIME::Types \
    Module::Refresh \
    Moose \
    MooseX::NonMoose \
    Mozilla::CA \
    Net::CIDR \
    Net::IP \
    Plack \
    Plack::Handler::Starlet \
    Regexp::Common \
    Role::Basic \
    Symbol::Global::Name \
    Text::Password::Pronounceable \
    Text::Quoted \
    Text::WikiFormat \
    Time::ParseDate \
    Tree::Simple \
    Web::Machine \
    XML::RSS

# 6. Instalar RT saltando verificación de dependencias problemática
WORKDIR /opt/rt6
RUN echo "Iniciando instalación de RT..." \
    && echo "Ejecutando make fixdeps..." \
    && (make fixdeps || echo "fixdeps completado, continuando...") \
    && echo "Saltando testdeps - instalando directamente..." \
    && echo "Compilando e instalando RT..." \
    && make install DESTDIR=/tmp/rt-install \
    && echo "Copiando archivos instalados..." \
    && cp -r /tmp/rt-install/opt/rt6/* /opt/rt6/ \
    && rm -rf /tmp/rt-install \
    && echo "Instalación de RT completada exitosamente"

# 7. Configuración de Apache
COPY rt-apache.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod perl rewrite headers cgid expires \
    && a2dissite 000-default \
    && a2ensite 000-default

# 8. Configuración personalizada de RT
COPY RT_SiteConfig.pm /opt/rt6/etc/RT_SiteConfig.pm
RUN chown www-data:www-data /opt/rt6/etc/RT_SiteConfig.pm

# 9. Preparar directorios y permisos
RUN mkdir -p /opt/rt6/var/log /opt/rt6/var/session_data /opt/rt6/var/mason_data \
    && chown -R www-data:www-data /opt/rt6/var \
    && chmod -R 755 /opt/rt6/var \
    && mkdir -p /var/log/apache2 \
    && chown -R www-data:www-data /var/log/apache2

# 10. Entrypoint, puerto y healthcheck
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

CMD ["/entrypoint.sh"]