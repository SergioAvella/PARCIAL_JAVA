# Sprint 3 — Trámites, Consultas Agregadas y Cierre de Documentación

| Campo | Detalle |
|---|---|
| **Duración** | Semana 3 (6 días hábiles + cierre de configuración) |
| **Objetivo del Sprint** | Completar los flujos de citas, solicitudes con documentos y favoritos; entregar los reportes administrativos con las 5 consultas SQL con JOIN; y cerrar la documentación, la configuración externa y el empaquetado para entrega. |
| **Resultado** | ✅ Sprint completado |
| **Estado** | Entregado / Release candidata |
| **Equipo** | Equipo Scrum académico (2–3 integrantes) |
| **Repositorio** | https://github.com/SergioAvella/PARCIAL_JAVA.git |

---

## 1. Planificación del Sprint (Sprint Planning)

**Seleccionado del Product Backlog:** los últimos flujos transaccionales (citas, solicitudes, favoritos), el módulo de reportes exigido (SQL con JOIN) y las tareas de documentación/empaquetado.

**Escala de estimación:** Story Points (Fibonacci: 1, 2, 3, 5, 8).

| ID | Historia | Prioridad | SP | Estado |
|----|----------|-----------|----|--------|
| HU-07 | Agendamiento de citas | Alta | 5 | ✅ Hecho |
| HU-08 | Gestión de solicitudes y documentos PDF | Alta | 5 | ✅ Hecho |
| HU-09 | Reportes administrativos (5 consultas SQL con JOIN) | Alta (exigido) | 8 | ✅ Hecho |
| HU-13 | Favoritos de inmuebles | Media | 2 | ✅ Hecho |
| HU-14 | Gestión de usuarios y roles (admin) | Media | 3 | ✅ Hecho |
| HU-15 | Documentación y empaquetado del proyecto | Alta (cierre) | 3 | ✅ Hecho |
| **Total Sprint Backlog** | | | **26 SP** | |

> Apoyados en la velocidad acumulada (≈22,5 SP), el sprint planificó 26 SP para aprovechar el último bloque de capacidad y la fase de documentación compartida.

---

## 2. User Stories y Criterios de Aceptación

### HU-07 — Agendamiento de citas
**Como** cliente, **quiero** solicitar una visita presencial a un inmueble **para** conocerlo antes de decidir la compra.

**Criterios de aceptación:**
- **CA-07.1 (Solicitud de cita):** El cliente registra una cita para un inmueble indicando fecha y hora; el sistema valida que la combinación **`id_propiedad + fecha_hora` sea única** (UNIQUE en BD).
- **CA-07.2 (Conflicto de agenda):** *Given* que ya existe una cita para el mismo inmueble en la misma fecha/hora, *When* el cliente intente agendar, *Then* el sistema muestra un mensaje de conflicto y no persiste el duplicado.
- **CA-07.3 (Gestión del agente):** El panel del agente (`gestionar-citas.jsp`) lista las citas de sus propiedades mediante `INNER JOIN` con `propiedad` e `inmobiliaria` y permite aprobar/rechazar/cambiar estado.
- **CA-07.4 (Consistencia):** Las citas quedan relacionadas con el perfil del cliente (`LEFT JOIN perfil`) para mostrar quién visita.

### HU-08 — Gestión de solicitudes y documentos PDF
**Como** cliente y agente, **quiero** adjuntar y revisar documentos de las solicitudes inmobiliarias **para** formalizar el interés sobre una propiedad.

**Criterios de aceptación:**
- **CA-08.1 (Crear solicitud):** El cliente crea una solicitud asociada a una propiedad con estado inicial definido.
- **CA-08.2 (Adjuntos):** Se soporta la subida de documentos (PDF) a `uploads/` vinculados a la solicitud (tabla `documento_solicitud`).
- **CA-08.3 (Revisión):** El agente revisa y actualiza el estado de la solicitud desde `revisar-solicitudes.jsp`; el historial de cambios queda trazado en `auditoria`.
- **CA-08.4 (Vistas por rol):** Cliente ve solo sus solicitudes (`LEFT JOIN perfil` + filtro por `id_usuario`); el agente ve las de sus inmuebles.

### HU-09 — Reportes administrativos con SQL (exigido: 5 consultas con JOIN)
**Como** administrador, **quiero** visualizar métricas consolidadas **para** tomar decisiones sobre ventas y catálogo.

