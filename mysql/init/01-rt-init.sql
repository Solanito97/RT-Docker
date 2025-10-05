-- Script de inicialización para MySQL
-- Configuración para Request Tracker 6.0

-- Asegurar que MySQL use configuración compatible con RT
SET sql_mode = 'TRADITIONAL';

-- Configurar charset para RT
ALTER DATABASE rt6 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Otorgar permisos completos al usuario RT
GRANT ALL PRIVILEGES ON rt6.* TO 'rt_user'@'%';
FLUSH PRIVILEGES;