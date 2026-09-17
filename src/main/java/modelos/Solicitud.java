package modelos;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Solicitud {

    private int idSolicitud;
    private int idUsuario;
    private int idPropiedad;
    private String tipo;
    private String estado;
    private String observaciones;
    private Timestamp fechaSolicitud;
    private Timestamp fechaRespuesta;
    private int cantidadDocumentos;
    private String tituloPropiedad;
    private String direccionPropiedad;
    private BigDecimal precioPropiedad;
    private String nombreCliente;
    private String apellidoCliente;

    public Solicitud() {
    }

    public Solicitud(int idSolicitud, int idUsuario, int idPropiedad, String tipo,
            String estado, String observaciones, Timestamp fechaSolicitud,
            Timestamp fechaRespuesta) {
        this.idSolicitud = idSolicitud;
        this.idUsuario = idUsuario;
        this.idPropiedad = idPropiedad;
        this.tipo = tipo;
        this.estado = estado;
        this.observaciones = observaciones;
        this.fechaSolicitud = fechaSolicitud;
        this.fechaRespuesta = fechaRespuesta;
    }

    public int getIdSolicitud() {
        return idSolicitud;
    }

    public void setIdSolicitud(int idSolicitud) {
        this.idSolicitud = idSolicitud;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public int getIdPropiedad() {
        return idPropiedad;
    }

    public void setIdPropiedad(int idPropiedad) {
        this.idPropiedad = idPropiedad;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getObservaciones() {
        return observaciones;
    }

    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }

    public Timestamp getFechaSolicitud() {
        return fechaSolicitud;
    }

    public void setFechaSolicitud(Timestamp fechaSolicitud) {
        this.fechaSolicitud = fechaSolicitud;
    }

    public Timestamp getFechaRespuesta() {
        return fechaRespuesta;
    }

    public void setFechaRespuesta(Timestamp fechaRespuesta) {
        this.fechaRespuesta = fechaRespuesta;
    }

    public int getCantidadDocumentos() {
        return cantidadDocumentos;
    }

    public void setCantidadDocumentos(int cantidadDocumentos) {
        this.cantidadDocumentos = cantidadDocumentos;
    }

    public String getTituloPropiedad() {
        return tituloPropiedad;
    }

    public void setTituloPropiedad(String tituloPropiedad) {
        this.tituloPropiedad = tituloPropiedad;
    }

    public String getDireccionPropiedad() {
        return direccionPropiedad;
    }

    public void setDireccionPropiedad(String direccionPropiedad) {
        this.direccionPropiedad = direccionPropiedad;
    }

    public BigDecimal getPrecioPropiedad() {
        return precioPropiedad;
    }

    public void setPrecioPropiedad(BigDecimal precioPropiedad) {
        this.precioPropiedad = precioPropiedad;
    }

    public String getNombreCliente() {
        return nombreCliente;
    }

    public void setNombreCliente(String nombreCliente) {
        this.nombreCliente = nombreCliente;
    }

    public String getApellidoCliente() {
        return apellidoCliente;
    }

    public void setApellidoCliente(String apellidoCliente) {
        this.apellidoCliente = apellidoCliente;
    }
}