# Sprint 1 — Arquitectura Base y Autenticación de Usuarios

| Campo | Detalle |
|---|---|
| **Duración** | Semana 1 (6 días hábiles) |
| **Objetivo del Sprint** | Establecer la base de datos MySQL, la conexión JDBC centralizada y el flujo completo de Login y Registro con contraseñas seguras. |
| **Resultado** | ✅ Sprint completado |
| **Estado** | Entregado a revisión |
| **Equipo** | Equipo Scrum académico (2–3 integrantes) |
| **Repositorio** | https://github.com/SergioAvella/PARCIAL_JAVA.git |

---

## 1. Planificación del Sprint (Sprint Planning)

**Seleccionado del Product Backlog:** las historias HU-01, HU-02 y HU-03, priorizadas por valor de negocio (sin autenticación no existe ningún módulo posterior).

**Escala de estimación:** Story Points (Fibonacci: 1, 2, 3, 5, 8).

| ID | Historia | Prioridad | SP | Estado |
|----|----------|-----------|----|--------|
| HU-01 | Inicio de sesión | Alta | 5 | ✅ Hecho |
| HU-02 | Registro de cliente | Alta | 3 | ✅ Hecho |
| HU-03 | Almacenamiento seguro de contraseñas | Alta (riesgo) | 3 | ✅ Hecho |
| **Total Sprint Backlog** | | | **11 SP** | |

**Capacidad del equipo:** 11 SP planificados (equipo junior, 6 días hábiles). Velocidad prevista: **11 SP**.

---

## 2. User Stories y Criterios de Aceptación

### HU-01 — Inicio de sesión
**Como** usuario registrado, **quiero** iniciar sesión con mi correo y contraseña **para** acceder a mi panel correspondiente.

**Criterios de aceptación:**
- **CA-01.1 (Válido):** *Given* que existe un usuario con correo y contraseña correctos, *When* enviaré el formulario de login, *Then* se inicia la sesión HTTP y el sistema me redirige al dashboard según mi rol.
- **CA-01.2 (No válido):** *Given* credenciales incorrectas o usuario inactivo, *When* envíe el formulario, *Then* se muestra un mensaje de error y permanezco en `login.jsp`.
- **CA-01.3 (Parámetros):** El correo se normaliza (trim + minúsculas) y se usa `PreparedStatement` para evitar inyección SQL.

### HU-02 — Registro de cliente
**Como** visitante, **quiero** crear una cuenta con mis datos personales **para** convertirme en cliente del sistema.

**Criterios de aceptación:**
- **CA-02.1 (Registro exitoso):** *Given* que completo todos los campos obligatorios y no existen duplicados, *When* envíe el formulario, *Then* se crea el usuario (y su perfil) y soy dirigido al login para iniciar sesión.
- **CA-02.2 (Duplicado):** *Given* que el correo ya está registrado, *When* envíe el formulario, *Then* el sistema captura el **error MySQL 1062** y muestra "el correo ya está registrado" sin romper la vista.
- **CA-02.3 (Validación):** Los campos obligatorios se validan en servidor; la contraseña debe cumplir la política mínima definida en el proyecto.

### HU-03 — Almacenamiento seguro de contraseñas
**Como** administrador del sistema, **quiero** que las contraseñas se almacenen cifradas **para** proteger la información sensible de los usuarios.

**Criterios de aceptación:**
- **CA-03.1 (Hash con salt):** *Given* un registro de usuario, *When* se guarda su contraseña, *Then* se almacena como derivación **PBKDF2WithHmacSHA256** con salt aleatorio de 16 bytes y 100 000 iteraciones (formato `PBKDF2$iteraciones$salt$hash`), **nunca** en texto plano.
- **CA-03.2 (Verificación a prueba de temporización):** La comparación usa `MessageDigest.isEqual` (tiempo constante).
- **CA-03.3 (Compatibilidad):** El verificador acepta también hashes **SHA-256** hexadecimales heredados (usuarios sembrados en `scripts.sql`), permitiendo migración progresiva.

---

## 3. Desglose técnico (Tasks) y Estimaciones

| # | Tarea | Responsable | SP | Horas est. | Entregable |
|---|-------|-------------|----|-----------|------------|
| T1.1 | Crear `docs/scripts.sql` (DDL + DML: 16 tablas, índices, FK y 3 usuarios de prueba) | — | 5 | 24 h | scripts.sql |
| T1.2 | Implementar `ConexionBD.java` (carga de driver + `DriverManager`) | — | 2 | 4 h | ConexionBD.java |
| T1.3 | Implementar `PasswordUtil.java` (PBKDF2-SHA256 con salt) | — | 3 | 8 h | PasswordUtil.java |
| T1.4 | Implementar `LoginServlet.java` (validación, roles y sesión) | — | 5 | 12 h | LoginServlet.class |
| T1.5 | Implementar `RegistroServlet.java` (inserción de usuario + perfil, error 1062) | — | 3 | 8 h | RegistroServlet.class |
| T1.6 | Maquetar `login.jsp` y `registro.jsp` (diseño base responsivo) | — | 3 | 8 h | login.jsp, registro.jsp |
| T1.7 | Configurar `WEB-INF/web.xml` (welcome-file, UTF-8, sesión 30 min, cookie HttpOnly) | — | 1 | 2 h | web.xml |
| | **Total** | | **22 SP** | **66 h** | |

