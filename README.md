
# Explicación del Sistema:


El sistema desarrollado permite gestionar de manera eficiente el funcionamiento de una biblioteca universitaria, incluyendo la administración de libros, usuarios, autores, editoriales, préstamos y devoluciones. Está diseñado para facilitar el control del stock de ejemplares, registrar las operaciones diarias de la biblioteca y permitir la consulta de información relevante para la gestión académica.

El sistema está construido sobre una base de datos relacional, con reglas de integridad que aseguran la consistencia de los datos. Además, incorpora vistas para consultas consolidadas, procedimientos almacenados para automatizar operaciones frecuentes y triggers que aplican reglas de negocio de forma automática.


# Instrucciones de instalación y ejecución

Con el objetivo de facilitar la correcta instalación y funcionamiento del proyecto, los scripts SQL han sido organizados y numerados según el orden en que deben ejecutarse. La numeración que antecede al nombre de cada archivo indica la secuencia obligatoria de ejecución.

El orden es el siguiente:

1. **create_biblioteca** – Crea la base de datos y la estructura principal del sistema.
2. **procedimientos_almacenados_biblioteca** – Genera los procedimientos almacenados utilizados por la aplicación.
3. **Resto de los scripts** – Ejecutar respetando la numeración indicada en el nombre de cada archivo.

Es importante mantener este orden, ya que algunos scripts dependen de objetos creados en los pasos anteriores. Alterar la secuencia podría provocar errores durante la instalación o inconsistencias en la base de datos.

Se recomienda verificar que cada script finalice correctamente antes de continuar con el siguiente.

Esperamos que este material facilite la puesta en marcha del proyecto y contribuya a una correcta evaluación del Trabajo Práctico Integrador.
