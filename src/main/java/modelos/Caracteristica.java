package modelos;

public class Caracteristica {

    private int idCaracteristica;
    private String nombre;
    private String icono;

    public Caracteristica() {
    }

    public Caracteristica(int idCaracteristica, String nombre, String icono) {
        this.idCaracteristica = idCaracteristica;
        this.nombre = nombre;
        this.icono = icono;
    }

    public int getIdCaracteristica() {
        return idCaracteristica;
    }

    public void setIdCaracteristica(int idCaracteristica) {
        this.idCaracteristica = idCaracteristica;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getIcono() {
        return icono;
    }

    public void setIcono(String icono) {
        this.icono = icono;
    }
}