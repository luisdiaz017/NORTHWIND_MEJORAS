# Northwind SQL - Guía Completa

## 1. Configuración Inicial

### 1.1 Verificar la Base de Datos Northwind

Antes de comenzar, asegúrate de que la base de datos está instalada y accesible.

---

## 2. Consultas SQL Básicas

### 2.1 Consultas de Selección

**Listar todos los clientes:**

```sql
SELECT customer_id, company_name, contact_name, city FROM customers;
```

**Productos con stock bajo:**

```sql
SELECT product_id, product_name, units_in_stock FROM products WHERE units_in_stock < units_on_order;
```

### 2.2 Consultas con Filtros y Ordenación

**Pedidos realizados en 1997:**

```sql
SELECT order_id, customer_id, order_date FROM orders WHERE order_date BETWEEN '1997-01-01' AND '1997-12-31';
```

**Productos ordenados por precio descendente:**

```sql
SELECT product_name, unit_price FROM products ORDER BY unit_price DESC;
```

---

## 3. Consultas Avanzadas

### 3.1 Joins y Agregaciones

**Ventas totales por categoría:**

```sql
SELECT c.category_name, SUM(od.unit_price * od.quantity) AS total_sales
FROM order_details od
JOIN products p ON od.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_sales DESC;
```

**Empleados con más ventas:**

```sql
SELECT e.employee_id, e.first_name || ' ' || e.last_name AS employee_name, COUNT(o.order_id) AS total_orders
FROM orders o
JOIN employees e ON o.employee_id = e.employee_id
GROUP BY e.employee_id, employee_name
ORDER BY total_orders DESC;
```

### 3.2 Subconsultas

**Clientes que han realizado pedidos superiores a \$1000:**

```sql
SELECT customer_id, company_name
FROM customers
WHERE customer_id IN (
    SELECT o.customer_id
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.customer_id
    HAVING SUM(od.unit_price * od.quantity) > 1000
);
```

---

## 4. Vistas

### 4.1 Creación de Vistas

**Vista de productos más vendidos:**

```sql
SELECT p.product_id,
       p.product_name,
       c.category_name,
       SUM(od.quantity) AS unidades_vendidas,
       p.units_in_stock,
       p.reorder_level,
       CASE
           WHEN p.units_in_stock <= p.reorder_level THEN 'CRÍTICO'
           WHEN p.units_in_stock::numeric <= (p.reorder_level::numeric * 1.5) THEN 'BAJO'
           ELSE 'OK'
       END AS estado_inventario
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name, c.category_name, p.units_in_stock, p.reorder_level
ORDER BY SUM(od.quantity) DESC
LIMIT 50;
```

**Vista de clientes con mayores compras:**

```sql
SELECT customers.company_name AS cliente,
       SUM(order_details.quantity::double precision * order_details.unit_price) AS volumen_ventas
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
JOIN order_details ON orders.order_id = order_details.order_id
GROUP BY customers.company_name
ORDER BY volumen_ventas DESC
LIMIT 15;
```

---

## 5. Funciones Almacenadas

### 5.1 Función para Calcular Total de Pedido

```sql
CREATE OR REPLACE FUNCTION calculate_order_total(order_id integer)
RETURNS numeric AS $$
DECLARE
    total numeric;
BEGIN
    SELECT SUM(unit_price * quantity * (1 - discount))
    INTO total
    FROM order_details
    WHERE order_id = calculate_order_total.order_id;
    RETURN total;
END;
$$ LANGUAGE plpgsql;
```

### 5.2 Función para Obtener Pedidos por Cliente

```sql
CREATE OR REPLACE FUNCTION get_orders_by_customer(customer_id varchar)
RETURNS TABLE (order_id int, order_date date, total numeric) AS $$
BEGIN
    RETURN QUERY
    SELECT o.order_id, o.order_date, calculate_order_total(o.order_id) AS total
    FROM orders o
    WHERE o.customer_id = get_orders_by_customer.customer_id;
END;
$$ LANGUAGE plpgsql;
```

---

## 6. Triggers

### 6.1 Trigger para Actualizar Stock

```sql
CREATE OR REPLACE FUNCTION update_product_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE products
    SET units_in_stock = units_in_stock - NEW.quantity
    WHERE product_id = NEW.product_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_order_detail_insert
AFTER INSERT ON order_details
FOR EACH ROW
EXECUTE FUNCTION update_product_stock();
```

---

## 7. Pruebas y Validación

**Probar vistas:**

```sql
SELECT * FROM top_selling_products;
SELECT * FROM top_customers;
```

**Probar funciones:**

```sql
SELECT calculate_order_total(10248);
SELECT * FROM get_orders_by_customer('ALFKI');
```

**Probar trigger:**

```sql
INSERT INTO order_details (order_id, product_id, unit_price, quantity, discount)
VALUES (10248, 11, 14.00, 5, 0);

SELECT product_id, product_name, units_in_stock FROM products WHERE product_id = 11;
```