**Criterios de aceptación:**
- **CA-09.1 (Consulta 1):** Listado de inmuebles con ciudad, tipo e inmobiliaria (**INNER JOIN** de 4 tablas) ordenado por fecha de publicación.
- **CA-09.2 (Consulta 2):** Características de una propiedad seleccionada (relación **N:M** vía `propiedad_caracteristica`).
- **CA-09.3 (Consulta 3):** Propiedades sin ninguna cita (**LEFT JOIN / Anti-Join**, `ci.id_cita IS NULL`).
- **CA-09.4 (Consulta 4):** Cantidad de propiedades `DISPONIBLE` por ciudad (**INNER JOIN + GROUP BY + HAVING COUNT(*) > 2**).
- **CA-09.5 (Consulta 5):** Métrica de solicitudes agrupadas por estado (**GROUP BY**).
- **CA-09.6 (Acceso):** `/reportes` solo accesible para ADMINISTRADOR (verificado por `FiltroAutenticacion`); las tablas se renderizan escapadas (anti-XSS) en `reportes.jsp`.

### HU-13 — Favoritos de inmuebles
**Como** cliente, **quiero** guardar propiedades en favoritos **para** consultarlas rápidamente.

**Criterios de aceptación:**
- **CA-13.1:** Agregar/eliminar favoritos sin recargar la sesión; la lista se muestra en `mis-favoritos.jsp` con JOIN de propiedad, ciudad y tipo.

### HU-14 — Gestión de usuarios y roles
**Como** administrador, **quiero** asignar roles y gestionar el estado de los usuarios **para** administrar los accesos.

**Criterios de aceptación:**
- **CA-14.1:** Listado de usuarios con sus roles (JOIN `usuario_rol` + `rol`); asignación/revocación de roles y activación/inactivación.
- **CA-14.2:** El panel redirige a 403 si el visitante no es ADMINISTRADOR.

### HU-15 — Documentación y empaquetado
**Como** administrador del proyecto, **quiero** documentación completa y configuración reproducible **para** que cualquier desarrollador instale y despliegue en 15 minutos.

**Criterios de aceptación:**
- **CA-15.1:** `README.md` describe estructura real, requisitos, instalación, cifrado (SHA-256 con salt), las 5 consultas y el enlace del repositorio.
- **CA-15.2:** `docs/scripts.sql`, `docs/mer.pdf` y `docs/modelo_relacional.pdf` están en el repositorio y son regenerables (`docs/generar_pdfs.py`).
- **CA-15.3:** Las credenciales de BD están **externalizadas** a `WEB-INF/classes/config.properties` (con plantilla `config.properties.example`), sin secretos en código.
- **CA-15.4:** `docs/sprint1.md`, `docs/sprint2.md` y `docs/sprint3.md` están completos (estimaciones, DoD, criterios de aceptación y retrospectivas).

---

## 3. Desglose técnico (Tasks) y Estimaciones

