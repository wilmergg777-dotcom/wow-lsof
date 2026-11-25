# 🌸 Violetero en PHP + MySQL

La tienda Violetero convertida a **PHP con base de datos MySQL**, lista para
montar en tu VPS o hosting con cPanel. Todo funciona: catálogo con ofertas,
mini tiendas con suscripción, carrito, pedidos, billetera con recargas,
panel de administración y sistema de seguridad.

---

## 🚀 Instalación en el VPS (3 pasos)

### Paso 1: sube los archivos
Sube TODO el contenido de esta carpeta al directorio público de tu VPS
(normalmente `/var/www/html` o `public_html`). Puedes subir el ZIP y
descomprimirlo ahí.

Requisitos del servidor:
- PHP 8.0 o superior (con las extensiones `pdo_mysql`, `gd`, `mbstring` — vienen en casi todos los paneles)
- MySQL 5.7+ o MariaDB 10.3+
- Apache (para que funcione el `.htaccess`) o Nginx

### Paso 2: crea la base de datos
En tu panel (cPanel, VestaCP, phpMyAdmin…) crea:
- Una base de datos, por ejemplo `violetero`
- Un usuario con contraseña y dale TODOS los permisos sobre esa base

¿Prefieres consola? Conéctate a MySQL y ejecuta:
```sql
CREATE DATABASE violetero CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'violetero'@'localhost' IDENTIFIED BY 'TU-CONTRASEÑA';
GRANT ALL PRIVILEGES ON violetero.* TO 'violetero'@'localhost';
FLUSH PRIVILEGES;
```

### Paso 3: configura y abre la web
1. Edita `includes/config.php` y pon tus datos: nombre de la base, usuario y contraseña de MySQL
2. Abre la web en el navegador: `https://tudominio.com/`
3. Te llevará a **install.php**: pulsa el botón de instalar y listo
   (crea las tablas y llena la tienda con datos de ejemplo para que puedas probar todo)

### Después de instalar
- **Borra `install.php`** del servidor (por seguridad)
- Entra como administrador con la cuenta de prueba:
  - Correo: `admin@violetero.cu` · Contraseña: `Violetero2026`
- Ve a **Administración → Datos de cobro** y pon los datos REALES de tu tarjeta
- Ve a **Mi Cuenta → Seguridad** y cambia la contraseña del administrador
- Borra o edita los productos de ejemplo cuando quieras

---

## 👥 Cuentas de prueba (contraseña para todas: `Violetero2026`)

| Cuenta | Correo | Qué hace |
|---|---|---|
| Administrador | admin@violetero.cu | Gestionar todo: pedidos, cobros, recargas, seguridad |
| María la Tiendita | maria@violetero.cu | Vendedora (tienda "Cosas de María") |
| Carlos Repuestos | carlos@violetero.cu | Vendedor (tienda "Repuestos Carlos") |
| Cliente de Prueba | cliente@violetero.cu | Comprar, carrito, billetera |

---

## 🧪 Guion de la primera prueba (10 minutos)

1. **Compra como cliente**: entra con `cliente@violetero.cu`, agrega 2 productos
   al carrito y finaliza el pedido en efectivo.
2. **Compra con transferencia**: otro pedido eligiendo transferencia — verás los
   datos de cobro del administrador. Guarda el ID de la transferencia en el pedido.
3. **Vende como María**: entra con `maria@violetero.cu`, publica un producto
   (sube una foto o elige de la galería incluida), revisa tu venta en
   "Ventas recibidas" y marca el pedido como entregado.
4. **Administra**: entra con `admin@violetero.cu`:
   - Cambia los datos de cobro (pide confirmación y avisa a todos los administradores)
   - Verifica y aprueba una recarga de billetera
   - Revisa el registro de seguridad
5. **Billetera**: como cliente, pide una recarga por transferencia; como admin,
   apruébala y mira cómo sube el saldo.
6. **Suscripción**: como María, paga los 200 CUP al mes con tu saldo.

---

## 🔐 Seguridad incluida

- Contraseñas cifradas con hash moderno (`password_hash`)
- Todas las consultas van con parámetros preparados (anti-inyección SQL)
- Tokens anti-CSRF en todos los formularios
- Bloqueo temporal de la cuenta tras 5 contraseñas fallidas (15 minutos)
- Límite de peticiones por IP en login, registro, recuperación y recargas
- Recuperación de contraseña con código de 6 dígitos (15 min de vigencia);
  si el servidor tiene `mail()` configurado llega por correo, si no, modo
  demostración mostrando el código en pantalla
- Sesiones con cookie httpOnly, lista de dispositivos y cierre remoto
- Cabeceras de seguridad (X-Frame-Options, nosniff, HSTS en HTTPS…)
- Registro de seguridad auditable en Administración → Seguridad
- Respuestas genéricas anti-enumeración (no se revela si un correo existe)

---

## 📁 Estructura de archivos

```
index.php          Portada (carrusel, ofertas, categorías, mini tiendas)
productos.php      Catálogo con búsqueda, categorías y orden
producto.php       Detalle del producto con fotos
tiendas.php        Listado de mini tiendas
tienda.php         Mini tienda pública
carrito.php        Carrito
checkout.php       Pago en efectivo o transferencia (muestra datos de cobro)
pedido.php         Detalle del pedido + enviar ID de transferencia
pedidos.php        Mis pedidos
cuenta.php         Mi Cuenta: datos, contraseña, sesiones por dispositivo
wallet.php         Billetera: saldo y recargas
login.php / registro.php / recuperar.php / logout.php
notificaciones.php Avisos internos
vender.php         Panel del vendedor
mi-tienda.php      Crear/editar la mini tienda
publicar.php       Publicar/editar productos con fotos
mis-productos.php  Inventario del vendedor
ventas.php         Ventas recibidas del vendedor
suscripcion.php    Pagar la suscripción de 200 CUP/mes con el saldo
install.php        Instalador automático (BORRAR tras instalar)
admin/             Panel de administración completo
includes/          Configuración, conexión a base de datos y seguridad
assets/            Estilos violeta y scripts
uploads/           Fotos (galería incluida + subidas)
schema.sql         Esquema MySQL por si prefieres crear las tablas a mano
```

---

## ❓ Problemas frecuentes

**"No se pudo conectar a la base de datos"**
→ Revisa `includes/config.php`: host, base de datos, usuario y contraseña.

**La web abre el instalador cada vez**
→ El instalador solo corre una vez; si la base ya tiene tablas, te redirige
a la tienda. Asegúrate de que el usuario de MySQL puede escribir.

**No llegan los correos de recuperación**
→ Tu servidor necesita `mail()` configurado (o SMTP). Mientras tanto funciona
el modo demostración: el código aparece en pantalla (aviso amarillo).

**Las fotos no suben**
→ Dale permisos de escritura a la carpeta `uploads/`:
`chmod -R 775 uploads`

**¿Puedo usar SQLite en vez de MySQL?**
→ Sí, para pruebas rápidas: en `includes/config.php` cambia
`DB_DRIVER` a `'sqlite'`. Para el VPS usa MySQL.
