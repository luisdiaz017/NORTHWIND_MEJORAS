
# Northwind + Mejoras SQL (PostgreSQL)

Este repositorio contiene la base de datos **Northwind** adaptada y mejorada para PostgreSQL, junto con ejemplos de consultas SQL, funciones, triggers, vistas y auditoría avanzada usando JSONB. Incluye documentación completa para pruebas y despliegue en otros entornos.

---

## 📁 Estructura del Proyecto

```
northwind-psql/
│
├── README.md                # Instrucciones y guía del proyecto
├── northwind_schema_LUIS-DIAZ.sql     # Script SQL para instalar la base de datos
├── docs/                    
│   ├── queries_doc.md       # Documentación detallada de consultas y funciones
│   └── queries_doc.pdf      # Versión PDF de la documentación
```

---

## ⚙️ Instalación Paso a Paso

### 1. Requisitos Previos

- PostgreSQL instalado (versión 12 o superior recomendada).
- Acceso a una terminal o PgAdmin para ejecutar scripts SQL.

### 2. Crear Base de Datos

```bash
createdb northwind
```

### 3. Importar el Script

Desde terminal:

```bash
psql -d northwind -f northwind_schema_LUIS-DIAZ.sql
```

Desde PgAdmin:

- Crear una base de datos llamada `northwind`.
- Ir a la pestaña de "Query Tool".
- Abrir y ejecutar el archivo `northwind_schema_LUIS-DIAZ.sql`.

### 4. Verificar Instalación

Ejecutar una consulta simple como:

```sql
SELECT * FROM customers LIMIT 10;
```

---

## 📄 Contenido Destacado

### 🔎 Consultas SQL

- Selecciones básicas, filtros y ordenaciones
- Joins y agregaciones
- Subconsultas
- Consultas JSON avanzadas

### 👀 Vistas

- Productos más vendidos
- Clientes con mayores compras

### ⚙️ Funciones y Triggers

- Cálculo total de pedidos
- Pedidos por cliente
- Actualización automática de stock
- Sistema de auditoría con JSONB

### 📦 JSONB y Metadatos

- Almacenamiento flexible de atributos de producto
- Índices GIN para búsquedas rápidas
- Consultas dinámicas con JSONB

### 📋 Auditoría de Pedidos

- Trigger completo para INSERT, UPDATE y DELETE
- Registro con usuario, hora y estado anterior/nuevo en JSON
- Consultas para recuperar historial de cambios

---

## 📚 Documentación

Consulta la carpeta `docs/` para ver la documentación extendida en:

- [`queries_doc.md`](./docs/queries_doc.md) — versión Markdown
- [`queries_doc.pdf`](./docs/queries_doc.pdf) — versión en PDF lista para imprimir

---

## ✍️ Autor

Proyecto desarrollado como ejercicio de práctica avanzada en SQL con PostgreSQL y JSON.

---

## 🪪 Licencia

Este proyecto es de uso libre para fines educativos y profesionales....
