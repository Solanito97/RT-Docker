# Configuración principal de Request Tracker 6.0

# Configuración de la base de datos
Set($DatabaseHost, $ENV{'RT_DATABASE_HOST'} || 'mysql');
Set($DatabaseName, $ENV{'RT_DATABASE_NAME'} || 'rt6');
Set($DatabaseUser, $ENV{'RT_DATABASE_USER'} || 'rt_user');
Set($DatabasePassword, $ENV{'RT_DATABASE_PASSWORD'} || 'rt_password');
Set($DatabaseType, 'mysql');

# Configuración web
Set($WebDomain, $ENV{'RT_WEB_DOMAIN'} || 'localhost');
Set($WebPort, $ENV{'RT_WEB_PORT'} || 80);
Set($WebPath, '/');
Set($WebBaseURL, "http://$WebDomain:$WebPort");

# Configuración de correo
Set($MailCommand, 'sendmailpipe');
Set($SendmailPath, '/usr/sbin/sendmail');
Set($SendmailArguments, '-t');

# Configuración de organización
Set($Organization, 'RT-Docker');
Set($CorrespondAddress, 'rt@localhost');
Set($CommentAddress, 'rt-comment@localhost');

# Configuración de seguridad
Set($WebSecureCookies, 0);
Set($WebRemoteUserAuth, 0);

# Configuración de logging
Set($LogToSyslog, 'info');
Set($LogToScreen, 'error');
Set($LogToFile, 'info');
Set($LogDir, '/opt/rt6/var/log');
Set($LogToFileNamed, 'rt.log');

# Configuración de zona horaria
Set($Timezone, 'America/Mexico_City');

# Configuración de plugins
Set(@Plugins, qw(
    RT::Authen::ExternalAuth
));

# Configuración de colas por defecto
Set($DefaultQueue, 'General');

# Configuración de tema
Set($WebDefaultStylesheet, 'aileron');

# Configuración de attachments
Set($MaxAttachmentSize, 10_000_000); # 10MB

# Configuración de fulltext search
Set($FullTextSearch, (
    Enable     => 1,
    Indexed    => 1,
    Column     => 'ContentIndex',
    Table      => 'AttachmentsIndex',
));

# Configuración adicional para desarrollo
Set($DevelMode, 0);
Set($WebFlushDbCacheEveryRequest, 0);

1;