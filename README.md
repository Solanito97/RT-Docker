# Request Tracker 6.0 - Instalación Docker

Este proyecto proporciona una instalación automatizada de Request Tracker 6.0 usando Docker y MySQL.

## Características

- Request Tracker 6.0.6
- MySQL 8.0
- Apache con FastCGI
- Configuración automatizada
- Puertos configurados: 4000-4008

## Estructura del Proyecto

```
RT-Docker/
├── docker-compose.yml      # Configuración principal de servicios
├── Dockerfile             # Imagen personalizada de RT
├── config/
│   └── RT_SiteConfig.pm   # Configuración de RT
├── apache/
│   └── rt.conf           # Configuración de Apache
├── scripts/
│   └── init-rt.sh        # Script de inicialización
├── mysql/
│   └── init/
│       └── 01-rt-init.sql # Inicialización de MySQL
└── README.md
```

## Instalación y Uso

### Prerrequisitos

- Docker
- Docker Compose
- Puertos 4000-4008 disponibles

### Instalación

1. Clona o descarga este repositorio
2. Navega al directorio del proyecto
3. Ejecuta el siguiente comando:

```bash
docker-compose up -d --build
```

### Acceso

- **Request Tracker**: http://localhost:4000
- **MySQL**: localhost:4001

### Credenciales por Defecto

**Request Tracker:**

- Usuario: `root`
- Contraseña: `password` (se establecerá durante la primera configuración)

**MySQL:**

- Usuario root: `rt_root_password`
- Usuario RT: `rt_user` / `rt_password`
- Base de datos: `rt6`

## Configuración

### Variables de Entorno

Puedes personalizar la instalación modificando las variables de entorno en `docker-compose.yml`:

```yaml
environment:
  - RT_DATABASE_HOST=mysql
  - RT_DATABASE_NAME=rt6
  - RT_DATABASE_USER=rt_user
  - RT_DATABASE_PASSWORD=rt_password
  - RT_WEB_DOMAIN=localhost
  - RT_WEB_PORT=4000
```

### Configuración Avanzada

Modifica los archivos en la carpeta `config/` para personalizar RT según tus necesidades.

## Comandos Útiles

### Ver logs

```bash
# Logs de RT
docker-compose logs rt

# Logs de MySQL
docker-compose logs mysql

# Logs en tiempo real
docker-compose logs -f
```

### Reiniciar servicios

```bash
# Reiniciar todo
docker-compose restart

# Reiniciar solo RT
docker-compose restart rt
```

### Acceder al contenedor

```bash
# Acceder al contenedor de RT
docker-compose exec rt bash

# Acceder a MySQL
docker-compose exec mysql mysql -u rt_user -p rt6
```

### Backup de la base de datos

```bash
docker-compose exec mysql mysqldump -u rt_user -p rt6 > backup_rt.sql
```

### Restaurar backup

```bash
docker-compose exec -T mysql mysql -u rt_user -p rt6 < backup_rt.sql
```

## Personalización

### Añadir plugins

1. Coloca los plugins en la carpeta `plugins/`
2. Modifica `config/RT_SiteConfig.pm` para incluir el plugin
3. Reinicia el contenedor

### Configurar email

Modifica las configuraciones de email en `config/RT_SiteConfig.pm`:

```perl
Set($MailCommand, 'smtp');
Set($SMTPServer, 'tu-servidor-smtp.com');
Set($SMTPUser, 'tu-usuario');
Set($SMTPPassword, 'tu-contraseña');
```

## Troubleshooting

### RT no inicia

1. Verifica que MySQL esté ejecutándose: `docker-compose logs mysql`
2. Revisa los logs de RT: `docker-compose logs rt`

### No se puede conectar a la base de datos

1. Verifica las credenciales en `docker-compose.yml`
2. Asegúrate de que MySQL haya inicializado completamente

### Problemas de permisos

```bash
docker-compose exec rt chown -R rt:rt /opt/rt6/var
docker-compose exec rt chgrp -R www-data /opt/rt6/var
```

## Puertos Utilizados

- 4000: Request Tracker (web interface)
- 4001: MySQL
- 4002-4008: Disponibles para expansión futura

## Contribuir

1. Fork el proyecto
2. Crea tu feature branch
3. Commit tus cambios
4. Push al branch
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la licencia MIT. Ver LICENSE para más detalles.

## Soporte

Para problemas específicos de Request Tracker, consulta la [documentación oficial](https://docs.bestpractical.com/rt/).

Para problemas con esta configuración Docker, abre un issue en este repositorio.
