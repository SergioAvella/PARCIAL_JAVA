# PROYECTO_INMOBILIARIA

Sistema web para la gestión de una inmobiliaria desarrollado con **Jakarta EE (Java 17)**, **Servlets + JSP**, **JDBC directo** (sin capa DAO) y **MySQL 8**. Incluye control de acceso por roles (RBAC), catálogo público de inmuebles, CRUD completo, citas, solicitudes, favoritos, auditoría y reportes administrativos con consultas SQL agregadas.

- **Registro de cambios de este doc:** se corrigió la documentación del cifrado (ahora describe **SHA-256 con salt vía PBKDF2WithHmacSHA256**), se incorporó la sección de consultas SQL con JOIN, la estructura real de carpetas y el enlace público del repositorio.

## Estructura real del proyecto

```
PARCIAL_JAVA/                          # Raíz de la aplicación (contexto de Tomcat)
├── .vscode/
│   ├── settings.json                  # IntelliSense / classpath / salida de Java (VS Code)
│   └── tasks.json                     # Tarea de compilación javac (Ctrl+Shift+B)
├── .gitignore                         # Excluye config.properties y artefactos compilados
├── config.properties.example          # Plantilla de credenciales (commiteada, sin valores reales)
├── META-INF/
│   └── MANIFEST.MF                    # Metadatos del contenedor (vacío)
├── src/main/java/
│   ├── config/
│   │   └── ConexionBD.java            # Conexión JDBC centralizada (lee config.properties)
│   ├── controladores/                 # 13 Servlets (ver tabla de endpoints)
│   │   ├── AuditoriaServlet.java      #  /auditorias
│   │   ├── CatalogoServlet.java       #  /catalogos (ciudades, tipos, características)
│   │   ├── CerrarSesionServlet.java   #  /CerrarSesionServlet
│   │   ├── CitaServlet.java           #  /CitaServlet
│   │   ├── FavoritoServlet.java       #  /FavoritoServlet
│   │   ├── LoginServlet.java          #  /LoginServlet
│   │   ├── PerfilServlet.java         #  /PerfilServlet
│   │   ├── PropiedadServlet.java      #  /propiedades, /mantenimiento-propiedad
│   │   ├── RegistroServlet.java       #  /RegistroServlet
│   │   ├── ReporteServlet.java        #  /reportes (5 consultas SQL agregadas)
│   │   ├── SolicitudServlet.java      #  /SolicitudServlet
│   │   └── UsuarioServlet.java        #  /UsuarioServlet
│   ├── filtros/
│   │   └── FiltroAutenticacion.java   # @WebFilter: sesión + RBAC + cabeceras anti-caché
│   ├── modelos/                       # 8 entidades (Auditoria, Característica, Cita,
│   │                                  #   Ciudad, Propiedad, Solicitud, TipoPropiedad, Usuario)
│   └── util/
│       ├── PasswordUtil.java          # SHA-256 con salt (PBKDF2WithHmacSHA256)
│       ├── AuthUtil.java              # Autenticación de sesión y roles
│       └── AuditoriaUtil.java         # Registro de auditoría en transacciones
├── WEB-INF/
│   ├── classes/
│   │   ├── config.properties          # Credenciales BD (NO versionado ⇒ usar el .example)
│   │   └── *.class                    # Clases compiladas (javac -d WEB-INF/classes)
│   ├── jspf/                          # Fragmentos reutilizables
│   │   ├── header.jspf
│   │   ├── navbar.jspf
│   │   └── footer.jspf
│   ├── lib/
│   │   └── mysql-connector-j-26.7.0.jar   # Driver JDBC de MySQL
│   └── web.xml                        # Descriptor (welcome-file, sesión, error-page, UTF-8)
├── css/
│   └── styles.css                     # Estilos de la aplicación
├── js/
│   └── main.js                        # Validaciones y comportamiento frontend
├── uploads/                           # Archivos (PDF) subidos por usuarios
│   └── .gitkeep
├── dashboard/                         # Vistas privadas separadas por rol
│   ├── admin/                         # panel.jsp, reportes.jsp, usuarios.jsp, catalogos.jsp, auditorias.jsp
│   ├── agente/                        # panel.jsp, formulario-propiedad.jsp, gestionar-citas.jsp, revisar-solicitudes.jsp
│   └── cliente/                       # panel.jsp, mis-citas.jsp, mis-favoritos.jsp, mis-solicitudes.jsp, perfil.jsp
├── docs/
│   ├── scripts.sql                    # DDL + DML (16 tablas + datos de prueba)
│   ├── mer.pdf                        # Diagrama Entidad-Relación
│   ├── modelo_relacional.pdf          # Diagrama del modelo relacional
│   ├── generar_pdfs.py                # Script Python que genera los diagramas PDF
│   └── sprint1.md, sprint2.md, sprint3.md   # Documentación Scrum
├── index.jsp                          # Página pública de inicio (búsqueda)
├── login.jsp
├── registro.jsp
├── detalle-propiedad.jsp              # Ficha pública de un inmueble
└── acceso-denegado.jsp                # 403 personalizado
```

