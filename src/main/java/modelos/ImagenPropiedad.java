package modelos;

import java.sql.Timestamp;

public class ImagenPropiedad {

    private int idImagen;
    private int idPropiedad;
    private String url;
    private String descripcion;
    private boolean esPrincipal;
    private int orden;
    private Timestamp fechaCarga;

    public ImagenPropiedad() {
    }

    public ImagenPropiedad(int idImagen, int idPropiedad, String url, String descripcion,
            boolean esPrincipal, int orden) {
        this.idImagen = idImagen;
        this.idPropiedad = idPropiedad;
        this.url = url;
        this.descripcion = descripcion;
        this.esPrincipal = esPrincipal;
        this.orden = orden;
    }

    public int getIdImagen() {
        return idImagen;
    }

    public void setIdImagen(int idImagen) {
        this.idImagen = idImagen;
    }

    public int getIdPropiedad() {
        return idPropiedad;
    }

    public void setIdPropiedad(int idPropiedad) {
        this.idPropiedad = idPropiedad;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public boolean isEsPrincipal() {
        return esPrincipal;
    }

    public void setEsPrincipal(boolean esPrincipal) {
        this.esPrincipal = esPrincipal;
    }

    public int getOrden() {
        return orden;
    }

    public void setOrden(int orden) {
        this.orden = orden;
    }

    public Timestamp getFechaCarga() {
        return fechaCarga;
    }

    public void setFechaCarga(Timestamp fechaCarga) {
        this.fechaCarga = fechaCarga;
    }
}