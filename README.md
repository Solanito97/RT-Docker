# 🎫 Request Tracker (RT) 6.0 - Docker Implementation

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://www.docker.com/)
[![RT Version](https://img.shields.io/badge/RT-6.0.0-green)](https://bestpractical.com/request-tracker)
[![MariaDB](https://img.shields.io/badge/MariaDB-11.3-orange)](https://mariadb.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04%20LTS-purple)](https://ubuntu.com/)

> **Una solución completa en Docker para Request Tracker (RT) 6.0.0** - El sistema de seguimiento de tickets empresarial más robusto, ahora containerizado y listo para producción.

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Características](#-características)
- [Arquitectura](#-arquitectura)
- [Requisitos Previos](#-requisitos-previos)
- [Instalación Rápida](#-instalación-rápida)
- [Configuración](#-configuración)
- [Uso](#-uso)
- [Monitoreo](#-monitoreo)
- [Troubleshooting](#-troubleshooting)
- [Contribución](#-contribución)

## 🚀 Descripción

Este repositorio proporciona una implementación completa de **Request Tracker (RT) 6.0.0** utilizando Docker y Docker Compose. Dado que no existe una imagen oficial de RT, hemos creado una solución robusta basada en Ubuntu 24.04 LTS con todas las optimizaciones necesarias para entornos de producción.

### ¿Qué es Request Tracker?

RT es un sistema empresarial de seguimiento de tickets que permite gestionar solicitudes de soporte, bugs, tareas y cualquier tipo de workflow empresarial de manera eficiente.

## ✨ Características

- 🐳 **Completamente Dockerizado** - Implementación lista para producción
- 🔒 **Seguro por Defecto** - Configuraciones de seguridad implementadas
- 📊 **Monitoreo Integrado** - Health checks y logging estructurado
- ⚡ **Alto Rendimiento** - Apache optimizado con mod_perl2
- 🛡️ **Persistencia de Datos** - Volúmenes Docker para datos y configuraciones
- 🔧 **Fácil Configuración** - Variables de entorno para personalización
- 📱 **Responsive** - Interfaz web moderna y adaptable

## 🏗️ Arquitectura

```
┌─────────────────┐    ┌─────────────────┐
│   RT Container  │    │  MariaDB        │
│                 │    │  Container      │
│ • Apache 2.4    │◄──►│                 │
│ • mod_perl2     │    │ • MariaDB 11.3  │
│ • RT 6.0.0      │    │ • UTF8MB4       │
│ • Ubuntu 24.04  │    │ • Persistent    │
└─────────────────┘    └─────────────────┘
        ▲
        │ Puerto 3001
        ▼
┌─────────────────┐
│   Host System   │
│   localhost     │
└─────────────────┘
```

## 📦 Contenido del Repositorio

| Archivo              | Descripción                                           |
| -------------------- | ----------------------------------------------------- |
| `Dockerfile`         | Imagen personalizada de RT con todas las dependencias |
| `docker-compose.yml` | Orquestación de servicios RT + MariaDB                |
| `entrypoint.sh`      | Script de inicialización inteligente con logging      |
| `rt-apache.conf`     | Configuración optimizada de Apache para RT            |
| `RT_SiteConfig.pm`   | Configuración principal de RT con mejores prácticas   |
| `.dockerignore`      | Optimización del contexto de construcción             |

## 🔧 Requisitos Previos

### Mínimos del Sistema

- **RAM**: 2GB mínimo, 4GB recomendado
- **Disco**: 5GB espacio libre
- **CPU**: 2 cores recomendado

### Software Requerido

- [Docker](https://docs.docker.com/get-docker/) >= 20.10
- [Docker Compose](https://docs.docker.com/compose/install/) >= 2.0
- Sistema operativo: Linux, macOS, o Windows con WSL2

### Verificación de Requisitos

```bash
# Verificar versiones
docker --version
docker-compose --version

# Verificar recursos disponibles
docker system df
docker system info
```

## ⚡ Instalación Rápida

### 1. Clonar el Repositorio

```bash
git clone https://github.com/tu-usuario/RT-Docker.git
cd RT-Docker
```

### 2. Configurar Firewall (Ubuntu/Debian)

```bash
# Permitir puerto 3001 para RT
sudo ufw allow 3001/tcp comment "Request Tracker RT6"
sudo ufw reload
```

### 3. Construir y Ejecutar

```bash
# Construcción y ejecución en una sola línea
docker-compose up --build -d

# Verificar estado de los contenedores
docker-compose ps
```

### 4. Acceder a RT

🌐 **URL**: http://localhost:3001

**Credenciales por defecto:**

- **Usuario**: `root`
- **Contraseña**: `password`

> ⚠️ **Importante**: Cambia la contraseña por defecto inmediatamente después del primer acceso.

## ⚙️ Configuración

### Variables de Entorno

Puedes personalizar la instalación modificando las variables en `docker-compose.yml`:

```yaml
environment:
  RT_DATABASE_HOST: db # Host de la base de datos
  RT_DATABASE_NAME: rt6 # Nombre de la base de datos
  RT_DATABASE_USER: rt_user # Usuario de la base de datos
  RT_DATABASE_PASSWORD: rt_pass # Contraseña de la base de datos
  RT_ROOT_PASSWORD: root_password # Contraseña root de MariaDB
```

### Configuración Avanzada

Para configuraciones más avanzadas, edita `RT_SiteConfig.pm`:

```perl
# Configuración de correo
Set($MailCommand, 'sendmail');
Set($SendmailPath, '/usr/sbin/sendmail');

# Configuración de organización
Set($Organization, 'tu-empresa.com');
Set($CorrespondAddress, 'soporte@tu-empresa.com');

# Configuración de timezone
Set($Timezone, 'America/Mexico_City');
```

## 🎯 Uso

### Comandos Básicos

```bash
# Iniciar servicios
docker-compose up -d

# Detener servicios
docker-compose down

# Ver logs en tiempo real
docker-compose logs -f rt

# Reiniciar solo RT (sin BD)
docker-compose restart rt

# Reconstruir imagen
docker-compose build --no-cache rt
```

### Backup y Restauración

```bash
# Backup de la base de datos
docker-compose exec db mysqldump -u root -p rt6 > backup_rt6_$(date +%Y%m%d).sql

# Restaurar base de datos
docker-compose exec -T db mysql -u root -p rt6 < backup_rt6_20241224.sql
```

### Actualización

```bash
# Backup antes de actualizar
docker-compose exec db mysqldump -u root -p rt6 > backup_before_update.sql

# Actualizar contenedores
docker-compose pull
docker-compose up --build -d
```

## 📊 Monitoreo

### Health Checks

Los contenedores incluyen health checks automáticos:

```bash
# Verificar salud de los contenedores
docker-compose ps
docker inspect rt-container --format='{{.State.Health.Status}}'
```

### Logs Estructurados

```bash
# Logs de RT con timestamps
docker-compose logs rt

# Logs de MariaDB
docker-compose logs db

# Seguir logs en tiempo real
docker-compose logs -f --tail=50
```

### Métricas de Rendimiento

```bash
# Uso de recursos
docker stats request-tracker rt-db

# Espacio utilizado
docker system df
```

## 🔍 Troubleshooting

### Problemas Comunes

#### 🚫 RT no responde en http://localhost:3001

```bash
# Verificar estado de contenedores
docker-compose ps

# Verificar logs de RT
docker-compose logs rt

# Verificar conectividad de red
curl -I http://localhost:3001
```

#### 💾 Error de conexión a base de datos

```bash
# Verificar estado de MariaDB
docker-compose logs db

# Verificar conectividad desde RT
docker-compose exec rt mysqladmin ping -h db
```

#### 🐌 RT responde lentamente

```bash
# Verificar recursos del sistema
docker stats

# Verificar logs de Apache
docker-compose exec rt tail -f /var/log/apache2/rt-error.log
```

### Comandos de Diagnóstico

```bash
# Información completa del sistema
docker system info

# Verificar configuración de RT
docker-compose exec rt cat /opt/rt6/etc/RT_SiteConfig.pm

# Acceso directo al contenedor de RT
docker-compose exec rt bash

# Acceso directo a MariaDB
docker-compose exec db mysql -u root -p
```

## 🛡️ Seguridad

### Recomendaciones de Producción

1. **Cambiar contraseñas por defecto**
2. **Usar HTTPS con certificados SSL**
3. **Configurar backup automático**
4. **Actualizar regularmente las imágenes**
5. **Monitorear logs de seguridad**

### Configuración SSL (Opcional)

Para habilitar HTTPS, modifica `rt-apache.conf` y agrega certificados:

```apache
<VirtualHost *:443>
    SSLEngine on
    SSLCertificateFile /path/to/cert.pem
    SSLCertificateKeyFile /path/to/private.key
    # ... resto de configuración
</VirtualHost>
```

## 🤝 Contribución

¡Las contribuciones son bienvenidas! Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

### Reportar Issues

Al reportar problemas, incluye:

- Versión de Docker y Docker Compose
- Sistema operativo
- Logs relevantes
- Pasos para reproducir el problema

## 📄 Licencia

Este proyecto está licenciado bajo la MIT License - ver el archivo [LICENSE](LICENSE) para detalles.

## 🙏 Agradecimientos

- [Best Practical Solutions](https://bestpractical.com/) por Request Tracker
- Comunidad de Docker por las mejores prácticas
- Contribuidores del proyecto

---

**⭐ Si este proyecto te fue útil, ¡dale una estrella!**