## 1. Requisitos previos

| Componente | Versión | Descarga |
|------------|---------|----------|
| JDK | 17 (LTS) | https://adoptium.net |
| Apache Tomcat | 10.1.x (Jakarta EE 9+/10) | https://tomcat.apache.org |
| MySQL | 8.0+ | https://dev.mysql.com/downloads/ |
| VS Code | último | https://code.visualstudio.com |
| Extensiones | Extension Pack for Java, Community Server Connectors | VS Code Marketplace |

> **Importante:** para `jakarta.servlet.*` se requiere **Tomcat 10+**. Tomcat 9 (javax) NO es compatible.

## 2. Crear la base de datos

1. Abra MySQL: `mysql -u root -p`
2. Ejecute el script completo (crea la BD `inmobiliaria_db` con **16 tablas** + datos de prueba):

```sql
source C:/ruta/al/proyecto/docs/scripts.sql;
-- o desde la consola del sistema:
mysql -u root -p < docs/scripts.sql
```

3. Verifique la creación:

```sql
USE inmobiliaria_db;
SHOW TABLES;
```

## 3. Configurar la conexión a la base de datos

Las credenciales **no están en el código fuente**. `ConexionBD.java` las carga desde la clase `config.properties` (que en tiempo de ejecución se busca en `WEB-INF/classes/`) y permite sobrescribirlas con variables de entorno.

**Precedencia:** variables de entorno `DB_URL`, `DB_USER`, `DB_PASSWORD` **>** `WEB-INF/classes/config.properties` **>** valores por defecto.

1. Copie la plantilla y edítela con sus credenciales:

```powershell
Copy-Item config.properties.example WEB-INF/classes/config.properties
notepad WEB-INF/classes/config.properties
```

Contenido esperado:

```properties
db.url=jdbc:mysql://localhost:3306/inmobiliaria_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
db.user=root
db.password=su_contrasena
```

2. (Opcional) Defina las variables de entorno como alternativa segura en despliegues:

```powershell
$env:DB_URL="jdbc:mysql://localhost:3306/inmobiliaria_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true"
$env:DB_USER="root"
$env:DB_PASSWORD="su_contrasena"
```

> **Seguridad:** `WEB-INF/classes/config.properties` está ignorado por Git (`.gitignore`). Nunca la commitee.

3. Copie el driver JDBC de MySQL a `WEB-INF/lib/`:

| Archivo | Origen |
|---------|--------|
| `mysql-connector-j-26.7.0.jar` | https://dev.mysql.com/downloads/connector/j/ |

### Cifrado de contraseñas (corregido)

Las contraseñas **no se almacenan en texto plano** y **no usan MD5**.

- Los usuarios nuevos se registran con **PBKDF2 con HMAC-SHA256** (es decir, **SHA-256 con salt**): salt aleatorio de **16 bytes** (`SecureRandom`), **100 000 iteraciones** y clave derivada de 256 bits, serializados como `PBKDF2$iteraciones$salt$hash` en `util/PasswordUtil.java` (sin librerías externas, solo JDK).
- Por compatibilidad, `verificarContrasena` también acepta hashes **SHA-256** hexadecimales (sin salt) usados por los usuarios sembrados en `docs/scripts.sql` (valor `5e884898…` = `SHA-256("password")`). Al migrar usuarios se recomienda re-hashear con PBKDF2 desde el panel de administración.

