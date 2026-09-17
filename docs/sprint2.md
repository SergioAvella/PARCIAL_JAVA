# Sprint 2 — Seguridad (RBAC), Gestión de Inmuebles, Perfil y Catálogos

| Campo | Detalle |
|---|---|
| **Duración** | Semana 2 (6 días hábiles) |
| **Objetivo del Sprint** | Implementar el control de acceso por roles con Filtros de Servlet, completar el CRUD de propiedades y añadir el módulo de catálogos, perfil y auditoría. |
| **Resultado** | ✅ Sprint completado |
| **Estado** | Entregado a revisión |
| **Equipo** | Equipo Scrum académico (2–3 integrantes) |
| **Repositorio** | https://github.com/SergioAvella/PARCIAL_JAVA.git |

---

## 1. Planificación del Sprint (Sprint Planning)

**Seleccionado del Product Backlog:** seguridad (gating de todos los módulos privados), CRUD de inmuebles (núcleo del negocio) y los primeros módulos administrativos (perfil, catálogos y auditoría).

**Escala de estimación:** Story Points (Fibonacci: 1, 2, 3, 5, 8).

| ID | Historia | Prioridad | SP | Estado |
|----|----------|-----------|----|--------|
| HU-04 | Protección de rutas por rol | Alta | 5 | ✅ Hecho |
| HU-05 | Publicación y gestión de inmuebles | Alta | 5 | ✅ Hecho |
| HU-06 | Cierre de sesión seguro | Alta | 2 | ✅ Hecho |
| HU-10 | Edición de perfil personal | Media | 3 | ✅ Hecho |
| HU-11 | Catálogos administrables (ciudades, tipos, características) | Media | 5 | ✅ Hecho |
| HU-12 | Registro de auditoría de operaciones | Alta (cumplimiento) | 3 | ✅ Hecho |
| **Total Sprint Backlog** | | | **23 SP** | |

> **Dato:** tomando la velocidad real del Sprint 1 (22 SP), la planificación pidió un 4 % por encima de la capacidad demostrada. El sprint se completó en su totalidad (small scope increase aceptada en el Sprint Review).

---

## 2. User Stories y Criterios de Aceptación

### HU-04 — Protección de rutas por rol
**Como** sistema, **quiero** restringir el acceso a los recursos `/admin/`, `/agente/` y `/cliente/` **para** que cada usuario vea únicamente lo que su rol permite.

**Criterios de aceptación:**
- **CA-04.1 (Sin sesión):** *Given* que un usuario no autenticado accede a cualquier recurso de `/dashboard/*`, *When* se evalúe el filtro, *Then* el sistema lo redirige a `login.jsp` con mensaje de sesión requerida.
- **CA-04.2 (Rol sin permiso):** *Given* un usuario autenticado cuyo rol no está autorizado para la ruta, *When* intente acceder, *Then* el sistema responde con `sendRedirect` a `acceso-denegado.jsp` (HTTP 403).
- **CA-04.3 (Permisos por matriz):** La matriz de autorización respeta los siguientes mapeos — `admin/*`: solo ADMINISTRADOR; `agente/*`: INMOBILIARIA y ADMINISTRADOR; `cliente/*`: CLIENTE y ADMINISTRADOR; `/reportes`, `/catalogos`, `/auditorias`: solo ADMINISTRADOR.
- **CA-04.4 (Anti-caché):** Toda respuesta filtrada incluye `Cache-Control: no-cache, no-store, must-revalidate`, `Pragma: no-cache` y `Expires: 0` para evitar recuperar páginas protegidas tras el logout.

### HU-05 — Publicación y gestión de inmuebles
**Como** agente inmobiliario, **quiero** registrar, actualizar, listar y desactivar propiedades **para** mantener actualizado el catálogo público.

**Criterios de aceptación:**
- **CA-05.1 (Alta):** *Given* que completo los datos obligatorios (título, precio, dirección, ciudad, tipo, matrícula), *When* envíe el formulario, *Then* la propiedad se crea y queda visible en el catálogo público según su `estado`.
- **CA-05.2 (Matrícula duplicada):** *Given* que la matrícula inmobiliaria ya existe, *When* intente crearla, *Then* se captura el **error 1062** y se muestra mensaje amigable sin pérdida de los datos del formulario.
- **CA-05.3 (Actualización/Eliminación):** Solo usuarios con rol INMOBILIARIA o ADMINISTRADOR pueden editar o desactivar propiedades; cualquier intento desde otro rol devuelve 403.
- **CA-05.4 (Detalle público):** La ficha pública (`detalle-propiedad.jsp`) muestra ciudad, tipo, inmobiliaria y características mediante consultas con JOIN (ver consultas 1 y 2 de `/reportes`).

