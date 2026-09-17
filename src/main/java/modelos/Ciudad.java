package modelos;

public class Ciudad {

    private int idCiudad;
    private String nombre;
    private String departamento;
    private String codigoDane;

    public Ciudad() {
    }

    public Ciudad(int idCiudad, String nombre, String departamento, String codigoDane) {
        this.idCiudad = idCiudad;
        this.nombre = nombre;
        this.departamento = departamento;
        this.codigoDane = codigoDane;
    }

    public int getIdCiudad() {
        return idCiudad;
    }

    public void setIdCiudad(int idCiudad) {
        this.idCiudad = idCiudad;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDepartamento() {
        return departamento;
    }

    public void setDepartamento(String departamento) {
        this.departamento = departamento;
    }

    public String getCodigoDane() {
        return codigoDane;
    }

    public void setCodigoDane(String codigoDane) {
        this.codigoDane = codigoDane;
    }
}