## 4. Compilar y desplegar

El proyecto se compila **manualmente** a `WEB-INF/classes` (no usa Maven ni Gradle). Incluya en el classpath el `servlet-api.jar`, `el-api.jar` y `jsp-api.jar` del Tomcat, junto con el driver JDBC.

### 4.1 Desde VS Code (recomendado)

1. Abra la carpeta `PARCIAL_JAVA`: `Archivo > Abrir carpeta`.
2. Presione `Ctrl+Shift+B` → ejecuta la tarea **Compilar aplicacion (javac → WEB-INF/classes)**:

```powershell
# Equivalente a lo que ejecuta la tarea (desde la raíz del proyecto):
Get-ChildItem -Recurse -Filter *.java src | Select-Object -ExpandProperty FullName |
    Set-Content -Encoding ascii build.sources.txt
javac -encoding UTF-8 -proc:none `
  -cp "..\..\lib\servlet-api.jar;..\..\lib\el-api.jar;..\..\lib\jsp-api.jar;WEB-INF\lib\mysql-connector-j-26.7.0.jar" `
  -d "WEB-INF\classes" `
  @build.sources.txt
Remove-Item build.sources.txt -ErrorAction SilentlyContinue
```

3. Despliegue y arranque con **Community Server Connectors**: paleta (`Ctrl+Shift+P`) → `Tomcat: Add` → seleccione `$TOMCAT_HOME`, luego arranque el contexto.

### 4.2 Desde terminal

```powershell
# Desde la raíz del proyecto (PARCIAL_JAVA)
javac -encoding UTF-8 -proc:none `
  -cp "..\..\lib\servlet-api.jar;..\..\lib\el-api.jar;..\..\lib\jsp-api.jar;WEB-INF\lib\mysql-connector-j-26.7.0.jar" `
  -d "WEB-INF\classes" `
  (Get-ChildItem -Recurse -Filter *.java src | ForEach-Object { $_.FullName })
```

> Los jars de Tomcat difieren según la instalación: si el proyecto no vive bajo `$TOMCAT_HOME/webapps/`, ajuste las rutas a `servlet-api.jar`, `el-api.jar` y `jsp-api.jar` en `.vscode/settings.json` (`java.project.referencedLibraries`).

### Despliegue en Tomcat (local)

1. Copie la carpeta `PARCIAL_JAVA` dentro de `$TOMCAT_HOME/webapps/` (ya es la estructura interna de la aplicación).
2. Inicie el servidor y abra: `http://localhost:8080/PARCIAL_JAVA/`

> Si usa **Eclipse WTP**: importe la carpeta como *Dynamic Web Project* con *Content Directory* raíz (la propia carpeta `PARCIAL_JAVA`).

## 5. Usuarios de prueba

Contraseña de todos los usuarios de prueba: `password` (hash SHA-256 hexadecimal en `docs/scripts.sql`; los registros nuevos usan PBKDF2-SHA256 con salt).

| Correo | Rol |
|--------|-----|
| `admin@inmobiliariauts.com` | Administrador |
| `carlos.ramirez@inmoandes.com` | Inmobiliaria |
| `ana.torres@gmail.com` | Cliente |

## 6. Las 5 consultas SQL principales con JOIN (exigidas)

Implementadas en `ReporteServlet.java` (`/reportes`, solo admin) y renderizadas en `dashboard/admin/reportes.jsp`.

### Consulta 1 — Catálogo traducible con JOIN de 4 tablas

```sql
SELECT p.id_propiedad, p.titulo, p.precio,
       c.nombre AS ciudad, tp.nombre AS tipo_propiedad,
       i.nombre AS inmobiliaria
FROM propiedad p
INNER JOIN ciudad c         ON c.id_ciudad = p.id_ciudad
INNER JOIN tipo_propiedad tp ON tp.id_tipo = p.id_tipo
INNER JOIN inmobiliaria i   ON i.id_inmobiliaria = p.id_inmobiliaria
ORDER BY p.fecha_publicacion DESC;
```