---

## 8. Campo JSON para Metadata

**Crear tabla con campo JSONB:**

```sql
CREATE TABLE product_metadata (
    metadata_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(product_id),
    attributes JSONB NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Insertar datos de ejemplo:**

```sql
INSERT INTO product_metadata (product_id, attributes)
VALUES
(1, '{
    "color_options": ["red", "blue", "green"],
    "weight": "0.5kg",
    "dimensions": {"length": 20, "width": 10, "height": 5},
    "compatibility": ["model-A", "model-B"],
    "warranty": {
        "period": 24,
        "type": "standard",
        "notes": "Includes parts and labor"
    }
}'),
(2, '{
    "material": "stainless steel",
    "energy_rating": "A++",
    "installation_requirements": ["220V", "dedicated circuit"],
    "accessories_included": true,
    "user_manual": "https://example.com/manuals/product2.pdf"
}');
```

**Crear índices para consultas JSON:**

```sql
CREATE INDEX idx_attributes_gin ON product_metadata USING GIN (attributes);
CREATE INDEX idx_warranty_period ON product_metadata ((attributes->'warranty'->>'period'));
```

**Consultas JSON de ejemplo:**

```sql
-- Productos con garantía > 12 meses
SELECT p.product_name, pm.attributes->'warranty'->>'period' AS warranty_months
FROM products p
JOIN product_metadata pm ON p.product_id = pm.product_id
WHERE (pm.attributes->'warranty'->>'period')::int > 12;

-- Buscar productos por material
SELECT p.product_id, p.product_name
FROM products p
JOIN product_metadata pm ON p.product_id = pm.product_id
WHERE pm.attributes @> '{"material": "stainless steel"}';

-- Actualizar atributos JSON
UPDATE product_metadata
SET attributes = jsonb_set(attributes, '{warranty,period}', '36')
WHERE product_id = 1;

-- Productos con manual de usuario disponible
SELECT p.product_name, pm.attributes->>'user_manual' AS manual_url
FROM products p
JOIN product_metadata pm ON p.product_id = pm.product_id
WHERE pm.attributes ? 'user_manual';

-- Agregar nuevo atributo
UPDATE product_metadata
SET attributes = attributes || '{"last_reviewed": "2023-07-15"}';
```

---

## 9. Sistema de Auditoría para Cambios en Pedidos

**Crear tabla de auditoría:**

```sql
CREATE TABLE order_audit (
    audit_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id),
    changed_by VARCHAR(50) NOT NULL DEFAULT CURRENT_USER,
    change_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    operation_type VARCHAR(10) NOT NULL CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE')),
    old_data JSONB,
    new_data JSONB
);
```

**Función para trigger:**

```sql
CREATE OR REPLACE FUNCTION log_order_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO order_audit (order_id, operation_type, old_data)
        VALUES (OLD.order_id, 'DELETE', row_to_json(OLD)::JSONB);
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO order_audit (order_id, operation_type, old_data, new_data)
        VALUES (
            NEW.order_id,
            'UPDATE',
            jsonb_strip_nulls(row_to_json(OLD)::JSONB),
            jsonb_strip_nulls(row_to_json(NEW)::JSONB)
        );
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO order_audit (order_id, operation_type, new_data)
        VALUES (NEW.order_id, 'INSERT', row_to_json(NEW)::JSONB);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
```

**Crear trigger:**

```sql
CREATE TRIGGER orders_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON orders
FOR EACH ROW EXECUTE FUNCTION log_order_changes();
```

**Consultas de uso:**

```sql
-- Ver cambios recientes
SELECT audit_id, order_id, changed_by, change_time AT TIME ZONE 'UTC' AS change_time, operation_type, old_data, new_data
FROM order_audit
ORDER BY change_time DESC;

-- Cambios específicos en ciudad de envío
SELECT change_time, changed_by, old_data->>'ship_city' AS old_city, new_data->>'ship_city' AS new_city
FROM order_audit
WHERE operation_type = 'UPDATE'
  AND (old_data->>'ship_city') IS DISTINCT FROM (new_data->>'ship_city');

-- Recuperar estado anterior
SELECT (old_data->>'order_id')::INT AS order_id, old_data->>'customer_id' AS customer_id, old_data->>'order_date' AS order_date, old_data->>'ship_city' AS ship_city
FROM order_audit
WHERE order_id = 10248 AND operation_type = 'UPDATE'
ORDER BY change_time DESC
LIMIT 1;
```

**Beneficios:**

* Auditoría completa: Inserciones, actualizaciones y eliminaciones
* Almacenamiento eficiente: JSONB
* Contexto: Quién hizo el cambio y cuándo
* Recuperación de datos antigua
* Mantenimiento bajo
* Flexibilidad y extensión
