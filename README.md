# World Layoffs — SQL Data Cleaning

## Descripción del proyecto
Limpieza y estandarización de un dataset público de despidos en empresas de todo el mundo (2020–2023), usando MySQL.

El dataset original tenía filas repetidas, nombres de empresas con espacios de más, una misma industria escrita de varias formas, países con errores de escritura, fechas guardadas como texto y celdas vacías. El objetivo es dejarlo en una tabla confiable para un análisis exploratorio posterior (por ejemplo: qué empresas, industrias o países tuvieron más despidos y en qué años).

---

## Tecnologías utilizadas
* **MySQL (Workbench)**
* **SQL:** CTE (`WITH`), funciones de ventana (`ROW_NUMBER`), `JOIN` de una tabla consigo misma, `STR_TO_DATE`, `ALTER TABLE`

---

## Proceso de limpieza

### 1. Copia de trabajo
* Se crea `layoffs_staging` como copia exacta de la tabla original, para hacer todos los cambios sobre la copia y conservar los datos crudos intactos.

### 2. Eliminación de duplicados
* Como el dataset no tiene un ID único, se usa `ROW_NUMBER() OVER (PARTITION BY ...)` sobre todas las columnas: las filas con `row_num > 1` son copias exactas.
* Los duplicados se revisan con un CTE y se eliminan desde una segunda tabla (`layoffs_staging2`) que guarda la columna `row_num`, ya que MySQL no permite borrar directamente sobre un CTE.

### 3. Estandarización
* **Empresas:** `TRIM()` para quitar espacios al inicio y al final.
* **Industria:** las variantes de "Crypto" se unifican en una sola categoría.
* **País:** se corrige "United States." (con punto final) a "United States".
* **Fecha:** se convierte el texto (`3/6/2023`) con `STR_TO_DATE` y luego se cambia el tipo de la columna a `DATE`.

### 4. Valores nulos y vacíos
* **Industria vacía:** se completa con un `JOIN` de la tabla consigo misma, tomando la industria de otra fila de la misma empresa. Un solo `UPDATE` cubre tanto valores `NULL` como texto vacío (`''`).
* **Bally's Interactive** queda sin industria porque aparece una sola vez y no hay de dónde obtener el dato.
* **Filas sin datos de despidos:** se eliminan las filas que no tienen ni `total_laid_off` ni `percentage_laid_off`, ya que no aportan información para el análisis.

### 5. Limpieza final
* Se elimina la columna auxiliar `row_num`.

---

## Estructura del repositorio
├── data_cleaning_layoffs2.sql   # Script completo de limpieza
├── layoffs.csv                  # Dataset original sin limpiar
└── README.md                    # Este documento