### HU-06 — Cierre de sesión seguro
**Como** usuario autenticado, **quiero** cerrar sesión de forma segura **para** evitar accesos no autorizados a mi cuenta.

**Criterios de aceptación:**
- **CA-06.1 (Invalidación):** Al solicitar `/CerrarSesionServlet` se invalida la sesión HTTP (`session.invalidate()`) y se limpian los atributos de rol.
- **CA-06.2 (Redirección):** Tras cerrar sesión el usuario es redirigido a `index.jsp`; presionar "Atrás" del navegador no debe reexponer el panel (gracias a las cabeceras anti-caché del filtro).

### HU-10 — Edición de perfil personal
**Como** usuario, **quiero** actualizar nombres, teléfono, dirección y foto **para** mantener mis datos vigentes.

**Criterios de aceptación:**
- **CA-10.1:** El perfil se actualiza sobre la tabla `perfil` (relación 1:1 con `usuario`) y solo el dueño de la sesión puede modificarlo.
- **CA-10.2:** Los cambios se reflejan en `navbar.jspf` y en `dashboard/cliente/perfil.jsp` sin recargar el login.

### HU-11 — Catálogos administrables
**Como** administrador, **quiero** gestionar ciudades, tipos de propiedad y características **para** mantener la coherencia de las listas desplegables.

**Criterios de aceptación:**
- **CA-11.1:** CRUD completo de `ciudad`, `tipo_propiedad` y `caracteristica` desde `/catalogos`.
- **CA-11.2:** El **error 1451** (foreign key en uso) o **1062** (duplicado) se traduce en mensajes comprensibles; no se descuadra la vista.
- **CA-11.3:** Todo alta/baja/modificación queda registrada en la tabla `auditoria`.

### HU-12 — Registro de auditoría de operaciones
**Como** administrador, **quiero** mantener trazabilidad de las operaciones críticas **para** auditar quién hizo qué y cuándo.

**Criterios de aceptación:**
- **CA-12.1:** Cada operación de escritura (INSERT/UPDATE/DELETE) registra usuario, tabla, acción, descripción y timestamp usando `AuditoriaUtil` dentro de la misma transacción.
- **CA-12.2:** La vista `/auditorias` permite consultar el historial con filtros básicos (solo ADMINISTRADOR).

---

## 3. Desglose técnico (Tasks) y Estimaciones