> La velocidad real de ejecución superó la capacidad planificada (11 SP) porque el equipo trabajó en pareja (pairwork) en paralelo. Velocidad real del sprint: **22 SP**.

---

## 4. Definition of Done (DoD) del Sprint

Un elemento del Sprint Backlog se considera **terminado** cuando cumple **todas** las siguientes condiciones:

- [x] **BD:** El script `docs/scripts.sql` ejecuta sin errores en MySQL 8 y deja la base `inmobiliaria_db` con sus 16 tablas y datos de prueba.
- [x] **Código:** Los fuentes de `src/main/java` compilan con `javac` (JDK 17, encoding UTF-8) sin warnings de bloqueo.
- [x] **Seguridad:** No hay contraseñas en texto plano; `PasswordUtil` genera PBKDF2 con salt.
- [x] **Flujo funcional:** Registro → Login → cierre de sesión funcionan extremo a extremo en Tomcat 10.1.
- [x] **Errores controlados:** Duplicado de correo (error 1062) se muestra de forma amigable.
- [x] **Codificación:** Tildes y caracteres especiales se muestran correctamente (UTF-8 por defecto).
- [x] **Despliegue:** La aplicación arranca bajo `http://localhost:8080/PARCIAL_JAVA/` sin excepciones en `catalina.out`.

---

## 5. Resultados y Verificación

| Criterio | Evidencia |
|----------|-----------|
| Script SQL idempotente | `DROP DATABASE IF EXISTS` + `CREATE DATABASE` ejecutados 3 veces sin fallos |
| Login por rol | `LoginServlet` carga roles vía `usuario_rol` + `rol` (INNER JOIN) y los guarda en sesión |
| Registro con perfil | Transacción única usuario + perfil; duplicado controlado con `getErrorCode() == 1062` |
| Hash seguro | Formatos `PBKDF2$100000$<salt>$<hash>` verificados con `verificarContrasena()` |
| Build | `javac` exitoso → `WEB-INF/classes` |

---

## 6. Retrospectiva formal — Sprint 1

**Metodología:** Start / Stop / Continue + análisis de métricas.

### Keep (Continuar haciendo)
- Uso de `PreparedStatement` en todas las consultas (prevención de inyección SQL).
- Centralización de la conexión JDBC en una única clase (`ConexionBD`) con driver cargado en bloque estático.
- Captura específica del **error 1062** para ofrecer mensajes de usuario en lugar de excepciones crudas.

### Stop (Dejar de hacer)
- Dejar la definición arquitectónica para el final: el modelo relacional cambió dos veces durante el sprint. **Detonante:** las historias dependían de un modelo estable.
- Asumir que el driver y el esquema estarán listos "después"; el retrabajo de `scripts.sql` consumió el 20 % de la capacidad.

### Start (Empezar a hacer)
- **Definir el DoD y los criterios de aceptación ANTES de codificar** cada historia (se aplicó recién a mitad del sprint).
- Ejecutar una revisión de pares (code review) de al menos 15 min por historia antes de marcarla "Hecho".
- Versionar `scripts.sql` y `passwordHash` desde el primer commit.

### Acciones de mejora (compromisos)
1. **IM-1:** Congelar el modelo de datos (MER) al inicio del Sprint 2 — responsable: equipo completo; criterio: ninguna modificación de tablas sin impacto aprobado.
2. **IM-2:** Todo código entra a la rama principal solo si `javac` pasa; añadir verificación local antes del push.
3. **IM-3:** Estimar con "planning poker" en el siguiente planning.

### Métricas del sprint
| Métrica | Valor |
|---|---|
| Histórias planificadas / completadas | 3 / 3 (**100 %**) |
| Story Points completados | 22 SP |
| Velocidad del equipo | 22 SP (base para próximos sprints) |
| Defectos abiertos al cierre | 0 |
| Deuda técnica identificada | Manejo de rutas protegidas (se atiende en Sprint 2 con `FiltroAutenticacion`) |

**Veredicto del equipo:** Sprint enfocado y con dosis saludable de retrabajo; la lección clave es que la arquitectura de datos debe estabilizarse antes de codificar los flujos.