#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Genera docs/mer.pdf y docs/modelo_relacional.pdf a partir de docs/scripts.sql.
Usa solo la libreria estandar de Python (zlib) para producir PDFs validos y
legibles, sin dependencias externas.

Uso:
    python docs/generar_pdfs.py
"""
import os
import re
import zlib

BASE = os.path.dirname(os.path.abspath(__file__))
SQL_PATH = os.path.join(BASE, "scripts.sql")
OUT_MER = os.path.join(BASE, "mer.pdf")
OUT_REL = os.path.join(BASE, "modelo_relacional.pdf")
HELVETICA = "/Helvetica"


def leer_esquema():
    """Extrae por cada CREATE TABLE: nombre de tabla y lista de columnas (nombre, tipo)."""
    sql = open(SQL_PATH, encoding="utf-8", errors="replace").read()
    tablas = []
    for bloque in re.split(r";\s*$", sql, flags=re.MULTILINE):
        m = re.search(r"CREATE TABLE\s+`?(\w+)`?\s*\((.*)\)", bloque, re.S | re.I)
        if not m:
            continue
        nombre = m.group(1)
        body = m.group(2)
        columnas = []
        for linea in body.splitlines():
            linea = linea.strip()
            if not linea:
                continue
            if re.match(r"(PRIMARY|UNIQUE|CONSTRAINT|KEY|FOREIGN|CHECK)", linea, re.I):
                continue
            cm = re.match(r"`?(\w+)`?\s+([A-Z0-9_ ]+)", linea, re.I)
            if cm:
                columnas.append((cm.group(1), cm.group(2).strip().split()[0:2]))
        if nombre in ("auditoria", "imagen_propiedad", "propiedad_caracteristica"):
            continue
        tablas.append((nombre, columnas))
    return tablas


def escapar(texto):
    return (texto.replace("\\", r"\\")
                 .replace("(", r"\(")
                 .replace(")", r"\)"))


def enc_latin(texto):
    return texto.encode("latin-1", errors="replace")


def construir_pdf(titulo, lineas, ancho=612, alto=792):
    """
    Construye un PDF de una sola pagina con varias lineas de texto.
    """
    import io
    margen = 50
    fuente = 11
    inter = 18
    inicio = alto - margen

    stream = io.StringIO()
    stream.write("BT\n")
    stream.write("/F1 %d Tf\n" % (fuente + 4))
    stream.write("0 0 0 rg\n")
    stream.write("%d %d Td\n" % (margen, inicio))
    stream.write("(%s) Tj\n" % escapar(titulo))
    stream.write("0 0 0 RG\n")
    stream.write("0 %d Td\n" % (-inter * 0.6))
    stream.write("%d %d Td\n" % (margen, inicio - 30))
    y = inicio - 40
    for linea in lineas:
        stream.write("/F1 %d Tf\n" % fuente)
        stream.write("%d %d Td\n" % (margen, y))
        stream.write("(%s) Tj\n" % escapar(linea))
        y -= inter
        if y < margen:
            break
    stream.write("ET\n")

    contenido = enc_latin(stream.getvalue())
    comprimido = zlib.compress(contenido)

    objetos = []
    # 1: catalogo
    objetos.append(b"<< /Type /Catalog /Pages 2 0 R >>")
    # 2: paginas
    objetos.append(b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>")
    # 3: pagina
    objetos.append(
        b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 %d %d] "
        b"/Resources << /Font << /F1 5 0 R >> >> /Contents 4 0 R >>"
        % (ancho, alto)
    )
    # 4: contenido
    objetos.append(
        b"<< /Length %d /Filter /FlateDecode >>\nstream\n%s\nendstream"
        % (len(comprimido), comprimido)
    )
    # 5: fuente
    objetos.append(b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>")

    salida = io.BytesIO()
    salida.write(b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n")
    offsets = [0]
    for numero, cuerpo in enumerate(objetos, start=1):
        offsets.append(salida.tell())
        salida.write(b"%d 0 obj\n" % numero)
        salida.write(cuerpo)
        salida.write(b"\nendobj\n")
    xref_pos = salida.tell()
    salida.write(b"xref\n0 %d\n" % (len(objetos) + 1))
    salida.write(b"0000000000 65535 f \n")
    for offset in offsets[1:]:
        salida.write(b"%010d 00000 n \n" % offset)
    salida.write(b"trailer\n<< /Size %d /Root 1 0 R >>\n" % (len(objetos) + 1))
    salida.write(b"startxref\n%d\n%%%%EOF\n" % xref_pos)
    return salida.getvalue()


def crear_mer(tablas):
    lineas = []
    lineas.append("Entidades del modelo:")
    for idx, (nombre, columnas) in enumerate(tablas, start=1):
        pk = ", ".join(c[0] for c in columnas if c[0].startswith("id_"))
        lineas.append("%d. %s  (PK: %s)" % (idx, nombre.title(), pk if pk else "—"))
    lineas.append("")
    lineas.append("Relaciones principales:")
    lineas.append("- usuario 1:N usuario_rol N:1 rol")
    lineas.append("- usuario 1:1 perfil")
    lineas.append("- propiedad N:1 ciudad, N:1 tipo_propiedad, N:1 inmobiliaria")
    lineas.append("- propiedad 1:N cita / solicitud / favorito")
    lineas.append("- solicitud 1:N documento_solicitud")
    return lineas


def crear_relacional(tablas):
    lineas = []
    for nombre, columnas in tablas:
        cab = "TABLA %s" % nombre.upper()
        lineas.append("%s (%d columnas)" % (cab, len(columnas)))
        for i in range(0, len(columnas), 2):
            par = columnas[i:i + 2]
            txt = "   ".join("%s %s" % (col, tipo) for col, tipo in par)
            lineas.append("  " + txt)
        lineas.append("")
    return lineas


def main():
    tablas = leer_esquema()
    print("Tablas encontradas: %d" % len(tablas))
    open(OUT_MER, "wb").write(construir_pdf(
        "Diagrama Entidad-Relacion - Inmobiliaria UTS", crear_mer(tablas)))
    open(OUT_REL, "wb").write(construir_pdf(
        "Modelo Relacional - Inmobiliaria UTS", crear_relacional(tablas)))
    print("OK: %s" % OUT_MER)
    print("OK: %s" % OUT_REL)


if __name__ == "__main__":
    main()