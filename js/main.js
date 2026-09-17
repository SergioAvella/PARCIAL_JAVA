/* =====================================================================
   Inmobiliaria UTS - main.js
   Validaciones de formularios del lado del cliente
   ===================================================================== */

document.addEventListener("DOMContentLoaded", function () {

    /* -------------------------------------------------------------
       Utilidad: mensaje de error en un campo
       ------------------------------------------------------------- */
    function mostrarError(campo, mensaje) {
        campo.classList.remove("is-valid");
        campo.classList.add("is-invalid");
        let feedback = campo.parentElement.querySelector(".invalid-feedback");
        if (!feedback) {
            feedback = document.createElement("div");
            feedback.className = "invalid-feedback";
            campo.parentElement.appendChild(feedback);
        }
        feedback.textContent = mensaje;
    }

    function limpiarValidez(campo) {
        campo.classList.remove("is-invalid");
        let feedback = campo.parentElement.querySelector(".invalid-feedback");
        if (feedback) {
            feedback.textContent = "";
        }
    }

    function marcarValido(campo) {
        campo.classList.remove("is-invalid");
        campo.classList.add("is-valid");
    }

    /* -------------------------------------------------------------
       Login: correo obligatorio + formato, clave obligatoria
       ------------------------------------------------------------- */
    var formLogin = document.getElementById("formLogin");
    if (formLogin) {
        formLogin.addEventListener("submit", function (event) {
            var ok = true;
            var correo = formLogin.querySelector("#correo");
            var clave = formLogin.querySelector("#clave");

            if (!correo.value || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(correo.value.trim())) {
                mostrarError(correo, "Ingrese un correo electrónico válido.");
                ok = false;
            } else {
                marcarValido(correo);
            }

            if (!clave.value || clave.value.trim().length < 6) {
                mostrarError(clave, "La contraseña debe tener al menos 6 caracteres.");
                ok = false;
            } else {
                marcarValido(clave);
            }

            if (!ok) {
                event.preventDefault();
            }
        });

        formLogin.querySelectorAll("input").forEach(function (input) {
            input.addEventListener("input", function () { limpiarValidez(input); });
        });
    }

    /* -------------------------------------------------------------
       Registro: correo, nombres/apellidos, clave y confirmación
       ------------------------------------------------------------- */
    var formRegistro = document.getElementById("formRegistro");
    if (formRegistro) {
        formRegistro.addEventListener("submit", function (event) {
            var ok = true;
            var correo = formRegistro.querySelector("#correo");
            var nombres = formRegistro.querySelector("#nombres");
            var apellidos = formRegistro.querySelector("#apellidos");
            var clave = formRegistro.querySelector("#clave");
            var claveConfirmar = formRegistro.querySelector("#clave_confirmacion");

            if (!correo.value || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(correo.value.trim())) {
                mostrarError(correo, "Ingrese un correo electrónico válido.");
                ok = false;
            } else {
                marcarValido(correo);
            }

            if (!nombres.value || nombres.value.trim().length < 3) {
                mostrarError(nombres, "Ingrese sus nombres.");
                ok = false;
            } else {
                marcarValido(nombres);
            }

            if (!apellidos.value || apellidos.value.trim().length < 3) {
                mostrarError(apellidos, "Ingrese sus apellidos.");
                ok = false;
            } else {
                marcarValido(apellidos);
            }

            if (!clave.value || clave.value.trim().length < 6) {
                mostrarError(clave, "La contraseña debe tener al menos 6 caracteres.");
                ok = false;
            } else {
                marcarValido(clave);
            }

            if (claveConfirmar) {
                if (claveConfirmar.value !== clave.value) {
                    mostrarError(claveConfirmar, "Las contraseñas no coinciden.");
                    ok = false;
                } else {
                    marcarValido(claveConfirmar);
                }
            }

            if (!ok) {
                event.preventDefault();
            }
        });

        formRegistro.querySelectorAll("input").forEach(function (input) {
            input.addEventListener("input", function () { limpiarValidez(input); });
        });
    }

    /* -------------------------------------------------------------
       Propiedad: campos obligatorios y valores numéricos coherentes
       ------------------------------------------------------------- */
    var formPropiedad = document.getElementById("formPropiedad");
    if (formPropiedad) {
        formPropiedad.addEventListener("submit", function (event) {
            var ok = true;
            var campos = {
                titulo: { selector: "#titulo", check: function (v) { return v.length >= 3; }, error: "El título debe tener al menos 3 caracteres." },
                id_tipo: { selector: "#id_tipo", check: function (v) { return v !== ""; }, error: "Seleccione un tipo de propiedad." },
                id_ciudad: { selector: "#id_ciudad", check: function (v) { return v !== ""; }, error: "Seleccione una ciudad." },
                direccion: { selector: "#direccion", check: function (v) { return v.length >= 5; }, error: "Ingrese una dirección válida." },
                matricula_inmobiliaria: { selector: "#matricula_inmobiliaria", check: function (v) { return v.length >= 5; }, error: "Ingrese la matrícula inmobiliaria (mínimo 5 caracteres)." },
                precio: { selector: "#precio", check: function (v) { return Number(v) > 0; }, error: "El precio debe ser mayor a 0." },
                area_m2: { selector: "#area_m2", check: function (v) { return Number(v) > 0; }, error: "El área debe ser mayor a 0." }
            };

            Object.keys(campos).forEach(function (nombre) {
                var campo = formPropiedad.querySelector(campos[nombre].selector);
                var valor = campo.value.trim();

                if (!campos[nombre].check(valor)) {
                    mostrarError(campo, campos[nombre].error);
                    ok = false;
                } else {
                    marcarValido(campo);
                }

                if (campo.getAttribute("type") === "number") {
                    var numero = Number(valor);
                    if (campo.id === "habitaciones") {
                        var habitaciones = document.getElementById("habitaciones");
                        if (habitaciones && Number(habitaciones.value) < 0) {
                            mostrarError(habitaciones, "Las habitaciones no pueden ser negativas.");
                            ok = false;
                        }
                    }
                    if (!isFinite(numero) || numero < 0) {
                        mostrarError(campo, "Ingrese un valor numérico válido.");
                        ok = false;
                    }
                }
            });

            if (!ok) {
                event.preventDefault();
            }
        });

        formPropiedad.querySelectorAll("input, select, textarea").forEach(function (campo) {
            campo.addEventListener("input", function () { limpiarValidez(campo); });
        });
    }

    /* -------------------------------------------------------------
       Cita: forzar fecha/hora posteriores al momento actual
       ------------------------------------------------------------- */
    var formCita = document.getElementById("formCita");
    if (formCita) {
        formCita.addEventListener("submit", function (event) {
            var ok = true;
            var fechaHora = formCita.querySelector("#fecha_hora");

            if (fechaHora) {
                var seleccionada = new Date(fechaHora.value);
                if (isNaN(seleccionada.getTime())) {
                    mostrarError(fechaHora, "Seleccione una fecha y hora.");
                    ok = false;
                } else if (seleccionada < new Date()) {
                    mostrarError(fechaHora, "La fecha de la cita debe ser futura.");
                    ok = false;
                } else {
                    marcarValido(fechaHora);
                }
            }

            if (!ok) {
                event.preventDefault();
            }
        });
    }

    /* -------------------------------------------------------------
       Confirmación en botones de aprobar/rechazar
       ------------------------------------------------------------- */
    document.querySelectorAll(".confirmar-accion").forEach(function (boton) {
        boton.addEventListener("click", function (event) {
            var mensaje = boton.getAttribute("data-mensaje") || "¿Está seguro de realizar esta acción?";
            if (!window.confirm(mensaje)) {
                event.preventDefault();
            }
        });
    });

    /* -------------------------------------------------------------
       Auto-descarte de alertas después de 5 segundos
       ------------------------------------------------------------- */
    document.querySelectorAll(".alert-dismissible").forEach(function (alerta) {
        window.setTimeout(function () {
            alerta.classList.add("fade");
            alerta.classList.remove("show");
            window.setTimeout(function () { alerta.remove(); }, 300);
        }, 5000);
    });
});