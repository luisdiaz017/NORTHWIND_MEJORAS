PGDMP      +                }        	   northwind    17.4    17.4 a    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            �           1262    16394 	   northwind    DATABASE     o   CREATE DATABASE northwind WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'es-ES';
    DROP DATABASE northwind;
                     postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
                     pg_database_owner    false            �           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                        pg_database_owner    false    4            �            1255    24599    calculate_order_total(integer)    FUNCTION     P  CREATE FUNCTION public.calculate_order_total(order_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$  
DECLARE  
    total numeric;  
BEGIN  
    SELECT SUM(unit_price * quantity * (1 - discount))  
    INTO total  
    FROM order_details  
    WHERE order_id = calculate_order_total.order_id;  
    RETURN total;  
END;  
$$;
 >   DROP FUNCTION public.calculate_order_total(order_id integer);
       public               postgres    false    4            �            1255    24600 )   get_orders_by_customer(character varying)    FUNCTION     z  CREATE FUNCTION public.get_orders_by_customer(customer_id character varying) RETURNS TABLE(order_id integer, order_date date, total numeric)
    LANGUAGE plpgsql
    AS $$  
BEGIN  
    RETURN QUERY  
    SELECT o.order_id, o.order_date, calculate_order_total(o.order_id) AS total  
    FROM orders o  
    WHERE o.customer_id = get_orders_by_customer.customer_id;  