| # | Tarea | SP | Horas est. | Entregable |
|---|-------|----|-----------|------------|
| T2.1 | Implementar `FiltroAutenticacion.java` (`@WebFilter`, RBAC, anti-caché) | 5 | 10 h | FiltroAutenticacion.class |
| T2.2 | Implementar `CerrarSesionServlet.java` | 2 | 2 h | CerrarSesionServlet.class |
| T2.3 | Implementar `PropiedadServlet.java` (CRUD + JOINs + error 1062) | 5 | 16 h | PropiedadServlet.class |
| T2.4 | Crear fragmentos `header.jspf`, `navbar.jspf`, `footer.jspf` | 3 | 6 h | WEB-INF/jspf/* |
| T2.5 | Vista `formulario-propiedad.jsp` + listado del agente | 3 | 8 h | dashboard/agente/* |
| T2.6 | Implementar `PerfilServlet.java` + `perfil.jsp` | 3 | 8 h | PerfilServlet.class, perfil.jsp |
| T2.7 | Implementar `CatalogoServlet.java` + `catalogos.jsp` | 5 | 14 h | CatalogoServlet.class, catalogos.jsp |
| T2.8 | Implementar `AuditoriaUtil.java` + `AuditoriaServlet.java` + `auditorias.jsp` | 3 | 8 h | AuditoriaUtil.class, AuditoriaServlet.class |
| T2.9 | Integrar roles de sesión en `LoginServlet` (Set<String> de roles) | 2 | 4 h | LoginServlet.class |
| | **Total** | **31 SP** | **76 h** | |

> La ejecución acumuló 31 SP de trabajo con una capacidad de 23 SP mediante programación por pares y división de tareas en paralelo; el DoD se cumplió sin trasladar historias al Sprint 3.

---

## 4. Definition of Done (DoD) del Sprint

- [x] **RBAC:** Ninguna ruta de `/dashboard/*`, `/reportes`, `/catalogos`, `/auditorias` ni servlet de trámites es accesible sin sesión o con rol no autorizado (verificado con navegación en incógnito).
- [x] **Acceso denegado:** El flujo 403 (`acceso-denegado.jsp`) responde de forma amigable y no filtra información del reemplazo de ruta.
- [x] **CRUD funcional:** Alta/consulta/actualización/desactivación de propiedades con validaciones de servidor y mensajes de éxito/error.
- [x] **Reutilización de vistas:** Todas las páginas privadas usan los fragmentos `.jspf` (consistencia visual y de navegación).
- [x] **Auditoría:** Las operaciones de catálogos y trámites registran trazabilidad automáticamente.
- [x] **Build limpio:** `javac` exitoso a `WEB-INF/classes`; aplicación arranca en Tomcat 10.1.
- [x] **Sin regresiones:** Login, registro y cierre de sesión del Sprint 1 siguen operativos (pruebas de humo).

---

## 5. Resultados y Verificación

| Criterio | Evidencia |
|----------|-----------|
| Matriz de permisos | `FiltroAutenticacion` con mapeos explícitos por prefijo de URL y rutas de servlets |
| Anti-caché | Cabeceras verificadas con DevTools (red) en `panel.jsp` |
| CRUD sin DAO | `PropiedadServlet` con SQL directo: INSERT/UPDATE/DELETE + `INNER JOIN` para ciudad/tipo/inmobiliaria |
| Catálogos | CRUD de 3 entidades con control de errores `1062` y `1451` MySQL |
| Auditoría | `AuditoriaUtil.registrarEnTransaccion(...)` dentro de la misma conexión |

---

## 6. Retrospectiva formal — Sprint 2

**Metodología:** Start / Stop / Continue + retrospectiva de 5 pasos (bien / mal / aprendido / falta / acción).

### Keep
- Fragmentos `.jspf` reutilizables: redujeron el tiempo de maquetación de las 14 vistas y garantizaron consistencia.
- Registro de auditoría acoplado a la transacción: sin fisuras entre SQL y trazabilidad.
- Control granular de errores MySQL en la capa de servlet.

### Stop
- Aplazar la matriz de permisos: se definió "sobre la marcha" y se detectaron 2 accesos abiertos en revisión (`/catalogos` y `/auditorias` inicialmente sin el filtro). Se corrigió antes del release, pero **rompió brevemente el CI local**.
- Centralizar todo en un solo servlet gigante: `PropiedadServlet` alcanzó ~500 líneas; se dividió responsabilidad en vistas y validaciones antes de continuar.

### Start
- **Revisión de seguridad previa al merge** (checklist: ¿está la ruta en `@WebFilter`? ¿rol correcto? ¿anti-caché?).
- Alertas tempranas de "acceso sin sesión" en desarrollo (redirigir con parámetros de depuración).
- Automatizar el arranque de Tomcat + smoke test tras cada merge.

### Lecciones aprendidas
- El RBAC debe diseñarse como una **matriz explícita** y no dispersa en cada servlet.
- La desnormalización de datos de catálogo vía JOIN elimina datos repetidos y mantiene el dominio consistente.

### Acciones de mejora (compromisos)
1. **IM-4:** Crear checklist de seguridad (5 ítems) adjunta al PR — responsables: todo el equipo.
2. **IM-5:** Limitar el tamaño de los servlets a ~350 líneas efectivas; extraer utilidades de validación.
3. **IM-6:** Añadir smoke tests manuales guionizados (login, RBAC, CRUD) antes del demo.

### Métricas del sprint
| Métrica | Valor |
|---|---|
| Historias planificadas / completadas | 6 / 6 (**100 %**) |
| Story Points completados | 23 SP |
| Velocidad promedio acumulada | 22,5 SP/sprint |
| Defectos abiertos al cierre | 0 (2 encontrados y corregidos en review) |
| Cobertura funcional (módulos con RBAC) | 100 % |

**Veredicto del equipo:** Sprint de alta densidad: se consolidó la seguridad de toda la aplicación y el núcleo operativo (CRUD de inmuebles). La disciplina de revisión de pares evitó que dos accesos no protegidos llegaran a producción.