# Directorio para plugins personalizados de Request Tracker

Este directorio está destinado para plugins adicionales que quieras instalar en tu instancia de RT.

## Instalación de plugins

1. Descarga o clona el plugin en este directorio
2. Modifica `config/RT_SiteConfig.pm` para incluir el plugin en la lista:

```perl
Set(@Plugins, qw(
    RT::Authen::ExternalAuth
    RT::Extension::TuPlugin
));
```

3. Reinicia el contenedor:

```bash
docker-compose restart rt
```

## Plugins populares

- **RT::Extension::MandatoryOnTransition**: Campos obligatorios en transiciones
- **RT::Extension::CommandByMail**: Comandos por email
- **RT::Extension::ActivityReports**: Reportes de actividad
- **RT::Extension::Assets**: Gestión de activos
- **RT::Extension::SLA**: Service Level Agreements

## Desarrollo de plugins

Consulta la [documentación de RT](https://docs.bestpractical.com/rt/latest/extending.html) para información sobre desarrollo de plugins.
