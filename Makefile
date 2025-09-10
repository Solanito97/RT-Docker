# ===========================================
# RT-Docker Makefile
# ===========================================

.PHONY: help build up down restart logs clean backup restore shell-rt shell-db

# Default target
help: ## Mostrar esta ayuda
	@echo "RT-Docker - Comandos disponibles:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

# Build and deployment
build: ## Construir la imagen de RT
	docker-compose build --no-cache

up: ## Iniciar todos los servicios
	docker-compose up -d

down: ## Detener todos los servicios
	docker-compose down

restart: ## Reiniciar todos los servicios
	docker-compose restart

restart-rt: ## Reiniciar solo el servicio RT
	docker-compose restart rt

# Monitoring
logs: ## Ver logs de todos los servicios
	docker-compose logs -f

logs-rt: ## Ver logs solo de RT
	docker-compose logs -f rt

logs-db: ## Ver logs solo de la base de datos
	docker-compose logs -f db

status: ## Ver estado de los contenedores
	docker-compose ps

# Database operations
backup: ## Crear backup de la base de datos
	@echo "Creando backup de la base de datos..."
	docker-compose exec db mysqldump -u root -p$$MYSQL_ROOT_PASSWORD rt6 > backup_rt6_$$(date +%Y%m%d_%H%M%S).sql
	@echo "Backup creado: backup_rt6_$$(date +%Y%m%d_%H%M%S).sql"

restore: ## Restaurar backup (usar: make restore FILE=backup.sql)
	@if [ -z "$(FILE)" ]; then echo "Error: Especifica el archivo con FILE=backup.sql"; exit 1; fi
	@echo "Restaurando backup: $(FILE)"
	docker-compose exec -T db mysql -u root -p$$MYSQL_ROOT_PASSWORD rt6 < $(FILE)

# Maintenance
clean: ## Limpiar contenedores, imágenes y volúmenes no utilizados
	docker-compose down
	docker system prune -f
	docker volume prune -f

clean-all: ## Limpiar TODO incluyendo volúmenes de datos (¡PELIGROSO!)
	@echo "⚠️  ADVERTENCIA: Esto eliminará TODOS los datos de RT y la base de datos"
	@read -p "¿Estás seguro? (y/N): " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		docker-compose down -v; \
		docker system prune -af; \
	else \
		echo "Operación cancelada"; \
	fi

# Development
shell-rt: ## Acceder al shell del contenedor RT
	docker-compose exec rt bash

shell-db: ## Acceder al shell de MySQL
	docker-compose exec db mysql -u root -p

# Setup
setup: ## Configuración inicial del proyecto
	@if [ ! -f .env ]; then \
		echo "Copiando .env.example a .env..."; \
		cp .env.example .env; \
		echo "⚠️  Edita el archivo .env con tus configuraciones antes de continuar"; \
	else \
		echo ".env ya existe"; \
	fi

install: setup build up ## Instalación completa del proyecto

# Testing
test: ## Verificar que RT esté funcionando
	@echo "Verificando RT..."
	@if curl -s -f http://localhost:3001/ > /dev/null; then \
		echo "✅ RT está funcionando correctamente"; \
	else \
		echo "❌ RT no está respondiendo"; \
		exit 1; \
	fi

health: ## Verificar salud de los contenedores
	@echo "Estado de salud de los contenedores:"
	@docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# Documentation
docs: ## Generar documentación del proyecto
	@echo "Generando documentación..."
	@echo "# RT-Docker Project Structure" > STRUCTURE.md
	@echo "" >> STRUCTURE.md
	@echo "## Archivos del proyecto:" >> STRUCTURE.md
	@find . -name "*.yml" -o -name "*.yaml" -o -name "*.sh" -o -name "*.conf" -o -name "*.pm" -o -name "Dockerfile*" | grep -v .git | sort >> STRUCTURE.md
	@echo "Documentación generada en STRUCTURE.md"
