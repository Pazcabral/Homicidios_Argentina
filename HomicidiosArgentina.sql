-- Creamos la base de datos
CREATE DATABASE	HomicidiosArgentina

-- Luego de importar los datos, seleccionamos la base de datos HomicidiosArgentina
USE HomicidiosArgentina;

-- TRANSFORMACIONES
-- Visualizamos los datos de nuestra tabla Homicidios
SELECT * FROM dbo.Homicidios

-- Obtener los nombres de las columnas
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Homicidios';

-- Filtramos los datos para quedarnos con información correspondiente a las víctimas y al año 2022
SELECT *
INTO Victimas2022
FROM Homicidios
WHERE tipo_persona = 'Víctima' AND anio = 2022;

-- Eliminamos columnas innecesarias
ALTER TABLE Victimas2022
DROP COLUMN 
	id_hecho, 
	tipo_persona_id, 
	cant_inc, 
	cant_vic, 
	federal, 
	provincia_id, 
	departamento_id, 
	departamento_nombre,
	localidad_id, 
	radio_censal, 
	latitud_radio,
	longitud_radio, 
	tipo_lugar_otro, 
	clase_arma_otro, 
	en_ocasion_otro_delito_otro, 
	motivo_origen_registro, 
	motivo_origen_registro_otro,
	victima_identidad_genero_otro, 
	victima_clase,
	victima_clase_otro, 
	victima_situacion_ocupacional, 
	victi_situacion_ocupacional_otro,
	inculpado_sexo,
	inculpado_identidad_genero,
	inculpado_identidad_genero_otro,
	inculpado_tr_edad,
	inculpado_clase,
	inculpado_otro_clase,
	inculpado_relacion_victima;

-- Exportar tabla Victimas2022 a Power BI 

-- ANÁLISIS DE LOS DATOS
-- Agrupar los datos en función del género de las víctimas
SELECT
    CASE
        WHEN victima_identidad_genero = 'Varón' THEN 'Varón'
        WHEN victima_identidad_genero = 'Varón trans' THEN 'Varón'
        WHEN victima_identidad_genero = 'Mujer' THEN 'Mujer'
        WHEN victima_identidad_genero = 'Mujer trans/travesti' THEN 'Mujer'
        ELSE 'Otro'
    END AS Género,
    COUNT(tipo_persona) AS Cantidad
FROM Victimas2022
GROUP BY
    CASE
        WHEN victima_identidad_genero = 'Varón' THEN 'Varón'
        WHEN victima_identidad_genero = 'Varón trans' THEN 'Varón'
        WHEN victima_identidad_genero = 'Mujer' THEN 'Mujer'
        WHEN victima_identidad_genero = 'Mujer trans/travesti' THEN 'Mujer'
        ELSE 'Otro'
    END;


-- Obtener datos sobre la cantidad de víctimas según tipo de homicidio
SELECT tipo_hecho_segun_victima, COUNT (tipo_persona) AS Víctimas
FROM Victimas2022
GROUP BY tipo_hecho_segun_victima
ORDER BY 2 DESC;

-- Obtener datos sobre la cantidad de víctimas según mes del hecho
SELECT
    FORMAT(fecha_hecho, 'MM/yyyy') AS Mes,
    COUNT(tipo_persona) AS Víctimas
FROM Victimas2022
GROUP BY FORMAT(fecha_hecho, 'MM/yyyy')
ORDER BY 1;

-- Obtener datos sobre la cantidad de víctimas según día de la semana
SELECT
    FORMAT(fecha_hecho, 'dddd') AS DiaSemana,
    COUNT(tipo_persona) AS Víctimas
FROM Victimas2022
GROUP BY FORMAT(fecha_hecho, 'dddd')
ORDER BY
    CASE FORMAT(fecha_hecho, 'dddd')
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;

-- Agrupar los datos en funcion de las franjas horarias
SELECT 
    CASE
        WHEN hora_hecho = '11:11:11' THEN 'Sin determinar'
        WHEN hora_hecho BETWEEN '00:00:00' AND '05:59:59' THEN 'Madrugada'
        WHEN hora_hecho BETWEEN '06:00:00' AND '11:59:59' THEN 'Mañana'
        WHEN hora_hecho BETWEEN '12:00:00' AND '17:59:59' THEN 'Tarde'
        WHEN hora_hecho BETWEEN '18:00:00' AND '23:59:59' THEN 'Noche'
    END AS FranjaHoraria, 
    COUNT(tipo_persona) AS Victimas
FROM Victimas2022
GROUP BY 
    CASE
        WHEN hora_hecho = '11:11:11' THEN 'Sin determinar'
        WHEN hora_hecho BETWEEN '00:00:00' AND '05:59:59' THEN 'Madrugada'
        WHEN hora_hecho BETWEEN '06:00:00' AND '11:59:59' THEN 'Mañana'
        WHEN hora_hecho BETWEEN '12:00:00' AND '17:59:59' THEN 'Tarde'
        WHEN hora_hecho BETWEEN '18:00:00' AND '23:59:59' THEN 'Noche'
    END
ORDER BY MIN(hora_hecho);


-- Agrupar los datos por provincia y localidad
SELECT 
    provincia_nombre,
    localidad_nombre,
    COUNT(tipo_persona) AS Vic_Localidad,
    SUM(COUNT(tipo_persona)) OVER (PARTITION BY provincia_nombre) AS Vic_Provincia
FROM Victimas2022
GROUP BY provincia_nombre, localidad_nombre;

-- Agrupar los datos por lugar del hecho
SELECT tipo_lugar, COUNT(tipo_persona) AS Victimas
FROM Victimas2022
GROUP BY tipo_lugar
ORDER BY 2 DESC;

-- Agrupar los datos por tipo de arma
SELECT clase_arma, COUNT(tipo_persona) AS Victimas
FROM Victimas2022
GROUP BY clase_arma
ORDER BY 2 DESC;

-- Agrupar los datos por relación victima-victimario/a
SELECT victima_relacion_inculpado, COUNT(tipo_persona) AS Victimas
FROM Victimas2022
GROUP BY victima_relacion_inculpado
ORDER BY 2 DESC;

-- Agrupar los datos según hecho en ocasión de otro delito
SELECT en_ocasion_otro_delito, COUNT(tipo_persona) AS Victimas
FROM Victimas2022
GROUP BY en_ocasion_otro_delito
ORDER BY 2 DESC;

-- Agrupar los datos según edad de la víctima
SELECT victima_tr_edad, COUNT(tipo_persona) AS Victimas
FROM Victimas2022
GROUP BY victima_tr_edad
ORDER BY 1 ASC;