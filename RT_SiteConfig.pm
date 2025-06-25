# Confi# Configuración Web
Set($WebDomain, 'localhost');
Set($WebPort, 3002);
Set($WebPath, '');ción de Base de Datos
Set($DatabaseType, 'mysql');
Set($DatabaseHost, $ENV{'RT_DATABASE_HOST'} || 'db');
Set($DatabaseName, $ENV{'RT_DATABASE_NAME'} || 'rt6');
Set($DatabaseUser, $ENV{'RT_DATABASE_USER'} || 'rt_user');
Set($DatabasePassword, $ENV{'RT_DATABASE_PASSWORD'} || 'rt_pass');

# Configuración Web
Set($WebDomain, 'localhost');
Set($WebPort, 8080);
Set($WebPath, '');

# Configuración de Correo
Set($MailCommand, 'sendmail');
Set($SendmailPath, '/usr/sbin/sendmail');
Set($MailCommandOutgoing, 'sendmail');

# Configuración de Seguridad
Set($WebSecureCookies, 0);
Set($WebRemoteUserAuth, 0);

# Configuración de Logs
Set($LogToFile, 'info');
Set($LogDir, '/opt/rt6/var/log');
Set($LogToFileNamed, 'rt.log');

# Timezone
Set($Timezone, 'UTC');

# Organización
Set($Organization, 'example.com');
Set($CorrespondAddress, 'rt@example.com');
Set($CommentAddress, 'rt-comment@example.com');

1;