END;  
$$;
 L   DROP FUNCTION public.get_orders_by_customer(customer_id character varying);
       public               postgres    false    4            �            1255    24635    log_order_changes()    FUNCTION     ?  CREATE FUNCTION public.log_order_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;
 *   DROP FUNCTION public.log_order_changes();
       public               postgres    false    4            �            1259    16395 
   categories    TABLE     �   CREATE TABLE public.categories (
    category_id smallint NOT NULL,
    category_name character varying(15) NOT NULL,
    description text,
    picture bytea
);
    DROP TABLE public.categories;
       public         heap r       postgres    false    4            �            1259    16400    customer_customer_demo    TABLE     �   CREATE TABLE public.customer_customer_demo (
    customer_id character varying(5) NOT NULL,
    customer_type_id character varying(5) NOT NULL
);
 *   DROP TABLE public.customer_customer_demo;
       public         heap r       postgres    false    4            �            1259    16403    customer_demographics    TABLE     z   CREATE TABLE public.customer_demographics (
    customer_type_id character varying(5) NOT NULL,
    customer_desc text
);
 )   DROP TABLE public.customer_demographics;
       public         heap r       postgres    false    4            �            1259    16408 	   customers    TABLE     �  CREATE TABLE public.customers (
    customer_id character varying(5) NOT NULL,
    company_name character varying(40) NOT NULL,
    contact_name character varying(30),
    contact_title character varying(30),
    address character varying(60),
    city character varying(15),
    region character varying(15),
    postal_code character varying(10),
    country character varying(15),
    phone character varying(24),
    fax character varying(24)
);
    DROP TABLE public.customers;
       public         heap r       postgres    false    4            �            1259    16416    employee_territories    TABLE     �   CREATE TABLE public.employee_territories (
    employee_id smallint NOT NULL,
    territory_id character varying(20) NOT NULL
);
 (   DROP TABLE public.employee_territories;
       public         heap r       postgres    false    4            �            1259    16411 	   employees    TABLE     s  CREATE TABLE public.employees (
    employee_id smallint NOT NULL,
    last_name character varying(20) NOT NULL,
    first_name character varying(10) NOT NULL,
    title character varying(30),
    title_of_courtesy character varying(25),
    birth_date date,
    hire_date date,
    address character varying(60),
    city character varying(15),
    region character varying(15),
    postal_code character varying(10),
    country character varying(15),
    home_phone character varying(24),
    extension character varying(4),
    photo bytea,
    notes text,
    reports_to smallint,
    photo_path character varying(255)
);
    DROP TABLE public.employees;
       public         heap r       postgres    false    4            �            1259    24619    order_audit    TABLE       CREATE TABLE public.order_audit (
    audit_id integer NOT NULL,
    order_id integer NOT NULL,
    changed_by character varying(50) DEFAULT CURRENT_USER NOT NULL,
    change_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    operation_type character varying(10) NOT NULL,
    old_data jsonb,
    new_data jsonb,
    CONSTRAINT order_audit_operation_type_check CHECK (((operation_type)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);
    DROP TABLE public.order_audit;
       public         heap r       postgres    false    4            �            1259    24618    order_audit_audit_id_seq    SEQUENCE     �   CREATE SEQUENCE public.order_audit_audit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.order_audit_audit_id_seq;
       public               postgres    false    4    248            �           0    0    order_audit_audit_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.order_audit_audit_id_seq OWNED BY public.order_audit.audit_id;
          public               postgres    false    247            �            1259    16419    order_details    TABLE     �   CREATE TABLE public.order_details (
    order_id smallint NOT NULL,
    product_id smallint NOT NULL,
    unit_price real NOT NULL,
    quantity smallint NOT NULL,
    discount real NOT NULL
);
 !   DROP TABLE public.order_details;
       public         heap r       postgres    false    4            �            1259    16422    orders    TABLE     �  CREATE TABLE public.orders (
    order_id smallint NOT NULL,
    customer_id character varying(5),
    employee_id smallint,
    order_date date,
    required_date date,
    shipped_date date,
    ship_via smallint,
    freight real,
    ship_name character varying(40),
    ship_address character varying(60),
    ship_city character varying(15),
    ship_region character varying(15),
    ship_postal_code character varying(10),
    ship_country character varying(15)
);
    DROP TABLE public.orders;
       public         heap r       postgres    false    4            �            1259    24602    product_metadata    TABLE     �   CREATE TABLE public.product_metadata (
    metadata_id integer NOT NULL,
    product_id integer NOT NULL,
    attributes jsonb NOT NULL,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
 $   DROP TABLE public.product_metadata;
       public         heap r       postgres    false    4            �            1259    24601     product_metadata_metadata_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_metadata_metadata_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public.product_metadata_metadata_id_seq;
       public               postgres    false    4    246            �           0    0     product_metadata_metadata_id_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE public.product_metadata_metadata_id_seq OWNED BY public.product_metadata.metadata_id;
          public               postgres    false    245            �            1259    16425    products    TABLE     c  CREATE TABLE public.products (
    product_id smallint NOT NULL,
    product_name character varying(40) NOT NULL,
    supplier_id smallint,
    category_id smallint,
    quantity_per_unit character varying(20),
    unit_price real,
    units_in_stock smallint,
    units_on_order smallint,
    reorder_level smallint,
    discontinued integer NOT NULL
);
    DROP TABLE public.products;
       public         heap r       postgres    false    4            �            1259    16428    region    TABLE     w   CREATE TABLE public.region (
    region_id smallint NOT NULL,
    region_description character varying(60) NOT NULL
);
    DROP TABLE public.region;
       public         heap r       postgres    false    4            �            1259    16431    shippers    TABLE     �   CREATE TABLE public.shippers (
    shipper_id smallint NOT NULL,
    company_name character varying(40) NOT NULL,
    phone character varying(24)
);
    DROP TABLE public.shippers;
       public         heap r       postgres    false    4            �            1259    16434 	   suppliers    TABLE     �  CREATE TABLE public.suppliers (
    supplier_id smallint NOT NULL,
    company_name character varying(40) NOT NULL,
    contact_name character varying(30),
    contact_title character varying(30),
    address character varying(60),
    city character varying(15),
    region character varying(15),
    postal_code character varying(10),
    country character varying(15),
    phone character varying(24),
    fax character varying(24),
    homepage text
);
    DROP TABLE public.suppliers;
       public         heap r       postgres    false    4            �            1259    16439    territories    TABLE     �   CREATE TABLE public.territories (
    territory_id character varying(20) NOT NULL,
    territory_description character varying(60) NOT NULL,
    region_id smallint NOT NULL
);
    DROP TABLE public.territories;
       public         heap r       postgres    false    4            �            1259    16442 	   us_states    TABLE     �   CREATE TABLE public.us_states (
    state_id smallint NOT NULL,
    state_name character varying(100),
    state_abbr character varying(2),
    state_region character varying(50)
);
    DROP TABLE public.us_states;
       public         heap r       postgres    false    4            �            1259    16606    vw_analisis_clientes    VIEW     w  CREATE VIEW public.vw_analisis_clientes AS
 SELECT c.customer_id,
    c.company_name,
    c.country,
    count(o.order_id) AS total_pedidos,
    round((sum((((od.quantity)::double precision * od.unit_price) * ((1)::double precision - od.discount))))::numeric, 2) AS valor_total,
    max(o.order_date) AS ultima_compra,
        CASE
            WHEN (count(o.order_id) > 20) THEN 'PREMIUM'::text
            WHEN (count(o.order_id) > 10) THEN 'MEDIO'::text
            ELSE 'BASICO'::text
        END AS segmento
   FROM ((public.customers c
     LEFT JOIN public.orders o ON (((c.customer_id)::text = (o.customer_id)::text)))
     LEFT JOIN public.order_details od ON ((o.order_id = od.order_id)))
  GROUP BY c.customer_id, c.company_name, c.country
  ORDER BY (round((sum((((od.quantity)::double precision * od.unit_price) * ((1)::double precision - od.discount))))::numeric, 2)) DESC;
 '   DROP VIEW public.vw_analisis_clientes;
       public       v       postgres    false    224    220    220    220    224    223    223    223    224    223    4            �            1259    16587    vw_ordenes_ciudad    VIEW     a  CREATE VIEW public.vw_ordenes_ciudad AS
 SELECT customers.city AS ciudad,
    customers.country AS pais,
    count(orders.order_id) AS total_ordenes
   FROM (public.customers
     JOIN public.orders ON (((customers.customer_id)::text = (orders.customer_id)::text)))
  GROUP BY customers.city, customers.country
  ORDER BY (count(orders.order_id)) DESC;
 $   DROP VIEW public.vw_ordenes_ciudad;
       public       v       postgres    false    220    220    220    224    224    4            �            1259    16557    vw_precios_categoria    VIEW     Q  CREATE VIEW public.vw_precios_categoria AS
 SELECT categories.category_name AS categoria,
    count(products.product_id) AS cantidad_productos,
    round((min(products.unit_price))::numeric, 2) AS precio_minimo,
    round((max(products.unit_price))::numeric, 2) AS precio_maximo,
    round((avg(products.unit_price))::numeric, 2) AS precio_promedio
   FROM (public.products
     JOIN public.categories ON ((products.category_id = categories.category_id)))
  WHERE (products.discontinued = 0)
  GROUP BY categories.category_name
  ORDER BY (round((avg(products.unit_price))::numeric, 2)) DESC;
 '   DROP VIEW public.vw_precios_categoria;
       public       v       postgres    false    225    225    225    225    217    217    4            �            1259    16601    vw_productos_mas_vendidos    VIEW     �  CREATE VIEW public.vw_productos_mas_vendidos AS
 SELECT p.product_id,
    p.product_name,
    c.category_name,
    sum(od.quantity) AS unidades_vendidas,
    p.units_in_stock,
    p.reorder_level,
        CASE
            WHEN (p.units_in_stock <= p.reorder_level) THEN 'CRÍTICO'::text
            WHEN ((p.units_in_stock)::numeric <= ((p.reorder_level)::numeric * 1.5)) THEN 'BAJO'::text
            ELSE 'OK'::text
        END AS estado_inventario
   FROM ((public.products p
     JOIN public.categories c ON ((p.category_id = c.category_id)))
     JOIN public.order_details od ON ((p.product_id = od.product_id)))
  GROUP BY p.product_id, p.product_name, c.category_name, p.units_in_stock, p.reorder_level
  ORDER BY (sum(od.quantity)) DESC
 LIMIT 50;
 ,   DROP VIEW public.vw_productos_mas_vendidos;
       public       v       postgres    false    225    217    217    223    223    225    225    225    225    4            �            1259    16592    vw_stock_bajo    VIEW     �   CREATE VIEW public.vw_stock_bajo AS
 SELECT product_id,
    product_name,
    units_in_stock,
    reorder_level
   FROM public.products
  WHERE ((units_in_stock <= reorder_level) AND (discontinued = 0))
  ORDER BY units_in_stock;
     DROP VIEW public.vw_stock_bajo;
       public       v       postgres    false    225    225    225    225    225    4            �            1259    16572    vw_top_clientes    VIEW       CREATE VIEW public.vw_top_clientes AS
 SELECT customers.company_name AS cliente,
    sum(((order_details.quantity)::double precision * order_details.unit_price)) AS volumen_ventas
   FROM ((public.customers
     JOIN public.orders ON (((customers.customer_id)::text = (orders.customer_id)::text)))
     JOIN public.order_details ON ((orders.order_id = order_details.order_id)))
  GROUP BY customers.company_name
  ORDER BY (sum(((order_details.quantity)::double precision * order_details.unit_price))) DESC
 LIMIT 15;
 "   DROP VIEW public.vw_top_clientes;
       public       v       postgres    false    223    224    224    223    223    220    220    4            �            1259    16567    vw_top_productos    VIEW     P  CREATE VIEW public.vw_top_productos AS
 SELECT products.product_name AS producto,
    sum(order_details.quantity) AS unidades_vendidas
   FROM (public.products
     JOIN public.order_details ON ((products.product_id = order_details.product_id)))
  GROUP BY products.product_name
  ORDER BY (sum(order_details.quantity)) DESC
 LIMIT 20;
 #   DROP VIEW public.vw_top_productos;
       public       v       postgres    false    225    225    223    223    4            �            1259    16577    vw_ventas_categori    VIEW       CREATE VIEW public.vw_ventas_categori AS
 SELECT categories.category_name AS categoria,
    sum(((order_details.quantity)::double precision * order_details.unit_price)) AS ventas_totales
   FROM ((public.categories
     JOIN public.products ON ((categories.category_id = products.category_id)))
     JOIN public.order_details ON ((products.product_id = order_details.product_id)))
  GROUP BY categories.category_name
  ORDER BY (sum(((order_details.quantity)::double precision * order_details.unit_price))) DESC;
 %   DROP VIEW public.vw_ventas_categori;
       public       v       postgres    false    225    225    223    217    223    223    217    4            �            1259    16547    vw_ventas_diarias    VIEW     b  CREATE VIEW public.vw_ventas_diarias AS
 SELECT orders.order_date AS fecha,
    count(DISTINCT orders.order_id) AS cantidad_pedidos,
    sum((((order_details.quantity)::double precision * order_details.unit_price) * ((1)::double precision - order_details.discount))) AS total_ventas,
    sum(order_details.quantity) AS total_productos_vendidos,
    count(DISTINCT orders.customer_id) AS clientes_unicos
   FROM (public.orders
     JOIN public.order_details ON ((orders.order_id = order_details.order_id)))
  WHERE (orders.order_date IS NOT NULL)
  GROUP BY orders.order_date
  ORDER BY orders.order_date DESC;
 $   DROP VIEW public.vw_ventas_diarias;
       public       v       postgres    false    223    223    223    223    224    224    224    4            �            1259    16562    vw_ventas_empleado    VIEW     �  CREATE VIEW public.vw_ventas_empleado AS
 SELECT employees.employee_id,
    (((employees.last_name)::text || ' '::text) || (employees.first_name)::text) AS empleado,
    count(orders.order_id) AS total_pedidos,
    sum(((order_details.quantity)::double precision * order_details.unit_price)) AS ventas_totales
   FROM ((public.employees
     JOIN public.orders ON ((employees.employee_id = orders.employee_id)))
     JOIN public.order_details ON ((orders.order_id = order_details.order_id)))
  GROUP BY employees.employee_id, employees.last_name, employees.first_name
  ORDER BY (sum(((order_details.quantity)::double precision * order_details.unit_price))) DESC;
 %   DROP VIEW public.vw_ventas_empleado;
       public       v       postgres    false    223    221    221    221    224    224    223    223    4            �            1259    16611    vw_ventas_mensuales    VIEW     �  CREATE VIEW public.vw_ventas_mensuales AS
 SELECT to_char((o.order_date)::timestamp with time zone, 'YYYY-MM'::text) AS periodo,
    count(DISTINCT o.order_id) AS pedidos,
    round((sum((((od.quantity)::double precision * od.unit_price) * ((1)::double precision - od.discount))))::numeric, 2) AS ventas,
    sum(od.quantity) AS productos,
    count(DISTINCT o.customer_id) AS clientes_unicos
   FROM (public.orders o
     JOIN public.order_details od ON ((o.order_id = od.order_id)))
  WHERE (o.order_date IS NOT NULL)
  GROUP BY (to_char((o.order_date)::timestamp with time zone, 'YYYY-MM'::text))
  ORDER BY (to_char((o.order_date)::timestamp with time zone, 'YYYY-MM'::text));
 &   DROP VIEW public.vw_ventas_mensuales;
       public       v       postgres    false    223    223    224    224    223    223    224    4            �            1259    16542    vw_ventas_mes    VIEW     �  CREATE VIEW public.vw_ventas_mes AS
 SELECT to_char((orders.order_date)::timestamp with time zone, 'YYYY-MM'::text) AS mes,
    count(DISTINCT orders.order_id) AS cantidad_pedidos,
    sum((((order_details.quantity)::double precision * order_details.unit_price) * ((1)::double precision - order_details.discount))) AS total_ventas,
    sum(order_details.quantity) AS total_productos_vendidos
   FROM (public.orders
     JOIN public.order_details ON ((orders.order_id = order_details.order_id)))
  WHERE (orders.order_date IS NOT NULL)
  GROUP BY (to_char((orders.order_date)::timestamp with time zone, 'YYYY-MM'::text))
  ORDER BY (to_char((orders.order_date)::timestamp with time zone, 'YYYY-MM'::text));
     DROP VIEW public.vw_ventas_mes;
       public       v       postgres    false    223    223    223    223    224    224    4            �            1259    16582    vw_ventas_pais    VIEW     �  CREATE VIEW public.vw_ventas_pais AS
 SELECT customers.country AS pais,
    sum(((order_details.quantity)::double precision * order_details.unit_price)) AS ventas_totales
   FROM ((public.customers
     JOIN public.orders ON (((customers.customer_id)::text = (orders.customer_id)::text)))
     JOIN public.order_details ON ((orders.order_id = order_details.order_id)))
  GROUP BY customers.country
  ORDER BY (sum(((order_details.quantity)::double precision * order_details.unit_price))) DESC;
 !   DROP VIEW public.vw_ventas_pais;
       public       v       postgres    false    220    220    223    223    223    224    224    4            �            1259    16596    vw_ventas_por_empleado    VIEW     :  CREATE VIEW public.vw_ventas_por_empleado AS
 SELECT e.employee_id,
    (((e.last_name)::text || ' '::text) || (e.first_name)::text) AS empleado,
    count(o.order_id) AS total_pedidos,
    round((sum((((od.quantity)::double precision * od.unit_price) * ((1)::double precision - od.discount))))::numeric, 2) AS ventas_totales,
    round((avg((((od.quantity)::double precision * od.unit_price) * ((1)::double precision - od.discount))))::numeric, 2) AS promedio_venta
   FROM ((public.employees e
     LEFT JOIN public.orders o ON ((e.employee_id = o.employee_id)))
     LEFT JOIN public.order_details od ON ((o.order_id = od.order_id)))
  GROUP BY e.employee_id, e.last_name, e.first_name
  ORDER BY (round((sum((((od.quantity)::double precision * od.unit_price) * ((1)::double precision - od.discount))))::numeric, 2)) DESC;
 )   DROP VIEW public.vw_ventas_por_empleado;
       public       v       postgres    false    221    221    223    223    224    224    223    221    223    4                        2604    24622    order_audit audit_id    DEFAULT     |   ALTER TABLE ONLY public.order_audit ALTER COLUMN audit_id SET DEFAULT nextval('public.order_audit_audit_id_seq'::regclass);
 C   ALTER TABLE public.order_audit ALTER COLUMN audit_id DROP DEFAULT;
       public               postgres    false    247    248    248            �           2604    24605    product_metadata metadata_id    DEFAULT     �   ALTER TABLE ONLY public.product_metadata ALTER COLUMN metadata_id SET DEFAULT nextval('public.product_metadata_metadata_id_seq'::regclass);
 K   ALTER TABLE public.product_metadata ALTER COLUMN metadata_id DROP DEFAULT;
       public               postgres    false    246    245    246            �          0    16395 
   categories 
   TABLE DATA           V   COPY public.categories (category_id, category_name, description, picture) FROM stdin;
    public               postgres    false    217   	�       �          0    16400    customer_customer_demo 
   TABLE DATA           O   COPY public.customer_customer_demo (customer_id, customer_type_id) FROM stdin;
    public               postgres    false    218   �       �          0    16403    customer_demographics 
   TABLE DATA           P   COPY public.customer_demographics (customer_type_id, customer_desc) FROM stdin;
    public               postgres    false    219   ,�       �          0    16408 	   customers 
   TABLE DATA           �   COPY public.customers (customer_id, company_name, contact_name, contact_title, address, city, region, postal_code, country, phone, fax) FROM stdin;
    public               postgres    false    220   I�       �          0    16416    employee_territories 
   TABLE DATA           I   COPY public.employee_territories (employee_id, territory_id) FROM stdin;
    public               postgres    false    222   w�       �          0    16411 	   employees 
   TABLE DATA           �   COPY public.employees (employee_id, last_name, first_name, title, title_of_courtesy, birth_date, hire_date, address, city, region, postal_code, country, home_phone, extension, photo, notes, reports_to, photo_path) FROM stdin;
    public               postgres    false    221   :�       �          0    24619    order_audit 
   TABLE DATA           v   COPY public.order_audit (audit_id, order_id, changed_by, change_time, operation_type, old_data, new_data) FROM stdin;
    public               postgres    false    248   �       �          0    16419    order_details 
   TABLE DATA           ]   COPY public.order_details (order_id, product_id, unit_price, quantity, discount) FROM stdin;
    public               postgres    false    223   .�       �          0    16422    orders 
   TABLE DATA           �   COPY public.orders (order_id, customer_id, employee_id, order_date, required_date, shipped_date, ship_via, freight, ship_name, ship_address, ship_city, ship_region, ship_postal_code, ship_country) FROM stdin;
    public               postgres    false    224   �       �          0    24602    product_metadata 
   TABLE DATA           ]   COPY public.product_metadata (metadata_id, product_id, attributes, last_updated) FROM stdin;
    public               postgres    false    246   �8      �          0    16425    products 
   TABLE DATA           �   COPY public.products (product_id, product_name, supplier_id, category_id, quantity_per_unit, unit_price, units_in_stock, units_on_order, reorder_level, discontinued) FROM stdin;
    public               postgres    false    225   �9      �          0    16428    region 
   TABLE DATA           ?   COPY public.region (region_id, region_description) FROM stdin;
    public               postgres    false    226   JB      �          0    16431    shippers 
   TABLE DATA           C   COPY public.shippers (shipper_id, company_name, phone) FROM stdin;
    public               postgres    false    227   �B      �          0    16434 	   suppliers 
   TABLE DATA           �   COPY public.suppliers (supplier_id, company_name, contact_name, contact_title, address, city, region, postal_code, country, phone, fax, homepage) FROM stdin;
    public               postgres    false    228   (C      �          0    16439    territories 
   TABLE DATA           U   COPY public.territories (territory_id, territory_description, region_id) FROM stdin;
    public               postgres    false    229   �K      �          0    16442 	   us_states 
   TABLE DATA           S   COPY public.us_states (state_id, state_name, state_abbr, state_region) FROM stdin;
    public               postgres    false    230   9N      �           0    0    order_audit_audit_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.order_audit_audit_id_seq', 1, false);
          public               postgres    false    247            �           0    0     product_metadata_metadata_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.product_metadata_metadata_id_seq', 2, true);
          public               postgres    false    245            %           2606    24629    order_audit order_audit_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.order_audit
    ADD CONSTRAINT order_audit_pkey PRIMARY KEY (audit_id);
 F   ALTER TABLE ONLY public.order_audit DROP CONSTRAINT order_audit_pkey;
       public                 postgres    false    248                       2606    16446    categories pk_categories 
   CONSTRAINT     _   ALTER TABLE ONLY public.categories
    ADD CONSTRAINT pk_categories PRIMARY KEY (category_id);
 B   ALTER TABLE ONLY public.categories DROP CONSTRAINT pk_categories;
       public                 postgres    false    217                       2606    16448 0   customer_customer_demo pk_customer_customer_demo 
   CONSTRAINT     �   ALTER TABLE ONLY public.customer_customer_demo
    ADD CONSTRAINT pk_customer_customer_demo PRIMARY KEY (customer_id, customer_type_id);
 Z   ALTER TABLE ONLY public.customer_customer_demo DROP CONSTRAINT pk_customer_customer_demo;
       public                 postgres    false    218    218            	           2606    16450 .   customer_demographics pk_customer_demographics 
   CONSTRAINT     z   ALTER TABLE ONLY public.customer_demographics
    ADD CONSTRAINT pk_customer_demographics PRIMARY KEY (customer_type_id);
 X   ALTER TABLE ONLY public.customer_demographics DROP CONSTRAINT pk_customer_demographics;
       public                 postgres    false    219                       2606    16452    customers pk_customers 
   CONSTRAINT     ]   ALTER TABLE ONLY public.customers
    ADD CONSTRAINT pk_customers PRIMARY KEY (customer_id);
 @   ALTER TABLE ONLY public.customers DROP CONSTRAINT pk_customers;
       public                 postgres    false    220                       2606    16456 ,   employee_territories pk_employee_territories 
   CONSTRAINT     �   ALTER TABLE ONLY public.employee_territories
    ADD CONSTRAINT pk_employee_territories PRIMARY KEY (employee_id, territory_id);
 V   ALTER TABLE ONLY public.employee_territories DROP CONSTRAINT pk_employee_territories;
       public                 postgres    false    222    222                       2606    16454    employees pk_employees 
   CONSTRAINT     ]   ALTER TABLE ONLY public.employees
    ADD CONSTRAINT pk_employees PRIMARY KEY (employee_id);
 @   ALTER TABLE ONLY public.employees DROP CONSTRAINT pk_employees;
       public                 postgres    false    221                       2606    16458    order_details pk_order_details 
   CONSTRAINT     n   ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT pk_order_details PRIMARY KEY (order_id, product_id);
 H   ALTER TABLE ONLY public.order_details DROP CONSTRAINT pk_order_details;
       public                 postgres    false    223    223                       2606    16460    orders pk_orders 
   CONSTRAINT     T   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT pk_orders PRIMARY KEY (order_id);
 :   ALTER TABLE ONLY public.orders DROP CONSTRAINT pk_orders;
       public                 postgres    false    224                       2606    16462    products pk_products 
   CONSTRAINT     Z   ALTER TABLE ONLY public.products
    ADD CONSTRAINT pk_products PRIMARY KEY (product_id);
 >   ALTER TABLE ONLY public.products DROP CONSTRAINT pk_products;
       public                 postgres    false    225                       2606    16464    region pk_region 
   CONSTRAINT     U   ALTER TABLE ONLY public.region
    ADD CONSTRAINT pk_region PRIMARY KEY (region_id);
 :   ALTER TABLE ONLY public.region DROP CONSTRAINT pk_region;
       public                 postgres    false    226                       2606    16466    shippers pk_shippers 
   CONSTRAINT     Z   ALTER TABLE ONLY public.shippers
    ADD CONSTRAINT pk_shippers PRIMARY KEY (shipper_id);
 >   ALTER TABLE ONLY public.shippers DROP CONSTRAINT pk_shippers;
       public                 postgres    false    227                       2606    16468    suppliers pk_suppliers 
   CONSTRAINT     ]   ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT pk_suppliers PRIMARY KEY (supplier_id);
 @   ALTER TABLE ONLY public.suppliers DROP CONSTRAINT pk_suppliers;
       public                 postgres    false    228                       2606    16470    territories pk_territories 
   CONSTRAINT     b   ALTER TABLE ONLY public.territories
    ADD CONSTRAINT pk_territories PRIMARY KEY (territory_id);
 D   ALTER TABLE ONLY public.territories DROP CONSTRAINT pk_territories;
       public                 postgres    false    229                       2606    16472    us_states pk_usstates 
   CONSTRAINT     Y   ALTER TABLE ONLY public.us_states
    ADD CONSTRAINT pk_usstates PRIMARY KEY (state_id);
 ?   ALTER TABLE ONLY public.us_states DROP CONSTRAINT pk_usstates;
       public                 postgres    false    230            #           2606    24610 &   product_metadata product_metadata_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.product_metadata
    ADD CONSTRAINT product_metadata_pkey PRIMARY KEY (metadata_id);
 P   ALTER TABLE ONLY public.product_metadata DROP CONSTRAINT product_metadata_pkey;
       public                 postgres    false    246                        1259    24616    idx_attributes_gin    INDEX     S   CREATE INDEX idx_attributes_gin ON public.product_metadata USING gin (attributes);
 &   DROP INDEX public.idx_attributes_gin;
       public                 postgres    false    246            !           1259    24617    idx_warranty_period    INDEX     �   CREATE INDEX idx_warranty_period ON public.product_metadata USING btree ((((attributes -> 'warranty'::text) ->> 'period'::text)));
 '   DROP INDEX public.idx_warranty_period;
       public                 postgres    false    246    246            5           2620    24636    orders orders_audit_trigger    TRIGGER     �   CREATE TRIGGER orders_audit_trigger AFTER INSERT OR DELETE OR UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.log_order_changes();
 4   DROP TRIGGER orders_audit_trigger ON public.orders;
       public               postgres    false    251    224            &           2606    16523 F   customer_customer_demo fk_customer_customer_demo_customer_demographics    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_customer_demo
    ADD CONSTRAINT fk_customer_customer_demo_customer_demographics FOREIGN KEY (customer_type_id) REFERENCES public.customer_demographics(customer_type_id);
 p   ALTER TABLE ONLY public.customer_customer_demo DROP CONSTRAINT fk_customer_customer_demo_customer_demographics;
       public               postgres    false    219    4873    218            '           2606    16528 :   customer_customer_demo fk_customer_customer_demo_customers    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_customer_demo
    ADD CONSTRAINT fk_customer_customer_demo_customers FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);
 d   ALTER TABLE ONLY public.customer_customer_demo DROP CONSTRAINT fk_customer_customer_demo_customers;
       public               postgres    false    4875    220    218            )           2606    16518 6   employee_territories fk_employee_territories_employees    FK CONSTRAINT     �   ALTER TABLE ONLY public.employee_territories
    ADD CONSTRAINT fk_employee_territories_employees FOREIGN KEY (employee_id) REFERENCES public.employees(employee_id);
 `   ALTER TABLE ONLY public.employee_territories DROP CONSTRAINT fk_employee_territories_employees;
       public               postgres    false    222    221    4877            *           2606    16513 8   employee_territories fk_employee_territories_territories    FK CONSTRAINT     �   ALTER TABLE ONLY public.employee_territories
    ADD CONSTRAINT fk_employee_territories_territories FOREIGN KEY (territory_id) REFERENCES public.territories(territory_id);
 b   ALTER TABLE ONLY public.employee_territories DROP CONSTRAINT fk_employee_territories_territories;
       public               postgres    false    4893    229    222            (           2606    16533     employees fk_employees_employees    FK CONSTRAINT     �   ALTER TABLE ONLY public.employees
    ADD CONSTRAINT fk_employees_employees FOREIGN KEY (reports_to) REFERENCES public.employees(employee_id);
 J   ALTER TABLE ONLY public.employees DROP CONSTRAINT fk_employees_employees;
       public               postgres    false    221    4877    221            +           2606    16493 %   order_details fk_order_details_orders    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT fk_order_details_orders FOREIGN KEY (order_id) REFERENCES public.orders(order_id);
 O   ALTER TABLE ONLY public.order_details DROP CONSTRAINT fk_order_details_orders;
       public               postgres    false    223    4883    224            ,           2606    16488 '   order_details fk_order_details_products    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT fk_order_details_products FOREIGN KEY (product_id) REFERENCES public.products(product_id);
 Q   ALTER TABLE ONLY public.order_details DROP CONSTRAINT fk_order_details_products;
       public               postgres    false    4885    225    223            -           2606    16473    orders fk_orders_customers    FK CONSTRAINT     �   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);
 D   ALTER TABLE ONLY public.orders DROP CONSTRAINT fk_orders_customers;
       public               postgres    false    4875    224    220            .           2606    16478    orders fk_orders_employees    FK CONSTRAINT     �   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_orders_employees FOREIGN KEY (employee_id) REFERENCES public.employees(employee_id);
 D   ALTER TABLE ONLY public.orders DROP CONSTRAINT fk_orders_employees;
       public               postgres    false    224    221    4877            /           2606    16483    orders fk_orders_shippers    FK CONSTRAINT     �   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_orders_shippers FOREIGN KEY (ship_via) REFERENCES public.shippers(shipper_id);
 C   ALTER TABLE ONLY public.orders DROP CONSTRAINT fk_orders_shippers;
       public               postgres    false    227    4889    224            0           2606    16498    products fk_products_categories    FK CONSTRAINT     �   ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_products_categories FOREIGN KEY (category_id) REFERENCES public.categories(category_id);
 I   ALTER TABLE ONLY public.products DROP CONSTRAINT fk_products_categories;
       public               postgres    false    4869    225    217            1           2606    16503    products fk_products_suppliers    FK CONSTRAINT     �   ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_products_suppliers FOREIGN KEY (supplier_id) REFERENCES public.suppliers(supplier_id);
 H   ALTER TABLE ONLY public.products DROP CONSTRAINT fk_products_suppliers;
       public               postgres    false    228    225    4891            2           2606    16508 !   territories fk_territories_region    FK CONSTRAINT     �   ALTER TABLE ONLY public.territories
    ADD CONSTRAINT fk_territories_region FOREIGN KEY (region_id) REFERENCES public.region(region_id);
 K   ALTER TABLE ONLY public.territories DROP CONSTRAINT fk_territories_region;
       public               postgres    false    226    229    4887            4           2606    24630 %   order_audit order_audit_order_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_audit
    ADD CONSTRAINT order_audit_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id);
 O   ALTER TABLE ONLY public.order_audit DROP CONSTRAINT order_audit_order_id_fkey;
       public               postgres    false    248    4883    224            3           2606    24611 1   product_metadata product_metadata_product_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_metadata
    ADD CONSTRAINT product_metadata_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id);
 [   ALTER TABLE ONLY public.product_metadata DROP CONSTRAINT product_metadata_product_id_fkey;
       public               postgres    false    246    4885    225            �   �   x�5P;n�0��S� E��;�:0�5#=%B� 崹}i9]D�|?ꉶ�B��]���YZ�C �)`{�X��[���6�������(u�|�r�2��/���N'����lN1W��E+����RUHYb6�S=U��^��h^�d?;Kѝ,�=�}	Ǥ����w{'��������*���\6C��"7|{��*�A�#��h� s\�?�S�f��I;p��/����	�u�l��|���      �      x������ � �      �      x������ � �      �      x��Zˎ"I�]_aRK��RB���t�<���Ro�/w�D������Lw�T�QI�h�j��9��Hr�KU�x�5�v��^�`p�� ���U��<��6�rɆ"�L36���T�S��8yx�l����<mp�eM�Fa��8b�ah>���N��L3�����i�kǶ�Z0
�SĂ����0�����!VIƟ�FFt��6~�eʂ�J4�J�H�Vgy����k��Æ�/��e�ۍ�MH�5J��}g��۶]�\ÿLW�h>�\��aI*���O�LO��7?�g2���0an��m��[Ӧo��L�s�I�x�����1�o���xW���ێ�?��A�|�S��x�(�?:����g��^�s]ϫ��j���~F{��`<�Y,����{�ڤ��N����)�ȃ�.��S*�$UZ���経9�ؠ���?h��o{�	6{�+3�7��np���j�֚���DAk���enE.3,�a���0I����$T�_	�!n��pG�p<Ss^@����Y�v���ǣ	��}2[����O�e�?�Q���ӗ��K��R�).��Ys�k`����}$�����CL�l��ZM��4�R2�k8ZC��^�6j���f�ӯQ�J �]��Z���%��O��|��v0Q¯�;�@h��7q�*Wd��w��@H~�;�-��2�u��0<
��$�b��� ����\����{��po&�rC��)ea)Uԛ��]V���jXv��*�:���C��dWo'Q$R^:4c�(<���7|��$�Y�\"4^����L<	�oF�U�]Ǭ�bs�{C��p�J��ͪ��u��9kv>��;,I"�` c�%�M̗m��4�|y��� F�,�JvZ�G��A����VК?`z˼�^�{��ǃH�D�i�����>�K��,g-��a�p�4Y� ��R��Ȅ�C���o�n�u�����:�y���4��hZ�"B�-sy,v���0�������BLߧ�Հ�oޤ?�+�3}�:����Vw<��y�}=+$\�	c8�}����P��+�}���	R�65��&̏�@t�Y�Q/����x8�1��L~��a���\a��'����,K�d������܏=z�)�D�'�@�M�6䴺fa'Rq#8�B��喖G�.�� ���>Z��U�7��)��2,q+#8��@�o�~�$��*��A�����b�:�u�z{�ڬ�
�o����5���q�G�\�$�Ge2}�k�|���}�М
���u8���}��j�!�k��;�[N0Ŗ~1���"-by�g�}a�V�T�8������-�B���p�(��|���Z'��A�"&��e�qAc��7fڼOH��	B镓M��=�v�f�neh��Y�Li�;)d	e镌�4!`�T���%����͚�Ç@�T,�{(���]7-þ^9��`��B�0"�J�"Z%  �[iq�D-`�-��ش|��~��o�lΦ��}�Vp���f�I���.�a/�X�r.7��Y#h�v(�	�&X�Gւ��Q�G���9�3�i��\��-�eHߘ�;��{h �5�kd�y�̔��)pq�®���}�=dmL�Ȳ�B��	�����l�/��i��Y�vi�1Mb˓�:�̻ͳx ?���>�i���j�ɧ��[Y�%�"1t�K�O��o(����`�W���*#��Hx����Aѥ�-�H�Gn9�w|	YO�4�%d=��uM��rmٺ2<={���r������ų�f���U��4y�����5����W�5exV޴	�=�j"	�'��m���\$�h��[$J�͑Ρ��Rc�\DX���-�����k,�a�k�����)�"D����� �KDbB7 �.��M@ W�;Nyu>����P�BMQ�&XD��Jͦm�s���}0��=N� q�D����]�:����8 ���0�ED�[�]T��K�<��RB��� 	���g����-~������=�����bi�ʲ�/{� �� �x�P�R���7>A�OIh$�!]�Lcʸ�cS��KM �J:��?L0�І&�X�P�B��;�V�	�Jߠ��t1hp��1�L��N��|Et����l*���wI�:U�M��w>��W� ��pM�A��j� � �M��Z�����ٚy�ϔ��l��3��9�bU��6�r;�>�tb���xp�>�~LD�O�bD�N 7c�;@���G�?�	�6�3�o����[��R���ZҸ$R�I�B��S6YQ
9�%Q���l��JaM?PV��𫳍K��|�e�;�Z�7F���xT@{��C��"���o�>nK!��Y��Q�9��,)��A��ꦍ���2��+�&�����g�Z�x�Que�u �Ժ����:�ZM�<���#��B	�5�@\̌����s���J}���6D��5�1�@���8�kU���:jN�˜�O��>
כ�H�T��kp�/QZ7��l \�H�b�n�O���J%���Fh��#f�7s�˔֙�jVX���ɛy�T���PR8Gi	���O�'y�?�B�dl�ܝ|(U����(���Ψ������:��%k'��=.^��e�CQ,d��
_i ,^�Kw�r݊�U��	Ͱ6Z؝� �-|�N, UZkC�"`�	��72I\�v�T.��u�4�#�Qv'�r��Ur��5l(Z��rm7t�=��N�P�H����B�4) �7|���D�X�� A-�l�L	-�}PU�^1���m��_����}�Z��)��r�����AKRu��#aN����MY�Ci��*���]H´�G�}��z�,"�CUF���c:�g��}b+DB�k\Jү1��j.���s�l�f�:H��=խc\��?��2t.�t�36� &�T��i�+6�1��" ��oq�P���1UXn)�>���r��lë4�����=�z^��3�B�.������PZC������m��L"�z�����1��� ��ґ��d�g�}S�� d[��ϊ=&&ӥ@r&��$>����o�g¶+��L��/���8Tx��$!!�NH���ɰ�<�.��M[�|��0M��l]�a;��h�f�Y��wI/�p��=����Jh�k{3�).��`�d_�Q~���`�BHf��C0(H�:��i�m����o�	��QgB��̠��D�*�t��!��~.�|���%؂O�-HF*>V����7�·]�:t,�6�fԀ�4 ��H�Ӱ�C���09 ��"9 ��ACR{P���{BjaJH��;��Q���mbi��륎��fm<\W[>Iо�@>)�բm
҂֔�M�I������0�u]�.4%�g�c�i$q4ɓWC�6�L�C���R*b�¿��~��W�������"�A%A�BM���&�u�\o�W��3W��^��p<���!Ծ+;�2+��6�rD�3�%�{�x�9_�ԕ�>8�` ��1T	L�t�zC%>_f��x:��u9�D��p���4�U�T7�s�	��}!1�*�W��٣���oO!��+�)��j�V'�1�t�� ���r�� _���@�*���*z������\n�����8���?� 5��.�R^�A�q��ъ?"�W�J�&@�$�����4	�k���[��̂>	���R_s/5�gU����7�y���y��F��sFbt*"�4T�}�IDGu�q>�����g(�HOPCQ٤�\���NA�2�-�8�6���A)B�l�B��0?})�I��S�8ʤ�����4Ɓ����M+�4�M�ٳ� 7[Fô��p��c׭M:�^���	���K|	`d!�4���t�:��-p#o�(�P
dN��7z��#:C���|X0�Zc6	�Ǣ�Ӊ��f�O���`�*[ferݢ_�M�"㥷�؎Qq�+�6��F=6|�2��	T�1�7	�a5R%=��^|��"�f���#�y�&�k;o���i3�������y��`@��U��	��o�d��B��xϱ�   7�B�����_Յ�a�c6�SdH gm��A�4�AD��&'Hے�@���l��{(<߶>=�N��#�l����L}�IR�.�<�>4���x.�#2���_%ﴊX>�h�ĵ���[ae���^V1�`�격jv�G�I>�/������W�@� \ J���i���rRTLe>oa*yc����gd���|f�Bq+o�oY��]>��R}
V����?6B���Y���L�2��j��=J�\�C���@�H���8��ɵ�$�2$&)$KL��}1��I��u�UKʨ��0�
ǥ���F,L륊�`K��A�< SC�v����R,���ܸ�:Q!���W!bZ�Y"f1{�Yl��P�o�7ؐZ��A7��v'�V�trS�����Cy�kh��4�G`@5���a�{Vv��3�A��R�ɏ�;�p�Q��FDPo�<�B���_��a}�Z�m֪#]�͂���Jd"~n���E�^S(�O��˔ԡ�72�Vl�w����������#C�:��y�b��� ��\[.,~��x�uQ���zNM܁t����C�(�fŧOT[�k&!��^�y��3��Ҿ�|u�2�|�̨9
��I���(e�KҼ_P	�z3}�jSQ5�"���mn��o�]�z\eS50���R�e|����Y�:axq+����Q.s�����7~\|Ӗ1���:/_�@��k��6:���ꊤ��i k't�H�YL��vc�.�Hrc�X�+��nö����1d6��������@��_P�AQm#܊8[n�d��o]>i��J�LDJ��=~�<d��g9(E^��mص��d
'�����:}���Ԛ˖DIHh9ucn�P�*����ā9��²�q�m�R��V�:J2����F�ͻ�f��7td��~�t�>�|~Nn,�
� ?}4@����80�֢��׵�锴�����J�R�ɓ�0Y@n�z��%��6RNx<F����*�7�e56�3��ٖ�9gh{t�rz�g���!��<�e|����?� x�N�ΕevcɃ�+Mmy��j��i�W��MGߺa��k��mX��� ���ڧ����"����Kn�1�KA)����||GN��.S]��_N���n�ҞQ/�AF
��S�F%C���������R���~�l�ytl�TvWFM��&F﨩/V>/Ss&1���2:`�������l�,���#e��1K?L�
~ԭS��g��`������]��1��및p�~Dr@R�����P/D�
��N��(Yc�(NJ7�"��Յ�<A�:�\�Lhr�z�yG�]T��]��-��7M���qy窠B����\�]g]����Զ�S�vasԙog�J���Ie��D���\U�I~�ol������x�PK�N-������ ��6��˵^{F�>�@/�)齏~��d�GQ)��Хwi3����;*�'Ƚ��#�w��ڴ鍓�`:�Gz �+���@��%��d[�"�)V��x+�QA&}�D�]+���^G�쀀_.k������c�I�\Bg���EG>o�u>I��Y�L����/�5]�g�M�K�H7�>v{�"�V�^��p[Y���߷�[L��u���l��.�_R@*�_��nxo���x=ĺ{�a���v��,��i���9K��ݢ��̶E����B�ga�U�̀<�x\���=el��8��G {r���QW��sv�[����?�8�O��x^}5�
�4y��!�Q<���@�N�L���2˨��ZueT�c�V��/oسD      �   �   x�%���E!е3'@xB/��:&��
G�h_�ٶ����˲�Ɗ����~%��;V �]������l.G�_c���=�Z��p��#�~F]�p�db����d���\M�Y�����,8|l�~�ȫ�<��	�3���J�D/I�r�,�G�j^/�ci^/N>�c̾T��󿿽�?��@      �   �  x��W�r�:]#_��Se)"Ej�<��J�,���&!P��}�����*�e.�t/v%�M��.t�c+QK����J'�^=K�tC�̳� I�>��;����|�ӑ���Y����Q/�~��[I�}-�Â�gI���;KG��<���|�OY�M�����.��͕.�D�_,�ߺ]Q��lv|mM�/�ي�����F��)����|:r��$�3�0Ͷ�^��_-��f�=>b��_����pw���F6O�Ң{#�o����W�_:(�!KY���_�>��x�O�d�S�NJ���x��퇔��ֵ�l�K+_�T!�-�U%�=�mve	����d���36���Un�5;v/p#1���L�Y��Y1��r+	�J^��+¤��P�2"�q�K\��^�;ux]��Sz�7B� t@u���� �E���5�뿬�EN���(��g+E��gi��S�5J�R:��z���.�.���o����M�
��8Ĺ߄n��q�4��E�D¶'�ʏ�a�RXT��cTӡ�FTY4�2��w�եO5j
���e%��.#�X���[Q��*��j��fkl��9f�!{�~Zg렬 �1��`�C7��O6��I\�Q���l<MS�4�;~Q?�C���?k��6��(m�%P�8σ�©�
T]�x)7VJB��d����u/��8�Wˍ�g�K���kx�ز��zB���7V4���R��.�1NT`�XI�R�6��Gt��(�y��]A�:�O�UI��S��ح�c����{��O�y㐱c�%Ɉ�au'�Ơ�;��}����fk��<�N;��)Z�s�Zoj�*^+(O���>_ual��!O��c	�d�ρDv4�y�[@Kbo ���u��dҳL����p��7�*�zM���� ��;�|k��Wִ��7�ы�H�6h��E[TP�f+�4;���!�	oX"���ɔ%�,,�����kk%g�>�v�~��ΦI�=�e3��q�=���9�[���Zcȸ�<EW(�'�!�+9���R��	���d�d�w�e'���c��RpM8T�~(�Xc��m�EZGRb�L�ڎK�/���^�}#b1��1������x�'C�pk_�E!�C �{Y�}�
�樓�M��z�j
Қ�U�h�K�oe}��}�����.!hM�ŴNb|Z��`�֮/S>}���t�pHg����حz��W�s��a�>[.ι,�6�*�9����׮t��1���Y ��'��t����y�:lL�� ɽ�	�r�lk������u�3u�y�Tq�A���f����;k����N�G4Z�?^,�c��ߢͶ�+c#^�1d�����h��wt2��#��4$9�Xb���HL`����~��[I�0�l����s���#��|>c�$6�X �b����;��~CӭݺH��`���ڡB�����mB��gL�:�����6B���줰,�Op4K��ǉN�)O��R��[k�2�n��ZZ{�c��{��1����n����0vz�4��v�S>4��R{f�4��(I������,;n�I2��t�e��p�~F?���;�U ̇l==@E���S����.��Cq5�{O��8gW�t/�U��-�8zN�tL�A��)�.1`x�z��z7���X��'��h�O���#��6{#^�Z��h�˟zG��Hޫ����g�o      �      x������ � �      �      x�m�[���D��Sa�0�;�q\2S�u"��Y{�BH�\�OJ?�������6��g������5������g���>�[*k�OM?�w�E/a���75��~R�_4��|h�C��׵�wwUQ� ��o�&[sX��E�y��Eԟ�<~�����dm�X��oY�Ơ�C�'��b�Ї��ކ���9E:���h��ۤ�O��z�����T:j9j맾�����ۮ��nа����}0������4��.��Xi���F4��M6�N�5��.���.Oo���xl��.*����n���w���c�ۃ��orH��;���B�4��4�%æ�]��^{�hf��?V8�y�^1z{t��3_B'+G�3��EvI껥%Y=6����J�s��d����Q��������� ���4u}��w���
d�5�}��������(���;P{��#a����r9˓K��9>U���@lv����=z��z�R��[[���}#�\Ch� iR>)�K�U��M��z�4�&��O��iI@HǴW�#����A���r���as�2�d.,�����H�=Bo{����+��K�xO�
�,��H�*�?^�q)�1���"T�\e/�D�*��[5���/���+�k(�h��ߦ�KҐ/���'@��"�9�F$=�\�tS��N���_Z�iO���ݰ�=j���nS�g��&������������j������L�[o��	�3 m1|(Q���2M@��DsM�Flh�DuIQ'��u�D ��U9��'#ae Q�$9IB�w7�0�շ=�_��x�^-�g����?BQo�]�:�^�.�k��Y�}7ZZkN�m����w�;[��Vy��Dr���(kث#)�)���@�^r	�Vc���qP�����ԁ�������q!�XhA�����]�Y� l�#��]�.3"g����[֏�C�.t+/�&��*N��{%�~���%7���)��]�- >�UD����&�O�_$���HC�����F�+���t�"C����h?;1\g"#|� T8j��M�	˷�)��R��2x��F�Q
�;��A4��M��= UD''�*I�#�Q��ۤF�_�a\z��%K&�v�c�)��\GX#0,U�����Z UD'�.Yk|l�G3����S��K�yI����l��6Sc��k]Y˴5ȟ���s�����ݘ-���)#���j�iN��ͻ⎪�1d�� ]���0�`Es�>�1ϳ�Y�/�|��~*�k��`�ʇ~��h�s�5&W����F�b�6.lgF0�����x~�W�5�M�=8}oa-�|u�����4~ӶԳ�y���|A����Ƿ%hK�Z6��Xy�k=�ˀ�$�"��K�rïްr�7���d{:�̣��B(c�M'l,�W��\�)/��>uH�&Gԭa�U?�W�s����L�!đ"dN��Z)���{L��}d�;��w�K�غ�x�2hnޏ��%�����C���т>So><6��ms�ۂ������A1�ϠDB�}�<q�>��-vNj:�bo��������I�q,8@�-��B�����ɸj���q�^w���H^�AO^	�W�B�����#�A��I�zֲ��6����b�?.^���~�ƫ;8�겛��N���׺�����K���҅�WN��)�`"�yv@��f`	�+�/�v,��ⱅ=6���3+��B��O����}����)��~g	7P��US2�Ee��W�RSKn����m潦�8��mȀ�;e*��;�ǏǑp��T� cQ�J߾�Fp���ȁ�q`OL���}���L(N��U>F�R~!@�c����͛�>!߃>����B�l��k�_r������=F{@���h�����E�K��m=5�{8��`�8��H{r.w*w!mMMH��?x��z �]�a��qf�MOF�<���Gݶ��+�޼u��� ��º^~��Vâ��q��:SVc��V�r��xd?س�5�_�%G	ޙ5�Q�qs;��Щ��t�`�x�Y�����W�4G�ԞU[n�h���	]����K� q�������W5���@�;[P��l0Z�"���P�*a)�r��b�7U�����7��kCt��S^�M���r;l�Ѩ�z�?����S��G��gz��¦�� 4��2te[S�d�R��M�
mf2 tP3��C�~^�\m�~	�|�'<bH�k�!��zZ�Lr�"1VXM��k�xj7��E4��5�18p{d\���$�>������y��g����U��������m?㚌�h���"3��� �"�U��eq1����H���(xZ��*p$��\�]rhP�
����[m5F)z9P?�c�_BCy��;��U�6y����v���Ra-;S�)��Q% O8O%��y��Go>�a	�g���t�n�`�a�ض���@���V����MyD�S����9�M@�9�j�ׁFGG�7�U��L�j�8��a8���r�\�����K�xX���8A?߾0�狨zt��H���ȨF�/�W�3rNqڛ�;U��t�� 5W-q�O�_��+f�� �#$�jB\�S�Z�>�OFnu���I��������t���(���?�s���	)V�Ρ]DV���*tn�|7��x���=�* J�0+��qԘ�7���kzL�#�"e�<��4��|<_����d��T߽E��]gp .��� 7��)],>V:�c�Gπp��6��~m~�m�>�WC��4����h���}`W�[~�_�+p�L;c��Y
=��g���f����y��J�	��:{��W�h3[Q����Ztl�uor�����,JC�7BV;[�^�>�{O�r(p[�!, =�=�3E>�)�L�19r�}C��\�ʿ�P_�	�O����������mS�<��i6�!k��<���2�+�)��JBw�@���a�*a�rJ�����h@�^u�-�nD*��a���u��[}�BWc���7�\D��q��w6�-r9��L�lU��Y]g����Y�ﭬL�:�x�̩���h�?���areW��7�Y���ᙡ��W)��%
78:+���	|��1D�i��N�6NO[O��/yH�O�Ӽ��4�'�b �����ܻp�Z)�=N��#�A0W�$�bA)v�!=럣�jR?N�#w̥��@l��-b����7»��{��6��g3���E������:[��_ܞ��v&A��(��wv��}���=��_��jĂ�YG)#}�f�g�Xs�͍n�v��r�}��w�����s�v��J��Y�Z�63H�zWH�{l���g$�а���t����;څ�m��[1���@�>��wL�vA���v�뛹���axC��q�#e���޳օƞ���W��V0��z�%D�qt�lio(sG^H��1%�G��q�����p�-=7\���j�fԔVvf=2�����Y��Ě�!V���m�ZP�a�{�7����c��;FRU>���Bo����3͹��}6+)���Έ�G�0�RI-?����pU�琰G����8�E}/u��"��K�GD��[�l��;�A�(��ܸͲ�m⣟D*EtR�|]��MՂ:!�w��F��xڡ�T,��ʏ��ϥ)m���Ш~�A^�M���ǎ��Sg�E��/����E��<5p~�����em@8u�ټݲś'��h��P˖�����	���/A 8��xm����0GdKQ�B��}_~!���k�>E���a����v?Lh�uV��ut�OE;ʘ-�8��'g͖��Ѓ��cw�p���ֹ7��u4n��7H�Q��X�e<�'֑ީb֭' �T'��@Ӫ��<Lh�ܷ�MN�]�Z�8��rϨ��K�!cz��{It����n�1�~����|\�j���uk���B�U��0���"b��F)�����6�Fl`+v��f[gh��K�����ͱ��|5�r^
c�x�D��U�p��Bz�ȻK�	m����:���Z�ܽ	�ψ�iW䨴LM6db�N	3N���عv�����4    �A��p�������q>o:v.cخ[s�Y��M��*��-�Ϳؙ�u#��ѯ�$hN�,���M����i�_$�?��2݈�BG)a_k�%��(M�Q�s�`۠{{�dOh+7����t�7��9,Xh��v/i���̳^%A<��[�k&��1��������|I��v�P�ѳ9��(Bi��HQ%X�^eb�]w�,��_��&�ղ�$�������6+�{4rX���=j�'k��ɉ�|�4:)��@{R�X�d�?���*"�V$���cȈ��.���B���ϼ؟��5:^��@�`��v�]�cP?q�f�� 4������GHoƯ�'L�K�|�V�����X�`8)9�����%��"(�`�&�+����u�`$�������=Z�;��G=��7�0Ts|Fsr����/�I7�٥[x:��#|n˖��V:ff��(Y��2ZY����޵@y~;�g�3��;���"�w�U���"X-�KP���u�o���ްx ����Xz�M	�qY�d�:�p��5�f^>�(4�3�������ϣ��"�BY%��{�h�����Ch�ԉ:%x�<���K���A�B@�_Ɛal�;�m\���s8����ѵc8�4WvP�?�ȭɍP��K-�5<MHO樭�؊��J K��'%+����w�Ҋ�5�����2~d<��k�����r�U�L�$(:��9ME+@Un�U��n�|6��a�X3��&�^yl�J�������P���ʘ4<ljL9O�|g}�!��5���XL4�� �1't*z�Q>s�*�[JC���cǦ��`�q�e�t(��6=u�L��װov����s<�����n����vd�Ñ���(��͐uV�޵�@;����J�|^T���-��j��'@9��l;KD�_C�JQ���r7�j?��U��r�?yh ��]W����/���';.,�B}�T���)�v�0�Aߢ쫺�?��^��Q|x��R���nx4R����\�H*���W����ftGV���-,����˰ .�=��W�G:���I˖T>�T�yd������W!B�:7�W`y.���rW�7y�P#&DG����x��4�������:�A��R�(��w���|�io�h��H�xP��%W��uT��r >HBl����tJr�j�R��~3��hȰ���H�Rm�Qe 
�&��6kLZC���=�&�k-�#j�޺��Nu&�����1z�1e��I(ZsQ�)����-�'��W��Gfٗ?��V:5�Θ��i���Jo�#n��_P���������m���‮T�!�-Upj.$l}b���gK[	�ھ�ON��=++��^�xٹ�����о�:�����{��>�m�?�k�@�b� BG��O�e���ʏ����h�w��QoC���#8'�=F�7�Mƹx���2��\g_�{R����s���b�s/q�3�5���3A�Ɔ�ٙ\y���ۋ�HeU�Y�^`�3xGGCV'�B��3��W�\�>;��nsحRN����;Gs��D ���h$ ���	!'6��a��N_�`7�S0��-{[�óv"�DW1�0�+���O�3<]Em��
�*;�&(��{�啞�&p���<�島�ʌ��=��y�_#�w+�+�Ku8>M�l���{X'U�\z����τ7,�����{�HZ�������C��<�v<�:R�#YFHM�S��T��o�X����b�*��n��k��`��*Tu:�	^�4o�<�SK�F�๘>*SgB�y���:��0�����
�]( ��"���=
|��.�+�*9g����9�1T�:g/�E������*������H�>0y�]Ǵ�:���򙆡r��o4x��>V�#e����h"����+���R��F~j�^��\�>��a���]7`zs�=<�3�+�����tO����˟]y(A9�8��Ү�8cJ,�E�wܮ+#�	��v���t�c�6�$r�#D��e ��zd��<' �Q0J�
��kXq���1m�z1���^���f�d���I:1+��>��F��2ռ����3J�	�����c���p���?�T���2�r3��/���i�ڕ+�X���7���>�� �Yv�2d�( �qt_���Q���OFŔ���]�B�oB]V$xv=Y��l99'hvdģ2gH]�X�٢�sp�Ue������i��ʃXW�����n�{���%KAJ�[��3��'�tk{���[1*(kw������|����v�ԩ�i�j�a9��D��	(�V;�#�X�+*ꡲ�Ax?�r,�O�s����Q��
Y6��+�1��ZG\�W;�3�`Ox��Ɣ��Iݗ��.BSr[�=����J�v�v/_G�a�[=�䴤8k����~4�~�_�+���F��e�ū�_ã��>�>��=�.�o���E�������;�����K����8�s�P�U)�>a�"1�<����R�����3hw�qA	eϐ�l=�H��C�iD��Y���a 4v~oQ����c��{'�P��I_	�czn�ԛ'��{z���0���=[9�;:�\����P����W�)'Coo�ԉ�9%ox�&�h^�`E�ɸ\\a�����1ǁԏ�2s�4	K�s�c���ϵu������EOWR�����Wz���8�|��*�<pC[������Ac감�����e�:b��o���I0�	�-��>(�q1~�ղ��QD!BV­�8�+�~������&b
�B�!��3�>�	c�-�pFqv�}�����!0�ط[d�6��8�Щ�
�#ū����MȺ'����P�U����	Z	�柵d��%�a����y*�ai*�U������̞�r��m��}&R6�e�c��Lů�n��r/6�^��H� �x
~�)w��^�%7��5HG����0Ӹ�����Uc1��k�����><��|��C�ρx��v�͜��[����s��H��9s	��L����|�T+$ճ�o�@�{B7t~n���s����o(,�;W�7f����Dh����䯯k#����x��H��o���G�AVD��{��m�ی�CE�3���^f���Ж|Jkj�LE�tyD}�����'������9�Iv�g��?
�ޢӺ��D���YWY��U�y|.M�����V/�^��Wr���z�x[�����c%И#t`�����'܁ J�k���6*I��e���!�6/n�B��2C�G�V�%Wum�2"tZq��g��g5ˈ��J�rR��5��fp�����;7�{���V�!e��Sgs�(5l��.���x�~����R�e$���X#qR�� �gKQ��I�ԣ�`�6({��,��n�&D�5<����w���|R���*{��?��f�W���4�i����m|�\�̷o���2�_�P���BY�~PGͣF�G׭��s]������]vp'_Ξn��&�4���ѩQ�[{��ً_�����뢐��o�Rփ�/�k0α���9�=2m^a�����M�z&�]7���!u֗���al�dWy����*õ�r:v�;�J�/��	:�laɏ�/z�Or���L��~v�|�C3G��/s�*1�i��������V�!��}�|��侞����7�m��I���� ���]щ9�)��d>����o�X૔���Q��f��ʚ�$cQ���:��L��WŀۭA�_��"�f<e���L���h0����3�}��Ӑ��q���w����ŏP���q��롚+}�gpV�G*��^D���H��R=՜����c���k*���)�sxzWRS�Ok��$��>%��Pצ`��a�G��Ȋ��_���)�둑Õ��t��>�&K.*��VpQu���R�`�s�c�oje���	�Ĵi��+>������3�n=3��� "d�]�w*�}ٌ�֝� �� �  ��&>w�Ҭ4@w6���@����m|�V$&/��L_�)��{�?Þ���5ݴ�Sk���l׺�q�x�s�v� �I��([	���cF��t�R��@�R�����B֨&��`�r�FWη:4p� �\t�;�F��ૐ��t��!ec�o^�n1���ȥ�"���W���|\�+�˽d�p�Ҋ�u���ϋ���>
�,G�
?S�����ovd�;vS\��SCZJ���!dTQ��������D��
T+�	���8���1y9\1;ˢ��0��D�G��$����c3`��R��Ŀ"����#�za%��yU��Ю�x3v9� �ފ��T�@�͋r�_*����K�Me\/KH�f���{��x�vF쩢�O�7»t��^un�2W�?l��t����〗vy	�UyU�"Z���XՃ�\Ԗu���b��#�����U@��!�M�)ԅ�,��J� ���Li�J\h������r��[-��@[��J��G+�1OrѢ�8k��b��s�E�ޗ�E.��QR�'��9�?�{��'}R�ڙ�O)�������ߏ��',b���_q>=�Mo�ߺE_{�&G�^�).]ţ�6��oM�����I�:��%M��hH8q�.����Zy�K��\㛒��턴2�~��c0@a5�|r@֨���x=�������]��Qqp�� >��j��#Y��1�^,~2��zڏ:�����'��XC��ȸ�KI�T!e�`��s�����v�m����r������6��k�ל�yuK)D��<��d�~S_���5�!4��CE�U��-9:T���h��R��w~&�U���=QpwM�r���A�~k�c�M��O7�̏ͼ�¶�G����G{��#77�m.����VH&
6����'����K^rk��=\��`��N��0<��h~<dF8:C�Wmp��\k�#�ʨ5�nt��y��n�FA!;����([�#�	`�+ o�`�g�m����4�tQD�[�mt΄,����6�2�*�=�zH�����a�˷��������U};`ӳ�����Hxx�r�	��1�aLmX�Nz�n������]oAJ�ݼ(�I\��=���#h�_!�e�8/�Ϫl"�HH7�b~a��k�,~4�!ݶ9:��H�R��I��6�����ym�\�ύ���]��S�|j�|�p�/�-���>	?�k��1�j|��"Mm ���NRU����7-h����Ƿ�������x&9��$H�{4H��^0������rM5 �9���>޵��Et�<t�����9��ǫ������F��Z�0�w�2��$�	�mv�ɿ�kc�K��Dv�5���<CsQt;���h���w��@6�E7�.�'� ��nG�����Y���^���?�Ή�!���]U���U��r_� �K�5�@��V^|/�ѹ�ɝ����	��8���Z�8��u�ۨ�\_S��_Ӄ��F�t��9������O�A�͏reH=�Wٴ�`� �>�!��Rm7J�!�|]�>~�篔`�����W��s���ᚓ�q���z�t��C{�V`�	tT�mx$m�y��rL�<���LJ�`[Wh�;���]���opT������3Ӏ��d6&|��Jz�� ��ct'�nt}����/	mB�m�B�H|�����F��s���s����#~�x���0:�����f8.�z��0Zz���ʩ3��0/�!�_�x?��b$��!�j�>���#�q�,��*��U{�s��%�c���]3���7���"C���60�#|���Q�b0H�v�\KR�8���F�;��J��%\�%�����}���c�
�\̑�&5T���!�۰gxYW���Z��qZ��ո9}<��F^ԧIa��{{�����!�#�+1���������V��v      �      x���KoI�'~��,�})儿ݏ$EIl�&U���^Bd���T�&U������ ���j������򋭙y<�#�̮����JU�/����~�rQH���.O�f&!�g�{V��G����
��Lɉ�?0���j�����b��O�ٴZf&��M��U��wG�ߗ_�캚~Ze��23BE�bY�o����W7o2�!�Yt�+�>CL���.>����/S�[?�e]ͳ��tU�W��$��\<��>�.��^V�O��B�"{utyt���w���@�Lf�L��^��r9�O��Zeכ2�[�oʇ�X|�[�]O��ߗ�j�\d׿�
��~�͎��/��哷���{���L��Ұ˷�M9��*��y�Z/n?f����d��S�����/�9�ֆN��_#����\?�&�_�5���l>/��	 �~�Moa�ǋ�Nwy����m�˥1��}��U��q������}�n>���Y%gX�(5�)@��F�f����zsÄY�nɾ��RN���,>?[m�/ �S���S6��$OJ������ ���y���Z�����������,p�i�?U�
�'J�Jn�A>s�k���uv�.�����Cn@Z���
!����C�������Zvid��V(�$��]5�M�֋y~���b�.�˲��"���r��װ��]�������3e�^8���,9���$)����A��������Dx��	/�e�K����TM��g�؋��Y�^W��ϔ�n�y~����_β��~{?�/7 �Pͫ_6լ�/�����ͫL�h�L��D���K�9�]5�^O����ժ�m���'��ۣ��4�����	߀��N�$����;��������V~��]Ç*�И�r�r����C
Tد��.������{Q�o�W�"�z���5���b3�)�w3c& �W��4�*��l�(΋�~yڹZFa�!{��f$�p*p�	��ߟ>?��
<5��PTϫ���`�Q�J�����[��(r�[*�Y�%��x�6�sk�C��p�`���z�s^~�@��%a����K&�p��t�W��r���o�mS-���E������#�V�h�D�jh��5Px��T�o-���������ò�b ��:��b�1_���?>�%u�=�׏��C��[�x��ۏ�Hn�y�Q���\���Ɏϯ.�d�o]�!��2$}v<[�z���cY���q:[eR����U�z���{��7k�������%W$f߂;�~��i0٬9p�D�)��]�\OaY���Ǐ��ӏ�z��/r��m&xf/��FS�]]�[";����B�L~J?�c5�	��5��As��~3+׿�Z�{q{_����$w�g/��n�������R���Z�R��Џ���]��_W��������u#j����gy[���/2Qx��A���^��51|��`�M���5����=�-`����j���Y��\��}���IvS�}��˂ `��pE}���2i|����N�Jr�N�]:?��� �@an>���_��W�����
�L�&���Ϲ~�ۺ���1��1���5
�&��!0鑰!�B��p@��������2���W�"���?��f����-7 ���ˇ�V����l�����tA!T���N� �\���3@#���dG/��`��:���J;A�X~(�e:��A�ᚯ�g��n���>���7w���xN�҂�Uv�Z���Aj���u9�k�@A��~�1_���kA���&^���7ʜ�ף���I~�˺�-���4���u&ܹ������l��Ȕ 9U �Z��b��"r�U�6󻏋�:{U�����~�eJz���%܁?�~y�����S�ʃ��6����*�~������L���i���_�k���U�44�x�����7����HPU�*�U�:���A�P�'���N~JN��j���DprAl����j��+��yd��������yb�%P�'Ag��.�/�z�	���y�����=�U�-�w$����w�F$��d�5q$A�y(8�7Y�
(���z=�]�?�,2�H/Z��0��x�!p��?Y�,��T�"?/��q	�q��K�^���_������e�mBw�5AӋ���(�ej��O��vv^�L�WC4��5\*?\��`��c�a�y�CZ{t��P��{��+��&�F�ՖK`�Gw�[r�W���->�����w��M�����`޾����˗'�\e�3�V�u��D�>| ��
Ɣ�PdK0s�^�t��/�)\�%%��M��n�OȒcl�U�z)Q3�nxP�p�^����#_�p�7����9=���|�}��`�'Wg|�;(uo�aⲓŧ�_�Iq��M�}��ӷ��|W�`�pg�l��#�7ZI0��R����}�ca=&�2{{}��;��v!wDo�L�Ns����W�N�D1;�?��x4�>���rj��Vi�F.f�OD�Ë��11��6��G�OΥ�W�fN���k7��ɻ�v�$���G�����2��lmF��KQt�|��Y1Y�6V$��
.�͇qS�;���	�����˗W|GL�#����Pï6��/���3p�g�.��׵ �2��~q���y~�(�@[,?�?P��g˪�S!�j�]u��3g���al5�`3"��B��k ��7~=.P v�.�w���O�p�6���*G������gG���p��٬��  7��z�H.b:T>������aD�ݏ�T/h�q"�
������%׭�K��p躼\�y9����ۇ�}���N�9���w9趛�'�(�9�{�y�
�(U��w���Hwت	�1����tu���;Z��t�g����.�X�?���2��jU�3 �
�r:��߬A��o�h쳣�Y�R�zUp��_Ζ�]*�@�Yv�斣�Z���=��H�2�hD
�}�jh�p��f>`�\.V����I�� 5Evu�'��kV賣ˣ��Yr?w�KI��vG(7�Ϳ�����\.�;���{�E���ECR���
��7�Ӈ����b�{GH\���*eJ���l_(�U��H��W��gL�dw��]����ʏ�Жb�	��Տ?4X�w��f�a9�?��@��qu���2�-1o+5�����&�o��l"������6x��5y����U�F�vK���JSrinw��,4�@�e��MXLr	kQ%_;:.��@J4.����KGsz"���\ݳ��Yr�-��m�@�|�B!��G��^�U�����f��\�����\���
�y�/~�ߡ�go���ݛ�GR�p%����<��@q��7J�S#��j��Lц5F�jpK�3��	��ykLJ��硶��F�D�- *b�Čc$e���;S�)��Cb�
�B�^�G	�>��q��ÛSpv��6�H$�V� ����-V^ ߞ��og���b��5J2؈���9�p�f�����e�Be&~���3�c>v>� ��}~J��E�y_�(�}iP���5� ���i1P7G?�e�_�Ѥ�I
M�f�S��|6[��|�w`�~����	��S0Zg�3�\�3Q����=�TgR4����������s���'-��%HP�n�<�}6Ӝ��e	NЩ=Z��gTt��^Si|/إ���\p[X��$8����*P|/��>;�R��/7V�F�lԋ���1��}�ɫ��r��K>�e�{�O�O9n (H��|B��O���/�3�/A�]%�o�#L��D)��9�3p
�^vf�%��9>���o0PXtuy��*�e�VR��c�3��ϟ��\���)A[�*����b왻�rqz6q�b�&J�㒘������C��}AP�.������b1_/~-g�6���^����D��a-
A�-� :�!�CdHo�p�u�b7��K���x~�2�He�)ej��NKv�Lm����d�1Po��.ϲ��4GZ�}��2X���'��2?[��!���{ N����[���k�����`��EV���U
�KdƢ�����Px�D    �5_Z)SHvH��*�G&����#c0kǺ8��U���JQ���NP��#��n�.���@��Ë*����f
dp���b������l]�s�����}��<
���j�Ŋ&��GuFW�t_���0��$���(��R-h�	���>�u]P��[|�)R/V���QڤL�;���":�R�8�uuC�_N��lMVP���H�O�1]����Zu��&"{QR�50��aQ�E]-���.�����2��(�����]���#gn���n��d;[P�A����������,�\VZ�����x�`����S9�����V�*���f��zv�X.���������h�����W�>-h=��п�TRY{Ý���R0eG���G����ޜ��\��l���\ ������v1[������%��t5C]D���/�1�L�k��|�N!�c�Q�U�+������o�TX��HL��.�:P��n�b�1Q.?�[��Xޑu�s@*?�E�����\����_j��tq�#n? ��%��ĉn�q5aR�� �4��1��߆���G��$[�|����?�z�k�����]s���_��p�M���`�Vu�
x ����,�*��&ח���ۢ��2/U��l�tB��'E���U�<�L��+le`����F�5H��~Io����F���G'���v�W2�#6����������͚�c�����%�3����q��,�$fBxzt�ŗ[P�Ub�1x��������d1�W��)��2�k� /+�bLx�����w���|{u�w��`�K�&p�Gs�[��f��"[����vr]���Ḱ��Iqu��>:?}δv�T�:;B��&���rF`9��*f�?���8���2��������T�j�Q/���j�&He]��ы�َ`���\ߚ	����f�
[]���O��l�.���uy��|��pG�M�3D��K�Xd~�ٷ���_�6�9�����\Q��Y~�[8�H�2n@+�KU�؇��:F�14��Xvz����5"*�-��|�?l�
o"�����S��,(���r� ?���{�[%wĝ��0Lј�;\�z C¢��0��������
�պ����i���_�_��l�� ��\�\� l�@��R�\F����͢E���e5^DS�^˂��d�e�2�M�@3e'�5��j��$��,�/j:������t�\��i[GD�^y��N�c���0VDĹ�i�������5�虇Z�2�L���лPWS&B��y�<A�Dj�zJ��&1 ٳ5�c��&��.R]�}�D{�;[7	�9�^֖I'����1n4���v��U͋�\$��M��� M��"��^���b!!�`���7�Afο�`�=��x�����֑���s��"ʍ��a�X��K��K����_�N\P�)��_�@*@8A�f��X~��9(�*�����v�d.�\,.�A�U��J��`�?�p�A�+ޯ޾�`�Dv��ܘq,e�^/>={�@��F9��߮� "ȏg?j����${+_��B3����Z.-6#X�"������~E��DG큡�S���`��cD�o`�)��w#'�#
�N�'�Ec�8v�Q3���~p��3����WztgHD�F`!i�A�o���z���8�.fH��ڝ��A]e��aX�HrL)�]�L��RQ�x)��k�����}��>`����jb���M�N�v��qX}q���+�`v&���Uy��G*4�լ��)���͈��0�h�$��	��w�df�8�օ���=�#;BG���h�U�
Ս��q�
t��(�W��Q�v?�砦$.�<k3��D�*2��_�_�MY,�j���l���u�]n����t��\¯t .����� �|v]w�̛!=Yx*�F�5`�i%r<7P,����������K.о5����R�
���mq�،����r�Z=�JmNo�_��)��:�jBQ�8j����7��+!�,�Ưn�;�9Z��}�F);_ߕ��l�a���.�x����7��o�+���Qv���p*G�e,�t�Q|=�����v���'~�KT0�c9w����a��;p��xز.]J廑���+N�A�����S��60�,QS=՘�a{c$Cr����p��!-�c@���:H9z K�}��be�J��9Wv������p��p�}ZO�A�$���ւ�t[���1i�e�/�n%c�1/�:����i,3練��'1A����kj��M���W� x9fhN�X-uî�d�U��5��Y2���i~3�<9����!V���@�B)�/��\�~�_�g;���^�gI�$��9�.�A�bW'�a��Р@�~��dE�F�>s��U�:��v�ʄ���c�H�e̓U��|G&�FE�襏��e��K��]���J`�ʈ�=`1��4���i%PE]в����k�:#P��8=��d�2��K����23�p�E��*�h�b��]����$���E	�{
�Z�5&�r���#�;���E��h���\�T�Hw��V�����<Z�B�f����u
LP�ȀĐ�yrũ5�<�3}��L{a�+p�;��w�����V�6?V��K;�VpsrP���H�yLA���0���+g�jM�Z�ш�:v���\�U{Z��p��.��a�7x��=&_�M�m]���"2��-糍d�tQ��4�h��S�Q�N�:8̦��k�w�&�L4����GW#*[�E�EJ�F�E}��ժ6g>��m��
V�3g:I�=�N�X��68W�����ԞH]5PCjL�|��D%|5�P^��x5��3M�TQ�b"tܙ&>���W�:� �2���k�����9��=���%�C5���<:l��ּ$��\p���G�����[)�Qɏ��o�k�oi#z�9�dv�fd
�!��q�:)^�\�F2�k������6MA�ઠE�f&����@]3�4*��2tc�kp�Cketbbc�-U��2�K�wP��u�!Ѱ>em\�(��1�*������!�g�\$���|�q�ij����i�]���&�U	�����ZL��b��4ı���<�����h.����2Yt��b�����X�:��
<�E��],�F�oM����Q��䟀�\ �����sӂ���.�`����4x.qv���"�����F�q8%Y�>pA��G7k��Fe��u_��>� bHy�Fm��39*:H�ϖJ,�zmծ�$�|O�lU-Җf��������}p�� �U��S�d]���a�X�	B$�T�i��C#hDr3�6IE��A�1g�h�4�m|�0k�2^M���
]|VT�!���;Dr��"��;�z��+�؁ww��3�M|�z-��x�3�UP��$���%�o��E�t4_{���o�Ny��R��ep���8�F��k3J�F[����;Jig��Z?�k�&��5��"��?��u��Ji~�7t��?/����_�[/�ԙsp®�D����7��߁>(s�'ِ���͎��p%{۠�ohƍ���%Q{@���bI١��7�V�E�a���'���+��K�m��N�S7�T�o�弫��_�"+s���7�Ĳ���XN�e�2��������c��<��<$?
�<���b1mN�Uq&Է9u8�ȉ��O��h�KctZ�cג4f�t�̍�Gf�{FJn�f1��k�v�hF��A���c�qȳ�~���Y����_��n~4|멳Rc��y��p�	8�[������ T����"䧳O����P6p-q�P/r�Z���p�|��M��d��w�O����3����8,L�#�4NuO�\F��=��}#Mꈕ�w����P�"�zts�I��E����?É��1����w��E8�{r��}�T�?G�x��C��ViWЋ���K0XP>�c�2��Ǳ�����G*��ia}��w��r�
T��?@��?��D#����՘"���:&&@��z�����;���� �8�{S4I�0�!    +��$�6�p�}ងԱA�C:c���+���\�� o�#���}։�h�Lz�hp��Y4e��l�|lj �.v��4B�"���Q��!��𐠁������-^'�1��|fp����N��\"����|]O-�0�g=˴����.\`�Ft>4�Ĉd�_J�w�Y c2V���FE/�a� �
#���O�����~{�7u���?�D�y	������Y�g��:�
��']�_N�n��w.��1�o5�Dus�t��4�QxTc�T7p#����e��qכh~��c��2v��D�5p��Q-�rC;�)�4�f>�)c��
����s_p�v>�rvR-���"�y�{�\>s�Mٔ�[M���`o�� �tE��n�~�pQ���0�){��FI��_rpՖ�[�Fצd�$;MU�X�t�h~#[E�!S���Θ6�V��.����C.J���Qׅ��UbG��+�q�\��
%����]�d�)	��#8)1�q��c�bk���n��.���M�/�,�#\D����������>�?;�\��q�����,CL��yBǀ4�3^��d�&�:U@Eph�̀"���nZ�� �u[+q�b����~���W�J���7��ci�#,��4r照F�%.Fi�v���{�T�;��U�̾�$4��*����x����_^.��B�q�c,��myb71k$ݎ�����˘�a٩D�To�w<��S��GU-�K[�n�e�N���b邿���ۃ�xo�P~({LS]]g�I@S�s<R`X�rR.��k�ߔ����Gv$�6��w���h�\IM��̗Ǣ@�20���Ǡ}r	H�X��ڲoBԺ~:J��2Eo��I�<e0�Hi]��NK2I�j],Ē��uX�X8 ���pLO:�ۡ���SO����:���~�#Q�c�oܰ.�kߏ�R�s���!QN{pۘ��ʙ�{��V+&5�����i��I2<��`�m��7�N	#�<�L�cwW�c��PR~�<�1ͫ7;h����u�R�C8��u�T��bY`��� �1�h%�?� �K#qyG+q�MR��s�������wI�i2~a����s�����vF��[����ɍڮaL���^��T��@�8�?kFz\�	�+`��sf��/�=��A�#;������"YL���.)Gm��t�YK��Agn��m��o̚5c�����跈��0�=N���M�����y�T���ۑRu����6:���p��d��K�Ӌ}�T��P������h�*�=�{��3�Ϋ7��I5\�Zx�|	�0�+D���03�������X�����{	�\���]��~{�	L]���(��8��
��dx0٩^�"�M2M&��.-��4�!���k'8앛X,C��~�/��k�#Qi����F9p5��?��㱰��R�A��ZP�W�/_3��?N�s�{�p��� �1D��Z��\��٫���0�QM?�2%������:��(Yw��d�(��.2J�k�h��6��-�Z��y��hV%;�!;5{V���l���ۛ��e�o��ֱ]�ajhH����X"��o�1A��{�$���tu��N`�@ݚ�g�=��x�㫥̢3XE9�.xQ���>P�W��D��.�`��� 3yƾ�*9|��1B��GII�����A��a�>��axSObs\XvX�8dV�5k����C"4��l�X���Fs�c���.X�$����4�8�}���q������J>���d*L�>��8�}h24^�	����Z2�X�qL��[��8p�t2��+�5A��C�yκ	H��(E�&�^13#@�c���Z�͒�����ݸ.�C��d���w�3����R�m��[3��է�Jw�q<�E�lp�ip���GA]�R�����r�G�<qF�<�s���T�H|*��}�D��}�7٢������u��k,j챴�������"#u�F-_,����9����Cբ-To>����g_����)ۢ�� ����Q���d�:r��W��r�0^%�-�����s�K�� �����>q��#�Y�@\�6~�M�-�c���Q�00	h��=����.��ܥ�c����&��Nz�B��Z�UÝL���Aj�_�I�]�/V54�ѭh�a|��r��T�s�c�"����>XPP`0���������x�Lp����H�ZC�D;�-R����F�,2;b�~����c[�Dׂ�|wv~���n�t\�����t:]���u���Y��𪚭��4�A��ù�C���z�EJ��y4j(�`�"��J?
��F�B����#4�p$� B/���V�>��g�9/�J�XYԭ���d�l�&I���ZM-��8�E�'�@����X���IF�BG�}�5��3?g�
�XƐg�T��$���8?���I��݈��=�}�;[��Z��7���/�̾�o��#��o@{fo3�- ����X	z���˵��.p��$ �,�l7�
b�Ѡ�岺�Mο�������6l��2��z���N�>�.w�D궠���|Ʀ��2>�@���R�t=;�e�90*��=�`��LC��Sa�(s�/��48ڂ���P��7��!�P_ZF�hc��h%�ZX�U���12xL �(MpMG�𔬛��������:��g�\��m���Mx��ƹ�g/���D�ۡ��ō1WȂ4����I܃��Z�;Ϫ~c`!	E�xZ,�8 maU3@��#0��7'F� c��☟�/tq�Pw���:�9?V�^�����Vћ���,x��� ��A�+�3BS�բǝ������t�mؓ�uu�{��B�����ɂgtt���٩�K�P��~��7ˏ�	�l �ّ�E�+�h�"$�{�&=
��m�Y±rui55��V7�*]��4�o����^��o�(�����-��s�"(��4�ނ��@�ſ8 S��&���$Ba��ܬ�	t���4�
�o#dt9$�X&�6ZS����"�ށ;��X#z�P�t�}A���Ď�J��_��A�Т�i�c��e�����8t���1�s9�Nך�yyOEL�"�L��ܥź��#�3���Xc{=�Fp�(��P��И�q���0�K#���	M���#��ҋ��z"��ThM�\���������,�da�m$�&��c�ѕ"s�� t��	��q�񬡕uS�ڇ�)	�b��:��!HoM�'5+�s�k�)�/u:b0�0vJg��^'jj��4��N�8�����cv��n��$V�*��[pGҘ�c�M�sqHL SPd��%-J'ӱY�Ɣ��a���GQelDU8�k:pX�)&�/(RrE/2�N�5�U��BvM)2ش���Z@i���^/���}"�֮�]����Xv#���ny�!�6.Ӧ"�O�CSdN���AQ����Qs�[Q�L��ݥ�DQ�{�5E�2�5"��P�Ē�1jԭk��m��{�����X��:�%��b~�.����=5�t��ТD�zr�8�{�Q��A��Y�=��pp��Zp���͔k�rY���RO�zYӓ�QAI�}#J�WuqJ������t��6�7-��)�����6`�� X�8}�,��b{M*�������X��M]q���X�j.״���^�a��@Z�y��ו�����zt��^�;�VG{��i�$C��-rs��)��P%�SN+q��'�DZ�ψ���U�̼(�4c g�R�m��-���FfV�����݁Q�м.��!S	�����(�������`�"���P��1A=d_��)��=G��X/^��`�4�1P�
Jќn|9q���4�����K,�0��Ւk��$o�3��6BK'q@�o'���K�j���%��g�����h�B�Ț�8�	t�H�{��R&���,0�0�EqŶ&���N���J�҃4�+�y�/��J	߹�5d6�+t�O�3%�Nw��+L���[p�u�e�F�s\    �� �),~MBC�Dq p8뜆��m�ľӄ9)p���CX���:=>�R�Ԉ{�J���R]���C~r_��_��W�P-1���
���][�P��/�0�,R�>;������Q'���N���ͯ�He�B�O�}�M���Kq��]X�2_4�6�̊����p�,�G�C�胵&ܜ�5w���У/����p'TZ�8sj�et3����Uoo�n4�a�z�$('���*�mc�$���wp����9-<�B��K�/.����O���C�����V'|Z���{jj)}�
Z:��щf���wFP1��!(P�@��2�X��+�ǫ�pR��9c<�b�!v��:��;��d�9�:p=ԃ/��&r�C��K-]�(�@���d��[�i�v��\px���D�S�m�i|��e2gF���];�=�v�3��Z����h����hh�ƫ�p����N�o�E,���X5��,CMh�.t�Ƨ�i���b�N5�8.V�^�!!,7��r|��������>���ޚ�P8��Jl�cpĄ�A7hu�Bd�Yv�*�>�(��1��m�VR� �G�}EKk��Z�N���hmpsǰ��W��ͫ䁒��'cF��~8�<}��=���?0m�¼U9�],f+�U?�3Lv�PX>������
t���oF��p
,�ӓ�Xvj���yv�<�z��]�eʴd�D�F������L
���z�j(Mr�;�r������)zbi0��96���R���U��8.��u�{����O��P��H�:�#��bS�ς8�iZ�#�^׹��t|P��q�y�*��;L��y�4r�pgY���}eβ�����b���.}_�q8j�ݛCӃN�^�Xt!���hZ?()p0 ��T�<�&cK�ȲF�I�X74%F��&��D��䌨+�vĥe
�u�*���|s ��14�$��o
,���˿o�2;ߓa��-�3���@�b޸�pΘ�D��e�����b�7�#�ߜ�]3�!;u��N8�#�o>���_�͏+��+��7�+|��9i?�*���A���j�%�vU%{�����Gw�e��+�tn��i������8����|;[�]1��v���Ʉ�'�6�8+ҁȜ3K%�f�'X�;� /ge�IS��i����N�J��n�e�ݏJ�*���h��]g�?�?�M��?�5�D-+�!!I#�Z�~p�@�I�-=�p2=?a�m`h�������󽨱W��%�|��' �{�u6��C�K�B�+1���\�M�K7�W��!��<���y�ȉRĶ9�o���S��D�z�Ș�/�a>�k
�|r�S�h^.t�B&��)�ǟ#���L��J�����܅�9�!v�t�\3��y���MH��b���ӵZ�=�-�Mr���T��G���/n�dݯ����g�`zhk����q�%�����A���1ńH��Q�����|�~�_��ߍ�y��X���'� �?�@�!��
�����d��S�P��7�E:��%��0ՠ�͆�>�zY?n�'�}��b����Wi�}˵#��K�]�TY1�v�iۇL�vV���ڰ������ݟ��� �?=��m!���5
�9l����^.�{T���6�)�/[g���F��$U��3^�
G��H ��9OQYk*<>ȵ��?�vف�(�3��P��O�5�7��b��(~~(j�a� ���;N�&��$���F1�F�X���*d=�S<��l���r0����zˎ��ĉ¦*3��M��Xҏ�l��X��Ø!��r�>֜b�����`�jO�˝s�%YǶ�oV�\�����y�B���
8�u��0����f��0}W�V��vع���q#��ً��T-6���b�N�����
���`<�[;���c�8=�*��Cq�<����1hjN�sm��ɒ�?�}6����:C�#�;Z�����+�(��;�<��5���u���͔���Cۧ}��	K��T�d��~7k�F��1�IG�����]j�=��f"V(�#y[x��G5�F��#���ZD��~�K5�Q�W'<��إ��A2`��w��\H7[g��{���K>O����/G�\���}�,V���� ���y�퉲��y��kT�y���EtL���
�h���v(�����cN��m�����;E㟇�na�У��zb��)0ߎ/g�zf�U�#�&���{�j�Bm�&���8Ua'p�:8��" ��a�c��0�����z`a1�"�}=6Э+��aWc�M�W�H3�s9���@�G�#4��,>��O {8��R�݇F����J���/�D7m{��!+KO�~����Mp�����i����Hj�$��D]�"��&/-)��#h��E�~�� 8�,�d�m`�#O�p���%^���'p��ru��.�t�xٔN�N�Y1�h4���HN=�'{��ip"Vt����J�㑓$E��o�M�T�G�8_��>�C�
��������Ru�sZ*E���ڽ��)�=����|�S6u������KK�X�z���|r�GD�q�=,��x��|��S0�2���}>�p�����b��z��-J�ޏ��B�5�.�-��_�:g_�(%��}���b�oa�͢��N"eL� ����kY�L��A2�1�1f�y8���v��]��*u(�Ӻ.����4H����m��N0����'�Ĕ��	0�o��I~Zy6�+n���d����ВSh��'2��4z��'W����)�ˢ<������uu�����Џլ��G�hr�����g�Y��Q���~��$D�|=S��Л��)bQm��*^�X�ތ����l�qJ�-��o��`��~��ʴȚ�Ɓ#�fp&��y�;�^v���3
=����I)8����p�~��%����O��,G���+�E`s}0g�=�n�#+��5��q��p���{$n��.�����+��Ցi�����p�X����|J�$MU�9o��N7���
���*�rj��)0�ϋx
���D��'��}�:��dӫx�_oo2l�A�	5��K[�6z۔��mP�)1m+h�M/%�6yj�վ;<VG�[��o���V��'��Q�b�I�-����2�Wh������ _�Z�E{����Oa�6q�3rߑ'P��#�I�1�{��s	����e�C�@c�G+`�8����f|�9�����vE]�������ux���&1
a�(���z�Q �2��;Y��h��ŧ���yѷ#��Y�1u��U�CG\z��׶�&��2~��L�
�^��'ˉr#h,�%�q��5P�+ ��F���K?
G][{PF%.y ����+�z�Y|�f�~��E����>�����7��/�Ԑ��<q�	^)�ސܐu"tG�Zu?�f����A��E	Î3Հ	��X��>��K�XF�G���_q��ރKY�P�4Q�Y����S�>9N��[>��Yۖ3�@��F�+�.����s~�;p�*�IΗ�%�<R��Ŋ�����2F���l��?Q9)L��V�ż�d5p������@-|*�!u��C�u8dG������?)�8>
��`��P�b�8���VB�v��!>���(\+Hޗ�W`��ڗ��_OC�,(��e,�vSoc�A�OCbo
�6q�Znk��>4Ja[�C�~{|+���cjaXD�^Е�y=�����&��lA��M���gW'�G�L^%s$�c|�����W,d9Z��.��"?_ߕ��l�a����,����+��L�j�����?`�C����"��8�⛔�`�E�o��J�V���5b+��B�<�@S�%��|�N(����/����f�x��h:wT�(�#�
�R�q�ջa����uP�B V�.�[��o���Ѥ���͵Ж��4"i�����Ttgw��X;�0���p�c��N�Pj�V4&}�z�P4o��=�1���p�AEI~I�>�x�<� ���d�v�>(� q  ?�o7�������+*pZ�h�4�����>��[��i���A$�?47�E�~lE��7��F���yC/�s��>�9�Xs�Ζ��8�c�����*lD��8����p:����`����&�D�=�4M���M��[�#3�`G�'L�^	X�R�$aĲ&�k��[$�cf�x�q���� �w�:��,v%2V'���o��_ii@�(�f�h��Y"e1��h5H�癴Z��m��t=\���P���H��ݰ14�Q
e�]��X�	��f����������ū�*�?[�G�;J�؜x=2��%9bl.��'#</��jX�C ���5nf{�_��7 q��(�נ�I�;�6Ujb��Q�Dv�k�L�Ňd��`�ṧ�����#���Q��1��!(���6���\�(�w~�dP�w�?�K�/��1��9q�}��`�&����.;ra��R4�g��TP��QL�uׯ�b58�U=$�T�{"�>8+��U�'2�b���8��O�Rt���T?�Y������{ТBv�/ ������vuA�ϐ��8�ld��!/��|�J�K~2]ނc�ժ����\���A�P$zhQ��o���X���4DNock^ �<�"��r��q��<�i׮>�)E���:@������ʣPqx�[ѡ��sN㼗�D���|[�$��7Ì�����a��QG��ؿ9�_2��ɶ���4���d���c�	ѧT���@��H���.9����.�Z�\��:�F����U��0�n���No�X3F�@�3K;��TuZ�0Ⱥ�Mj�4�I���$���~��d0������i�#��������-��Ϸ9"+���������g�ǋ9[��{>�g0^1��ơ��_�g;2�)���$��m�`k���rv_n�*���i���{`��O9r��b��Orl���/����m>�qɺN��Dn�$Fc=M��%�M�ώA���}3PO8�v`�O���9�I�F�&4?'�>~{u�&�ܴ���Nb��,>���\���/kX���Ŝq$���!���R�@y>��)H}�F5�ruqq�D5������ï�[젚�0&%I@p�7���� =���o�wpE=�/p��"��y>g$�����.X)ңR`������s�{��]�*� /p�Tn��S;�A�8"���1�d���ݨ�!���iA牆�]h�u�)Ң��qh�k����6��"�d
�b綼U��B���2X{>�]u�.�{�dݾ �k`�\ ��&�>��� P��� u���k.J�!3�űK�/z�Њ�I�,IU��������"� SFc�z���Uodޣ�4~	߃ч��|�Z��ٔ�S!������^ʣh�G
���CdM~z|�Q����	���Ĵ�wt����2��;����}or�cpTUevu�S�(��ÿ徕ƎR,yo�wE�"%��b�">��@ⷫ� ��������a]�ChW����p��������uX=�I�c�a���2��>��qb����E����볓L�b��@
�m���-�i��[P�)�ZqR���+�	�#&@��5[������ع�O�WW�'�h{):�1&�T+~������_�\���.1��6��\�d#�xӶ���΅�"���%��� �k�(�X`]��� 4�'n2d�&��;�#3����@S�cZjZ�P ����i	���Ć�h�����}o0M]�,�`�#�6�T�H���G�L����ʃ� �eo��.�����MՒ,$�z���^��٪|_����{�����q��[����$�!2] _��������><F�p̫��1'��C����W�1�X*~xv�\Θ�ߑ�5I���^�}!ce�]��:����iiH�N�^OG�h^h##���S7ʐb5�Tu���#�N�˝J�J�Y~9��&����·��EcǷ$L5&��l�!C�i"���XE������/k�r�8L"]�3c �]G_7��=0T,�ܚ1��8�-;J�T����������"�!�t�Z�#2��W��&������$E���'��5�=R%�����۸	妌��q��AU7 ��H��:h�&7�i̖� 4S�0i���8S$���0	8�?O����v��?�}�s�>��&9��o7V�`��Y~�N��K*`}�fyl���1�tq{q|ʡyL��ӒIF%�K� ��q>����@sG�z���9%7 �
h���Ш9��������_{wQ��^�!�_��	w����&�(��`c����F3P��h�a��ҍ ȶ~{b�rSdz�V�#������$�E�&�ɠif ���{�(5�X����=�>x����r��o���\���&�Kx�}C����U�`1s&�Us9D�b�W�]p<&-$F#X�E�ڑO��ux5`��\ �8,Z����F-��J��h$����|c9	ڂ�|���+�5�ث�|Z��f����gG�`�&��+b
7k �pcִ��� �G�I��Ȅ�D����"�<ܹ�MO��h:�tI��������T�V�I�����)zU���y)��X�!Y��V�>)=YwQ�4�ke}tux--=T:
3�~A>	\�8���� L��^��Ȣ��%����������Q�m�"�Znp�W�6�ç�^j=�4��,��X}u��0.���~���.��dHE�ԯ��r}�ϰ��}F��*UQ�T
�z���%�7�\.���`��T�>f�PxI<��zj��Ƴ�#���dԷ+EQOA�1s�9��T㠅�ˇ�p+�\2�q�&�~��dV�����F{���1,��ϓ�j��(�ݼ�85Z%����/�`"��U9���Γ�}0R�X|�m���V��n���ġLݺ�#�,ʈd}���`َ9�ۘ�գ�f��PC��>j�Ra&X޾<pG��ۙm1��%(��vv@�\���
�Y�M��4&G���)b���'E@���'vW�7��<��� ����w\�Z|�	<�{ 1u<mGJ���ݰ0Z;�\?�o=�Û���5.�)�E[c�����?��?�?m���      �   M  x��PAR�0<'���Z�&-Co����NƍE�����L�t�w�Μ,iw���Y���L?���*���x(�E!*GW�]$4�rZ�N�	b���NbR,�QXu��H�x�,�x�V�\4��y��h��+Ɔ?[n,�~�d�t��[�Wz���� �=8q��cPd�ƚ��Q�^�]m)_���Jn��n]5E]���i��y�{jr�I�dT�����81� lZ5E�vTnZQ�����,�lc��q��#Y���� �k�l��I|X��\u��@l�j��pF�c֪�A��5N��<���������3�M��������i��      �   ;  x�uWMs�8=ÿ�9�%��:z�co��D�٪��@$L�� -?;fj�rعo�47��}���)WR�e��ݯ_�n�l����,d�o�����:�,Z��bᙠ����L������/���F�쒅�L$8��;�J�~m�=�0�?�I���h��#�9��Y�_�ޚ:��O��k%;k4<��s\���'�vL�D�Βo������[����g�DD��@�)�j�)w?��N��j�W�޷J�,��Ώ�� cq��n�F�v�>��4��i52�Wt��+B�l�����Ep�x\g9��m��lm����
u���" �����n����(~����.$��łW��e��r�>?�C+q2�W��+��;
鯿<�σ�,�i%U+�Q�kwm $	~���b<}+M�U��7��ˮ����E�,�	����>g�\�Z� b|M@�1{���=�� 9�ID�1���^)�@��^�FxƊ��yz��Sv/��,� �s��6aĉG�U\�ht���Ѓo0��k���G�s������5�AW
Pg�:��� (�)�%{P��;�W[[�F� ��A���vE�Z�r�K�X��-�dK�^��[��d#K����~����h�}���حk�w
�pO>GD�Υ`WC��G�]��עV���V�%�v%8%� щ�V{�9���LNh��p>ÓD�~���ߺ^�	������]H�"�b*�a%��p�������W��)�G���s\5��(ɘe�UGuՀ���$2;M?���[1����Fa���"c�bk�Js����$'�#�=�q,Y��]����� 9�֭z�6��t
�Vc�I J�S� ���GUTۮGO����s�)K��{�����!:+;�!@���]6�O��*��:)�.���$ȗ�a\�gЖ+�V�|A��A5�X�6En&>M�;�Vv�l��"
�Ѷ���w���0%yE��[J�T����aH��o��Zv�d_l�E�j��9�s6	[�J5���-�=���ϛ��id�٨���f~���{!�qz`Fs�Y���/�"�wSJ$J���8��A4J�F#_�0vF��⨂"��loI���[5t�?��m3�W|�x[�u:	( �(C�0�6��EI��ń�S�0�����8d�E��S��O�1%_5rG���T���d
:z/�4a�<E��k0Q�-���u�1.�$�U�pL��O��;$�؇���}|��C��	d|�Pᴮ��ǷP�����O0�B-�ܘ�ŇO�R�J���$��~,Q��(�O�l�W�:���,K���+q��)���U5Ԉ��o��s��M�0M�$��
4�A�P �n�]C��Fb�@��IΏ�s�H����_dS[Ms��FJov��G��fw�L|HB�1Oz7��=�b�w<��JA�OX�Dcg9[�.u3.}1��t.��>��cL�� ��-)�;Hi��7A>+_B�������V�}Jw���/�C������buӝ?��q-�� -I�O0S�-`�K͍5Fr�`A�S}��'7>G�2�I>�&b��Tc߱
��{�9��D��}�)V�2��:w��n�Jg=J��������`TB���gO�}�i��4=�@��ܩ�۞�k�v<&sM[;������F잗?~��@v0��q�8Y�D�t=�J���d��,Zg�5F7/���s�_T��y�w��Vo
-u3կ�4��4��?�n�e�W��>4����MZ:��:c9,�m�X<p����5�2��/`��$����0�Cd�7�_L�E��Et�z��#�w����������i�n�P����NO�el�I��1��������XSm�?m�s�����͡����z�u�l�yd�v"T4n4� ��q�7� �)�q���tB6�J����j�����WS�'`3l��٪r����x(��C:�x��hg+�5:T�'�>t��KA�#���|�~T�=z���  �؏3�8��hk�:���v��bbBc$�F�t�=���u-]�o�&���,��I6u}��������4�#��������"���:>��)5�_�����r�      �   ,   x�3�tM,.I-��2�O���9��J2@L���R3F��� _�!      �   �   x�M��
�0F�{�"����j3
*���%��6XJH��-(��[�w8|b����J�K�)�D$]m5h���^4�{��W��Ρ����$�S��.��P�q�b�;�*�hY+%�1RU���m�j�����z��$�V��"~ �{+�      �   �  x��W�n�J]��� ��>Erv��ȉ�ǵd�"�RGT�n7)G�� �,&�Y�N?6�)�V��5[MR]]��SثϺ�埍,-;�rS�t��Bv՘bʭT:�Op)�i ��05�j��*�b/ث���	{�^ipHI�tB���/�Bv!���T�+K��S��DTr2�-MEU��3�Ҕ�P��K%mmx�q�ң��Li�G��^l�c�){?�!��ob��&��q��������^���r��W�N�\�Z�]��T�����؈W�ҵXa��y-�aR��|�MIץ�zJQόq��7,�?�!
���4Jv�Q����ӳ��w�#Q����T��p+�9�.�y'����9�8��xX��n�q9"i��/�b/|����d�}�6uYp*���-�+��p{�lj����n8�A#Η�4}��(��9n�qO_k�+���R�R���#�eQ��)-�Ĺ� ��]J�����v����~�˩�;����63M��Fwf��|��vI�<B�=�8
:i����Cz��SA��T%�J q+Ƈ�Ӻ^������{o.�����B�_�֖b������Xؗ�v;oZ���Rvŗ�^�#�h�7�u���៩d;��c�k�-�
B����(�ndp%g��d��8�+,ۺ�q�	�8zZu�,sHf�Y�W5H$m���n�t%j��VVD}��Ü�pL t�W8�*����.�i�@��ֈ�mK���>����b&�f���^�����}�ٛ ;��%:�P��Q0h�u�8�.Z�^�B15̳��	ʹ��]c�>8{�D
�ro.�,���ồ�Rf�D�/������?}+�,�qXMW��������"+d�I��n�o��N!a4Z�o����h0��? ����{5�u���Ia&��B���
JX_�Ά�i���0s�V�w U��,N���!�����;c�2���jb���|��̠㽁K�S_`�7
%Q(�V �,㱾F��q����N��S�h]?���tsw�0Mw�����6�B�\@m;���F[O��-*;A�V.� 9-����9�;SB�A%z����M׺̦s#J�1Arv�|�B�Z��4N��L�4Dٳ4�vq�̰��O&�� ���g��c�*�(�n��Q�p��҄]��1g#>{S�ʅGR׏��i�%�}y}��ll-HLv&�\����N�����,�!�)�+��8�nL�r#�A�n�{����<����벾��i]S߈{ʍ¬*�Ū�-8m۫W�Q���cQ��ԡ��R�6�@H��[��*��5���6��[������`��vF�O�w���\�	`B}\4!p}��*�\s��sT�b6��|#<A�Ax��'F��N�?�'��'��Z�0��04�j�%�B��7��~tD׍sKK�Y����������E�4�1B�������"���n��:lϔ�s�+5�PAX#GeJ�R����1pP�[$+�뻇�ly3l]���Z�D,`O(��
!�\
#�_-K'S;�1?��������e���:j(f��w�1b�T+�]d��ʍ�i��#�	l���V����!�k3�p0�I�{�E�`�sf��+5���Jv!!O��sY��#����fh���N+�x"�bq��q�g�A���9-��X�a��b�N��Ѱ)��`[�w	x#�Yҵ���ń����m�?���A5�� �OaTHg᷇�`�f6��rs��S!g3��4j[6E�S�����aՋ�
�כ1*
P��R����1��� o�%_a;dv��H�<���d$��^�����F_:m�!�)\V�J%V�bt��xw��p;P�P��U����4�a�&�`�9��8P�@=��t��[�ot@u�拣�o��]�e���q;ת6��b4��cQ���-���iz�[��^��P[s�ջ�2�3��@6�,䳯Kp��A�kw㈂$j�cT;�d��dp�n��n��*mO��W��f�k�k��7�]�_�
����Gd éG7Z�@(��V��<]�xI�D��0�:����"�휟�V[����s�ݧhӉl�Z@����)��1b�yi��3��>}N�9:̝����D˃�w��U�p�tS��9:q��Ɠ֊P���R�#��6Q:�~�{�c��]��������?E��      �   C  x�U�ˎ�0E��W�
�l��&�Z4m0`P��Vad1���ӯ/e��.���%o�w7�=&^1�%����Y)��a:���B�-�p�);X�q��pt1
V����[H�$l^��b?#�T/��@�4��S�F��SA��4��p�����S�T�6#c����Osg�w���Ꟙ> ��k�a�B��P��J5��Og*]@�����;�p>yK��NsY����L#���2�Z�|�4l��>
�pN���":��1\�=eT�dR��5�b-����hO�t�#Q��E˖ix�㹄+&��ox�ӿ��V����@]���b�|��,�0����{�.�M�%\�i%�
���^�P겛F*zx����HL���[j����������tHe���hc�8e���8����{{D�Z�rM.Җ�|�ҍ�
lv*�h���e�>�4������%J`XǺ�-&;`�;'���iW�Jt����h8�z�y,U�#K��F�@r��#�뭥�)�/q�S���S_Z��L���.j���[����l�,]�dX1�����-��F�ì9��yn�ח���A��      �   Z  x�E�ݎ�@���O�l�ǿK�3#��DY7{�=��'�8���[H#		�WEq�N���b���aԥ.n�̉�
Ri"-�)I�����ȉI����n��U�Si) M� T�ҬP�M	I��Z����a�+ve�c�Ԣ9��Z��P}����A�avFx�Ң`x�;^��GJ{	:�bI���2j8���
�gQ��GTUB*a�{<F$���(����J{4Ū�j��V\֗�t����c�.�܋�;��1�#~�Sw"�V1Y ^�=�.1cX^^�k�8�=�"/őI�Q}�4k�j�8�蘨1���%o;	�;WM0����u�5޵�sgH����H��h֝�fdG�o���p��_��l�l��{��k�oH^-u�4�?"WHb[ĻӃ�'$��#iZ�L+2�~i���Ȃ�����ao��
�GS���6��?]�x�T�H7V�o\Js��Y��oA�;�M�
>��ݧMd��m3�^��
�]���@�Î7nα������f�~���f%ޭ!�{��d����)������ΐ12Bkj-��ϑ�{�H���A��	�+i�G=c�M���C[���`�U�T�     