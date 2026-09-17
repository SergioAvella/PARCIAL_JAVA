package modelos;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Cita {

    private int idCita;
    private int idPropiedad;
    private int idUsuario;
    private Timestamp fechaHora;
    private String estado;
    private String observaciones;
    private Timestamp fechaCreacion;
    private String tituloPropiedad;
    private String direccionPropiedad;
    private BigDecimal precioPropiedad;
    private String inmobiliaria;
    private String nombreCliente;
    private String apellidoCliente;

    public Cita() {
    }

    public Cita(int idCita, int idPropiedad, int idUsuario, Timestamp fechaHora,
            String estado, String observaciones, Timestamp fechaCreacion) {
        this.idCita = idCita;
        this.idPropiedad = idPropiedad;
        this.idUsuario = idUsuario;
        this.fechaHora = fechaHora;
        this.estado = estado;
        this.observaciones = observaciones;
        this.fechaCreacion = fechaCreacion;
    }

    public int getIdCita() {
        return idCita;
    }

    public void setIdCita(int idCita) {
        this.idCita = idCita;
    }

    public int getIdPropiedad() {
        return idPropiedad;
    }

    public void setIdPropiedad(int idPropiedad) {
        this.idPropiedad = idPropiedad;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public Timestamp getFechaHora() {
        return fechaHora;
    }

    public void setFechaHora(Timestamp fechaHora) {
        this.fechaHora = fechaHora;
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

    public Timestamp getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(Timestamp fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
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

    public String getInmobiliaria() {
        return inmobiliaria;
    }

    public void setInmobiliaria(String inmobiliaria) {
        this.inmobiliaria = inmobiliaria;
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