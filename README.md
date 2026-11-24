# World Layoffs — SQL Data Cleaning

## Descripción del proyecto
Limpieza y estandarización de un dataset público de despidos en empresas de todo el mundo (2020 – 2023), usando MySQL.

El dataset original tenía filas repetidas, nombres de empresas con espacios de más, una misma industria escrita de varias formas, países con errores de escritura, fechas guardadas como texto y celdas vacías. El objetivo es dejarlo en una tabla confiable para un análisis exploratorio posterior (por ejemplo: qué empresas, industrias o países tuvieron más despidos y en qué años).

---

## Tecnologías utilizadas
* **MySQL (Workbench)**
* **SQL:** CTE (`WITH`), funciones de ventana (`ROW_NUMBER`), `JOIN` de una tabla consigo misma, `STR_TO_DATE`, `ALTER TABLE`

---

## Proceso de limpieza

### 1. Copia de trabajo
* Se crea `layoffs_staging` como copia exacta de la tabla original (`CREATE TABLE ... LIKE` + `INSERT ... SELECT`).
* Todos los cambios se hacen sobre la copia, así la tabla `layoffs` queda intacta por si algo sale mal.

### 2. Eliminación de duplicados
* El dataset no tiene un ID único, así que se usa `ROW_NUMBER() OVER (PARTITION BY ...)` sobre todas las columnas. Si una fila tiene `row_num > 1`, es una copia exacta de otra.
* Los duplicados se revisan primero con un CTE. Como MySQL no permite borrar directamente sobre un CTE, se crea una segunda tabla (`layoffs_staging2`) con la columna `row_num` guardada, y desde ahí se eliminan las copias.

### 3. Estandarización
* **Empresas:** `TRIM()` para quitar espacios al inicio y al final del nombre.
* **Industria:** había varias formas de escribir la misma industria que empiezan por "Crypto"; se unifican en "Crypto" para que no se cuenten como industrias distintas.
* **País:** algunas filas decían "United States." con punto al final; se corrige con `TRIM(TRAILING '.' FROM country)`.
* **Fecha:** venía como texto (`3/6/2023`). Primero se pasa al formato que entiende MySQL con `STR_TO_DATE` y después se cambia el tipo de la columna a `DATE`.

### 4. Valores nulos y vacíos
* **Industria vacía:** algunas filas no tenían industria, pero la misma empresa sí la tenía en otra fila. Con un `JOIN` de la tabla consigo misma por `company`, se copia la industria de la fila que sí la tiene. Antes del `UPDATE` se corre el mismo `JOIN` como `SELECT` para ver exactamente qué filas se van a cambiar. Un solo `UPDATE` cubre tanto valores `NULL` como texto vacío (`''`).
* **Bally's Interactive** queda sin industria porque aparece una sola vez y no hay de dónde sacar el dato. Se deja vacía en lugar de asignarle una categoría inventada.
* **Filas sin datos de despidos:** se eliminan las filas que no tienen ni `total_laid_off` ni `percentage_laid_off`, porque el análisis es sobre despidos y esas filas no dicen cuántas personas salieron.

### 5. Limpieza final
* Se elimina la columna `row_num`, que solo sirvió para encontrar duplicados.

---

## Criterios aplicados
* **Revisar antes de modificar:** los cambios más importantes (`UPDATE` y `DELETE`) tienen una consulta `SELECT` previa para ver qué filas se van a afectar.
* **Relleno solo con datos reales:** la industria se completa únicamente cuando la misma empresa ya la tiene registrada en otra fila.
* **La tabla original nunca se modifica.**

---

## Estructura del repositorio
```
├── data_cleaning_layoffs2.sql   # Script completo de limpieza
├── layoffs.csv                  # Dataset original sin limpiar
└── README.md                    # Este documento
