Set($DatabaseType, 'mysql');
Set($DatabaseHost, $ENV{'RT_DATABASE_HOST'} || 'db');
Set($DatabaseName, $ENV{'RT_DATABASE_NAME'} || 'rt4');
Set($DatabaseUser, $ENV{'RT_DATABASE_USER'} || 'rt_user');
Set($DatabasePassword, $ENV{'RT_DATABASE_PASSWORD'} || 'rt_pass');