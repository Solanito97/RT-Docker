# ===========================================
# Request Tracker 6.0 Site Configuration
# ===========================================

# Configuración de Base de Datos
Set($DatabaseType, 'mysql');
Set($DatabaseHost, $ENV{'RT_DATABASE_HOST'} || 'db');
Set($DatabaseName, $ENV{'RT_DATABASE_NAME'} || 'rt6');
Set($DatabaseUser, $ENV{'RT_DATABASE_USER'} || 'rt_user');
Set($DatabasePassword, $ENV{'RT_DATABASE_PASSWORD'} || 'rt_pass');

# Configuración Web
Set($WebDomain, $ENV{'RT_WEB_DOMAIN'} || 'localhost');
Set($WebPort, $ENV{'RT_WEB_PORT'} || 3002);
Set($WebPath, '');
Set($WebBaseURL, "http://" . ($ENV{'RT_WEB_DOMAIN'} || 'localhost') . ":" . ($ENV{'RT_WEB_PORT'} || 3002));

# Configuración de Correo
Set($MailCommand, $ENV{'RT_MAIL_COMMAND'} || 'sendmail');
Set($SendmailPath, $ENV{'RT_SENDMAIL_PATH'} || '/usr/sbin/sendmail');
Set($MailCommandOutgoing, $ENV{'RT_MAIL_COMMAND'} || 'sendmail');

# Configuración de Seguridad
Set($WebSecureCookies, $ENV{'RT_WEB_SECURE_COOKIES'} || 0);
Set($WebRemoteUserAuth, 0);
Set($WebSessionClass, 'Apache::Session::File');

# Configuración de Logs
Set($LogToFile, $ENV{'RT_LOG_LEVEL'} || 'info');
Set($LogDir, '/opt/rt6/var/log');
Set($LogToFileNamed, 'rt.log');

# Timezone y Localización
Set($Timezone, $ENV{'RT_TIMEZONE'} || 'UTC');
Set($DateTimeFormat, 'DefaultFormat');

# Organización
Set($Organization, $ENV{'RT_ORGANIZATION'} || 'example.com');
Set($CorrespondAddress, $ENV{'RT_CORRESPOND_ADDRESS'} || 'rt@example.com');
Set($CommentAddress, $ENV{'RT_COMMENT_ADDRESS'} || 'rt-comment@example.com');

# Configuración de Rendimiento
Set($MaxAttachmentSize, 25000000); # 25MB
Set($TrustHTMLAttachments, 0);
Set($PreferRichText, 1);

# Configuración de Sesiones
Set($WebSessionClass, 'Apache::Session::File');
Set($AutoLogoff, $ENV{'RT_WEB_SESSION_TIMEOUT'} || 7200); # 2 horas

# Configuración de Búsqueda
Set($DefaultSearchResultFormat, qq{
   '<B><A HREF="__WebPath__/Ticket/Display.html?id=__id__">__id__</A></B>/TITLE:#',
   '<B><A HREF="__WebPath__/Ticket/Display.html?id=__id__">__Subject__</A></B>/TITLE:Subject',
   Status,
   QueueName,
   Owner,
   Priority,
   '__NEWLINE__',
   '',
   '<small>__Requestors__</small>',
   '<small>__CreatedRelative__</small>',
   '<small>__ToldRelative__</small>',
   '<small>__LastUpdatedRelative__</small>',
   '<small>__TimeLeft__</small>'});

# Plugin Configuration
Set(@Plugins, qw(
    RT::Extension::CommandByMail
    RT::Extension::MergeUsers
));

# Configuración adicional de seguridad
Set($DisallowExecuteCode, 1);
Set($RestrictReferrer, 1);

1;