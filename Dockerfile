# Usamos Ubuntu 24.04 LTS como imagen base
FROM ubuntu:24.04

# Evitar interacciones durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# 1. Actualizar repositorios con mirrors confiables
RUN sed -i 's/archive.ubuntu.com/mirrors.ubuntu.com/g' /etc/apt/sources.list

# 2. Instalar dependencias del sistema
RUN apt-get update && apt-get install -y postfix \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 3. Descargar Request Tracker 5.0.4
WORKDIR /opt
RUN wget https://download.bestpractical.com/pub/rt/release/rt-6.0.0.tar.gz \
    && tar -xvzf rt-6.0.0.tar.gz \
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

# 5. Instalar dependencias Perl requeridas por RT
RUN cpanm --notest \
    GD \                 
    GD::Graph \          
    GD::Text \           
    GraphViz2 \          
    Apache::Session Business::Hours CGI CGI::Cookie CGI::Emulate::PSGI CGI::PSGI \
    CSS::Minifier::XS CSS::Squish Class::Accessor::Fast Convert::Color Crypt::Eksblowfish \
    DBIx::SearchBuilder Data::GUID Data::ICal Data::Page Date::Extract Date::Manip DateTime \
    DateTime::Format::Natural DateTime::Locale Devel::GlobalDestruction Devel::StackTrace \
    Email::Address Email::Address::List Encode::Detect::Detector Encode::HanExtra \
    File::ShareDir HTML::FormatExternal HTML::FormatText::WithLinks HTML::FormatText::WithLinks::AndTables \
    HTML::Gumbo HTML::Mason HTML::Mason::PSGIHandler HTML::Quoted HTML::RewriteAttributes \
    HTML::Scrubber IPC::Run3 JSON JavaScript::Minifier::XS Locale::Maketext::Fuzzy Locale::Maketext::Lexicon \
    Log::Dispatch MIME::Entity MIME::Types Module::Path Module::Refresh Module::Versions::Report \
    Moose MooseX::NonMoose MooseX::Role::Parameterized Mozilla::CA Net::CIDR Net::IP \
    Parallel::ForkManager Path::Dispatcher Plack Plack::Handler::Starlet Regexp::Common \
    Regexp::Common::net::CIDR Regexp::IPv6 Role::Basic Scope::Upper Symbol::Global::Name \
    Text::Password::Pronounceable Text::Quoted Text::WikiFormat Text::WordDiff Text::Wrapper \
    Time::ParseDate Tree::Simple Web::Machine XML::RSS File::Which GnuPG::Interface PerlIO::eol \
    Crypt::X509

# 6. Instalar RT sin inicializar la base de datos
WORKDIR /opt/rt6
RUN make testdeps && \
    make install DESTDIR=/tmp/rt-install && \
    cp -r /tmp/rt-install/opt/rt6/* /opt/rt6/ && \
    rm -rf /tmp/rt-install

# 7. Configuración de Apache
COPY rt-apache.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod perl rewrite headers cgid

# 8. Configuración personalizada de RT
COPY RT_SiteConfig.pm /opt/rt6/etc/RT_SiteConfig.pm
RUN chown www-data:www-data /opt/rt6/etc/RT_SiteConfig.pm

# 9. Preparar directorios y permisos
RUN mkdir -p /opt/rt6/var && chown -R www-data:www-data /opt/rt6/var

# 10. Entrypoint y puerto
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 80

CMD ["/entrypoint.sh"]