### Consulta 2 — Relación N:M (características de una propiedad)

```sql
SELECT ca.nombre, ca.descripcion
FROM caracteristica ca
INNER JOIN propiedad_caracteristica pc
       ON pc.id_caracteristica = ca.id_caracteristica
WHERE pc.id_propiedad = ?
ORDER BY ca.nombre;
```

### Consulta 3 — Anti-Join con LEFT JOIN (propiedades sin citas)

```sql
SELECT p.id_propiedad, p.titulo, p.direccion,
       p.matricula_inmobiliaria, p.estado
FROM propiedad p
LEFT JOIN cita ci ON ci.id_propiedad = p.id_propiedad
WHERE ci.id_cita IS NULL
ORDER BY p.titulo;
```

### Consulta 4 — Agregación con INNER JOIN + GROUP BY + HAVING

```sql
SELECT c.nombre AS ciudad, COUNT(*) AS total_disponibles
FROM propiedad p
INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad
WHERE p.estado = 'DISPONIBLE'
GROUP BY c.nombre
HAVING COUNT(*) > 2
ORDER BY total_disponibles DESC;
```

### Consulta 5 — Métrica de trámites por estado (GROUP BY)

```sql
SELECT s.estado, COUNT(*) AS total_solicitudes
FROM solicitud s
GROUP BY s.estado
ORDER BY s.estado;
```

## 7. Endpoints (Servlets)

| Método(s) | URL | Rol requerido |
|-----------|-----|---------------|
| `GET/POST` | `/` | Público |
| `GET` | `/propiedades` | Público (catálogo + detalle) |
| `GET/POST` | `/LoginServlet`, `/RegistroServlet`, `/CerrarSesionServlet` | Público |
| `GET/POST` | `/PerfilServlet` | Autenticado |
| `GET/POST` | `/mantenimiento-propiedad` | INMOBILIARIA, ADMINISTRADOR |
| `GET/POST` | `/CitaServlet`, `/SolicitudServlet`, `/FavoritoServlet` | Autenticado (según flujo) |
| `GET/POST` | `/reportes`, `/catalogos`, `/auditorias`, `/UsuarioServlet` | ADMINISTRADOR |
| *Cualquiera* | `/dashboard/admin/*` | ADMINISTRADOR |
| *Cualquiera* | `/dashboard/agente/*` | INMOBILIARIA, ADMINISTRADOR |
| *Cualquiera* | `/dashboard/cliente/*` | CLIENTE, ADMINISTRADOR |

El acceso se protege mediante `FiltroAutenticacion.java` (`@WebFilter`) con cabeceras `Cache-Control: no-store`, `Pragma: no-cache` y `Expires: 0`.

## 8. Funcionalidades

- Catálogo público de inmuebles con buscador por ciudad, tipo y precio máximo.
- Registro/login con **SHA-256 con salt (PBKDF2WithHmacSHA256)** y control de acceso por rol (`FiltroAutenticacion` → paneles `/dashboard/*`).
- Dashboard por rol: Administrador, Inmobiliaria y Cliente.
- CRUD de propiedades (error 1062 controlado para matrícula duplicada).
- Citas (UNIQUE `id_propiedad + fecha_hora`), solicitudes/documentos y favoritos.
- Reportes administrativos con SQL (**Consultas 1–5**: JOINs, N:M, Anti-Join, `GROUP BY ... HAVING`).
- Catálogos administrables (ciudades, tipos de propiedad, características) y módulo de **auditoría** de operaciones.
- Gestión de usuarios: asignación de roles desde `UsuarioServlet`.

## 9. Enlace al repositorio y Scrum

- **Repositorio Git:** https://github.com/SergioAvella/PARCIAL_JAVA.git
- Documentación Scrum de sprints: `docs/sprint1.md`, `docs/sprint2.md`, `docs/sprint3.md`.
- Diagramas de datos: `docs/mer.pdf` y `docs/modelo_relacional.pdf` (regenerables con `docs/generar_pdfs.py`).