| # | Tarea | SP | Horas est. | Entregable |
|---|-------|----|-----------|------------|
| T3.1 | Implementar `CitaServlet.java` + `gestionar-citas.jsp` + `mis-citas.jsp` | 5 | 14 h | CitaServlet.class, JSP |
| T3.2 | Implementar `SolicitudServlet.java` (estados + subida a `uploads/`) + vistas | 5 | 16 h | SolicitudServlet.class, JSP |
| T3.3 | Implementar `FavoritoServlet.java` + `mis-favoritos.jsp` | 2 | 6 h | FavoritoServlet.class, JSP |
| T3.4 | Implementar `ReporteServlet.java` (Consulta 1–5) + `reportes.jsp` | 8 | 18 h | ReporteServlet.class, reportes.jsp |
| T3.5 | Implementar `UsuarioServlet.java` + `usuarios.jsp` (roles) | 3 | 10 h | UsuarioServlet.class, usuarios.jsp |
| T3.6 | Subir `docs/mer.pdf`, `docs/modelo_relacional.pdf`, `generar_pdfs.py`, actualizar `scripts.sql` | 2 | 6 h | docs/* |
| T3.7 | Externalizar credenciales a `config.properties` (con `.example`), actualizar `ConexionBD.java` y `.gitignore` | 2 | 4 h | config.properties, ConexionBD.class |
| T3.8 | Configuración de compilación/ejecución en VS Code: `.vscode/settings.json` + `tasks.json` | 1 | 3 h | .vscode/* |
| T3.9 | Actualizar `README.md` y completar `sprint1–3.md` | 3 | 8 h | README.md, docs/sprint*.md |
| T3.10 | Release candidata: build completo, smoke test, inventario de entrega | 2 | 5 h | Verificación final |
| | **Total** | **33 SP** | **90 h** | |

> Incluye las tareas de cierre (T3.7–T3.9) solicitadas en la fase final del proyecto: externalización de credenciales, configuración de VS Code y documentación Sprint/README corregida.

---

## 4. Definition of Done (DoD) del Sprint

- [x] **Trámites:** Citas (con restricción única), solicitudes con documentos PDF y favoritos funcionan de extremo a extremo para cliente y agente.
- [x] **Reportes (5 consultas):** Las 5 consultas SQL se ejecutan sobre `inmobiliaria_db` y se renderizan correctamente en `/reportes` con datos escapados (sin XSS).
- [x] **SQL demostrado:** Cada consulta está documentada en el README con su tipo de JOIN y propósito.
- [x] **Seguridad:** El listado de endpoints del README coincide con la configuración real de `@WebFilter`.
- [x] **Configuración externa:** No hay credenciales de BD en `src/`; `ConexionBD.java` lee `config.properties` (clasepath) con override por variables de entorno.
- [x] **VS Code:** `.vscode/settings.json` (classpath/salida) y `tasks.json` (tarea de compilación `Ctrl+Shift+B`) validados y funcionales.
- [x] **Build y despliegue:** Compilación `javac` exitosa → `WEB-INF/classes`; aplicación operativa en `http://localhost:8080/PARCIAL_JAVA/`.
- [x] **Documentación:** README, MER, modelo relacional y los 3 documentos de sprint completos y consistentes entre sí.
- [x] **Repositorio:** Todos los entregables versionados en https://github.com/SergioAvella/PARCIAL_JAVA.git; `.gitignore` evita secretos y artefactos.

---

## 5. Resultados y Verificación

| Criterio | Evidencia |
|----------|-----------|
| Citas sin duplicados | Restricción `UNIQUE (id_propiedad, fecha_hora)` en `scripts.sql` + validación en `CitaServlet` |
| Documentos | Subida a `uploads/` con vínculo en `documento_solicitud` |
| Consultas SQL | Verificación ejecutando cada `SELECT` por `mysql -u root -p inmobiliaria_db` → resultados esperados en las 5 métricas |
| Anti-Join | Consulta 3 devuelve solo propiedades sin registros en `cita` |
| Credenciales externas | `rg -n "sergio200606\|jdbc:mysql" src` → sin coincidencias en código Java |
| Build final | `javac` exitoso; `WEB-INF/classes` completo; arranque limpio en Tomcat 10.1 |

---

## 6. Retrospectiva formal — Sprint 3

**Metodología:** Start / Stop / Continue + análisis de métricas y deuda técnica.

### Keep
- Ejecución de las 5 consultas contra datos reales **antes** de escribirlas en los servlets (feedback de SQL inmediato).
- Documentación entregada junto con el código (docs "vivas" en el mismo repositorio).
- Externalización de secretos: permitió compartir el repositorio públicamente sin filtrar credenciales.

### Stop
- Documentar en retrospectiva ("todo al final"): varios ajustes de parametrización de `config.properties` tuvieron que retroalimentar README y sprints. **Detonante:** acuerdos de la retros 1 y 2 (anticipar y validar) no se aplicaron a la documentación.
- Dejar la revisión de consistencia README↔código para el último día: se detectó que el README mencionaba cifrado como "SHA-256 (MessageDigest)" cuando el código ya usaba **PBKDF2WithHmacSHA256 (SHA-256 con salt)**.

### Start
- Establecer un "checklist de release" versionado que incluya: secretos fuera del código, enlaces válidos, árbol de carpetas real y pruebas de humo documentadas.
- Programar una sesión de revisión de documentación 2 días antes del final del sprint.

### Métricas del sprint
| Métrica | Valor |
|---|---|
| Historias planificadas / completadas | 6 / 6 (**100 %**) |
| Story Points completados | 26 SP |
| Velocidad promedio acumulada (3 sprints) | ≈23,7 SP/sprint |
| Consultas SQL con JOIN entregadas | 5/5 |
| Artefactos de documentación | 7 (README, 2 PDFs, 3 sprints, scripts.sql, generar_pdfs.py) |
| Defectos abiertos al cierre | 0 |
| Deuda técnica remanente | Gráficas automáticas en el dashboard del admin (fase futura, opcional) |

### Acciones de mejora para próximas fases
1. **IM-7:** Añadir generación automática de gráficas (Chart.js u similar) al dashboard administrativo.
2. **IM-8:** Migrar progresivamente todos los hashes SHA-256 heredados a PBKDF2 (migración de contraseñas).
3. **IM-9:** Considerar un pool de conexiones (HikariCP) o JDBC DataSource de Tomcat para entornos productivos.

**Veredicto del equipo:** Sprint de cierre exitoso: se cumplió el 100 % del alcance, se entregaron las 5 consultas SQL con JOIN exigidas y el proyecto quedó reproducible (configuración externa + scripts + documentación). La aplicación queda como **release candidata** lista para presentación.