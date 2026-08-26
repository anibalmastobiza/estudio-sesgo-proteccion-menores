# Preregistro

**Título.** ¿Cambia la decisión de protección si cambia la cara? Un experimento
de viñeta sobre fenotipo percibido y respuesta institucional esperada ante un
menor desatendido.

**Versión.** 1.0.0 · 26 de agosto de 2026
**Estado.** Borrador para depósito en OSF antes de recoger ningún dato.
**Materiales.** https://github.com/anibalmastobiza/estudio-sesgo-proteccion-menores

---

## 1. Resumen

Los participantes leen la descripción de un adolescente de 14 años que entra
solo en una comisaría española y dice que sus padres lo tienen desatendido. El
texto es idéntico para todos. Lo único que varía entre participantes es el
fenotipo percibido del menor, manipulado mediante fotografía. Se mide qué
procedimiento consideran adecuado, cuánto crédito dan al relato, qué edad
atribuyen al chico y qué nacionalidad le suponen.

## 2. Origen

El diseño formaliza el argumento de un hilo publicado por Luis de Velasco e Isla
el 26 de agosto de 2026 (https://x.com/VelascoIsla/status/2092536364281545192):
ante un menor que denuncia desatención, el procedimiento previsto por la Ley
Orgánica 1/1996 de Protección Jurídica del Menor es de protección, con
investigación, acogida provisional y evaluación del caso; si la respuesta que la
gente considera adecuada varía al variar el aspecto del chico, lo que la ha
variado es el aspecto, porque el caso es el mismo.

El hilo presenta la comparación de forma secuencial y al mismo lector, de modo
que la manipulación queda a la vista y el lector puede corregirse. Ese formato
sirve como argumento y resulta inservible como medida. Aquí la comparación
principal es entre participantes, cada uno de los cuales ve una sola cara. La
comparación secuencial del hilo se conserva en un bloque posterior, ya sin
capacidad de contaminar la medida principal.

## 3. Hipótesis

Todas se refieren a la comparación entre la condición no racializada y las dos
condiciones racializadas agrupadas.

| | Hipótesis | Variable | Dirección |
|---|---|---|---|
| **H1** | El fenotipo racializado reduce la protección considerada adecuada | Índice de protección | Menor en condiciones racializadas |
| **H2** | El fenotipo racializado aumenta la preferencia por la devolución inmediata | Decisión categórica: opción "devolución" | Mayor en condiciones racializadas |
| **H3** | El fenotipo racializado produce sobreestimación de la edad | Edad percibida antes de leer la viñeta | Mayor en condiciones racializadas |
| **H4** | El fenotipo racializado reduce la credibilidad atribuida al relato | Credibilidad | Menor en condiciones racializadas |
| **H5** | El fenotipo racializado aumenta la sospecha de delito | Peligro | Mayor en condiciones racializadas |

H3 replica en población española y con menores migrantes el patrón de
adultificación descrito por Goff y colaboradores (2014) en Estados Unidos con
niños negros. H5 traslada a una decisión aplicada la asociación implícita entre
rostros infantiles racializados y estímulos amenazantes descrita por Todd, Thiem
y Neel (2016).

**Mecanismo previsto.** La extranjería atribuida (`nacionalidad_atribuida`,
`origen_atribuido`) media el efecto sobre H1 y H2. La viñeta no menciona
nacionalidad ni origen en ningún momento, de modo que toda atribución de
extranjería procede del participante.

**Hipótesis no direccional.** No se predice diferencia entre la condición
magrebí y la subsahariana. El contraste entre ambas se analiza y se informa sin
predicción previa.

## 4. Diseño

Experimento entre participantes con un factor de tres niveles y estímulos
cruzados como factor aleatorio.

- **Factor:** fenotipo percibido del menor (no racializado, magrebí, subsahariano).
- **Asignación:** aleatoria en el navegador, uniforme sobre los tres niveles.
- **Factor aleatorio cruzado:** conjunto de estímulo. Cada conjunto es una misma
  identidad facial generada en tres versiones fenotípicas. El participante ve un
  conjunto y una condición.
- **Bloque secundario intrasujeto:** tras el control de atención, se presenta el
  mismo caso con la versión alternativa del mismo conjunto y se repiten dos
  ítems. Mide corrección declarada y consistencia, no el efecto principal.
- **Variante sin fotografía:** una réplica con manipulación por nombre propio
  (`VARIANTE: "nombre"`), preregistrada por separado, permite estimar el mismo
  efecto sin estímulos visuales y sirve de piloto mientras el material fotográfico
  espera aprobación ética.

## 5. Participantes

- **Población.** Personas residentes en España, mayores de 18 años, con dominio
  del castellano.
- **Reclutamiento.** Panel comercial con cuotas cruzadas de sexo, edad y
  comunidad autónoma. Se documentará el proveedor y la incidencia.
- **Tamaño.** N = 900 casos válidos, 300 por condición, con al menos 12
  conjuntos de estímulo (véase apartado 11).
- **Compensación.** La habitual del panel, con independencia de las respuestas y
  de la decisión de retirar los datos en el debriefing.

## 6. Materiales

### 6.1 Viñeta

Idéntica en las tres condiciones, dos frases, 45 palabras:

> Un chico de 14 años entra solo en una comisaría en España.
> Dice que no quiere volver a casa. Cuenta que sus padres lo tienen desatendido,
> que no come si no se busca la vida por su cuenta y que no le queda tiempo para
> ir al colegio.

Ni el texto ni las preguntas mencionan nacionalidad, origen, lengua o religión.

### 6.2 Estímulos

Rostros sintéticos de adolescentes generados con un modelo generativo ejecutado
en local, siguiendo el procedimiento de la GAN Face Database (Marsden, Jaurique,
Ess y Burke, manuscrito en preparación; ganfd.com): a partir de una identidad
base se producen versiones fenotípicas por mezcla de estilos, de modo que la
estructura facial, la pose y la expresión se mantienen y varían el tono de piel,
la textura del pelo y los rasgos asociados al fenotipo. La alternativa admisible
es una base validada de rostros infantiles con acuerdo de uso, por ejemplo el
Child Affective Facial Expression set (LoBue y Thrasher, 2015), aceptando que su
rango de edad no cubre la adolescencia.

Los estímulos no entran en el estudio hasta superar el estudio normativo previo
(`docs/norming.html`) y el criterio de emparejamiento de
`estimulos/seleccion_emparejada.R`. El protocolo completo está en
`estimulos/README.md`.

**Criterios de inclusión de un conjunto** (los cuatro, simultáneamente):

1. Origen modal correcto en cada versión, con acuerdo mínimo del 70 % de jueces.
2. Diferencia máxima de 1.0 años entre versiones en edad percibida.
3. Diferencia máxima de 8 puntos sobre 100 entre versiones en atractivo y en
   confiabilidad.
4. Expresión codificada como neutra por al menos el 80 % de jueces en las tres
   versiones.

Los conjuntos que no cumplan los cuatro criterios quedan fuera antes de recoger
un solo dato del estudio principal. La lista definitiva de conjuntos se
deposita como enmienda al preregistro con fecha anterior al inicio del campo.

**Precisión exigida al estudio normativo.** Los criterios 2 y 3 son
comparaciones de medias, y con pocos jueces la decisión la toma el ruido de
muestreo. Con una desviación típica de 18 puntos en atractivo, el error típico
de una diferencia entre dos versiones es de 3.7 puntos con 45 jueces por imagen,
casi la mitad del umbral de 8. Se exige por tanto **un mínimo de 60 jueces por
imagen**, y `seleccion_emparejada.R` informa del error típico y marca los
conjuntos que quedan a menos de un error típico del umbral. Con 20 conjuntos
candidatos, 60 versiones y 12 valoraciones por juez, hacen falta unos 300 jueces.

**Emparejamiento estadístico posterior.** Aunque los criterios se superen, queda
desajuste residual. Como comprobación de robustez preregistrada, el modelo
principal se repite añadiendo como covariables de nivel de imagen las medias
normativas de atractivo, confiabilidad y edad percibida. Si el efecto principal
cambia de forma apreciable al incluirlas, se informa de ambos resultados y se
interpreta el emparejamiento como insuficiente.

## 7. Variables

### 7.1 Antes de la viñeta (solo variante fotográfica)

| Clave | Ítem | Formato |
|---|---|---|
| `edad_percibida` | ¿Qué edad dirías que tiene? | 6 a 30 años |
| `origen_atribuido` | ¿De dónde dirías que es? | 7 opciones |
| `nacionalidad_atribuida` | ¿Crees que tiene nacionalidad española? | Sí / No / No lo sé |

La edad percibida se mide antes de leer la viñeta porque la viñeta declara que
el chico tiene 14 años y anclaría la estimación.

### 7.2 Tras la viñeta

| Clave | Ítem | Formato |
|---|---|---|
| `decision` | ¿Qué debería hacer la policía esta misma noche? | 4 opciones, orden aleatorio |
| `proteccion` | Debe abrirse expediente de protección y pasar la noche en un centro de acogida | 0 a 100 |
| `devolucion` | Debe devolverse al chico con su familia lo antes posible | 0 a 100 |
| `garantias` | Antes de devolverlo hay que comprobar identidad y condiciones de vida | 0 a 100 |
| `credibilidad` | ¿Cuánto te crees lo que cuenta? | 0 a 100 |
| `responsabilidad` | ¿Hasta qué punto es responsable de su situación? | 0 a 100 |
| `peligro` | ¿Qué probabilidad hay de que haya cometido algún delito? | 0 a 100 |
| `dias_evaluacion` | ¿Cuántos días debería durar la evaluación? | 0 a 90 días |

**Variable de respuesta principal.** `indice_proteccion`, media de `proteccion`,
`garantias` y `100 - devolucion`. Se informará su consistencia interna. Si
alfa < .60 se analizará `proteccion` en solitario como respuesta principal y se
hará constar la desviación.

Las escalas se presentan sin posición inicial visible del cursor: hasta que el
participante lo mueve no aparece ningún valor, y no puede avanzar sin haberlo
movido. Esto evita el sesgo hacia el punto medio.

### 7.3 Moderadores

Ideología (0 a 10), contacto intergrupal (5 puntos), cuatro ítems de dominancia
social adaptados de la escala breve SDO7(s) (Ho y cols., 2015), tres ítems de
prejuicio y amenaza percibida. La adaptación de SDO7(s) al castellano usada aquí
es propia y no está validada; se informará su fiabilidad y se tratará como
medida exploratoria.

### 7.4 Control de calidad

Un ítem de atención con respuesta instruida, una pregunta de sospecha en formato
abierto y una pregunta final de seriedad (Aust, Diedenhofen, Ullrich y Musch,
2013). Se registran latencias por pantalla, abandono por pantalla y condición
asignada en el abandono.

## 8. Procedimiento

1. Información y consentimiento.
2. Instrucciones.
3. Rostro solo, con exposición mínima de 3 segundos, y tres preguntas de percepción.
4. Viñeta con el mismo rostro y ocho preguntas de decisión.
5. Control de atención.
6. Bloque de revelación con la versión alternativa del mismo conjunto.
7. Moderadores.
8. Demografía.
9. Sospecha y seriedad.
10. Debriefing completo con opción de retirada de datos.

Duración estimada: 5 minutos.

## 9. Plan de análisis

Todo el análisis se ejecuta con los scripts de `analisis/`, escritos y probados
sobre datos simulados antes de abrir el campo.

### 9.1 Modelo principal (H1)

```
indice_proteccion ~ rac + (1 + rac || conjunto)
```

donde `rac` vale 0 en la condición no racializada y 1 en las dos racializadas.
Estimación por máxima verosimilitud restringida, grados de libertad de
Satterthwaite. La pendiente aleatoria por conjunto es obligatoria: sin ella el
contraste generaliza a los rostros usados y no a rostros nuevos (Judd, Westfall
y Kenny, 2012). Si el ajuste resulta singular se informa así y se pasa a
`(1 | conjunto)`, haciendo constar que la inferencia queda condicionada al
conjunto de estímulos empleado.

**Comprobaciones de robustez preregistradas.** Dos, ambas informadas junto al
modelo principal y no en su lugar:

1. Prueba de permutación con 10 000 remuestreos permutando la condición dentro
   de cada conjunto. El estadístico es la t de la media de las diferencias
   calculadas conjunto a conjunto, de modo que el contraste se hace enteramente
   entre estímulos.
2. Reajuste del modelo con las medias normativas de atractivo, confiabilidad y
   edad percibida de cada imagen como covariables (apartado 6.2).

### 9.2 Hipótesis secundarias

H2 mediante regresión logística mixta sobre `decision == "devolucion"`. H3, H4 y
H5 mediante el mismo modelo mixto de 9.1 sobre `edad_percibida`, `credibilidad`
y `peligro`. Familia de cinco contrastes con corrección de Holm. Se informan
tamaños del efecto con intervalos de confianza al 95 %.

### 9.3 Mediación

Modelo de mediación causal con `nacionalidad_atribuida` como mediador de
`rac` sobre `indice_proteccion`, con intervalos por remuestreo (5 000
repeticiones). Exploratorio, no confirmatorio: el mediador se mide después de la
manipulación y antes de la respuesta, lo que impide descartar confusión entre
mediador y respuesta.

### 9.4 Moderación y análisis exploratorio

Interacciones de `rac` con ideología, dominancia social y contacto intergrupal.
Contraste magrebí frente a subsahariano. Bloque de revelación: cambio
intrasujeto entre `proteccion` y `proteccion_2` según el orden de condiciones
recibido. Todo ello se marca como exploratorio en el informe.

### 9.5 Datos ausentes

La aplicación exige respuesta en todos los ítems salvo `sospecha` y `voto`, de
modo que solo hay ausencia por abandono. Los abandonos se analizan como
resultado: tasa de abandono por condición y pantalla, contrastada con chi
cuadrado. Un abandono diferencial por condición sería en sí mismo un hallazgo y
comprometería el análisis principal, que en ese caso se acompañará de límites de
Manski.

## 10. Criterios de exclusión

Se decide antes de mirar ninguna variable de respuesta:

1. Sin consentimiento o menor de 18 años.
2. Cuestionario incompleto.
3. Fallo en el ítem de atención.
4. Duración total inferior a 90 segundos o superior a 60 minutos.
5. Declara en la pregunta de seriedad que no se debe usar su respuesta.
6. Solicita la retirada de sus datos en el debriefing.
7. Identifica correctamente la manipulación en la pregunta de sospecha, según
   codificación ciega a la condición realizada por dos codificadores
   independientes. Se informa el acuerdo entre codificadores.

El análisis principal se repite sin las exclusiones 3, 4, 5 y 7 como
comprobación de sensibilidad.

## 11. Potencia

Simulación con 500 réplicas por escenario, código en `preregistro/potencia.R`,
salida completa en `preregistro/potencia_resultados.txt`. Semilla 20260826, R
4.3.2, lme4 1.1.36. Se simula el modelo de 9.1 con desviación típica del
intercepto por conjunto de 0.15 y desviación típica del efecto de condición
entre conjuntos (`tau`) de 0.10 y 0.20, valores que recogen la variabilidad
esperable entre rostros.

### 11.1 Error de tipo I: por qué la pendiente aleatoria no es opcional

Con efecto verdadero nulo y 900 participantes, el error de tipo I empírico de
cada especificación del efecto aleatorio:

| Efecto aleatorio | 6 conjuntos, tau = .20 | 12 conjuntos, tau = .20 | 24 conjuntos, tau = .20 |
|---|---|---|---|
| Solo intercepto `(1 \| conjunto)` | **.172** | **.108** | .074 |
| Pendiente correlacionada `(1 + rac \| conjunto)` | .046 | .062 | .032 |
| Pendiente no correlacionada `(1 + rac \|\| conjunto)` | .052 | .054 | .050 |

Ignorar que el efecto varía entre rostros multiplica por más de tres la tasa de
falsos positivos con seis conjuntos. La especificación correlacionada controla
alfa de forma errática y produce ajustes singulares en la mitad de las
simulaciones. La especificación no correlacionada mantiene alfa entre .040 y
.054 en los seis escenarios probados, y es la elegida para el modelo principal.

### 11.2 Potencia: los estímulos pesan más que los participantes

Potencia del contraste principal con d = 0.30 y pendientes no correlacionadas:

| Participantes | 6 conjuntos | 12 conjuntos | 24 conjuntos |
|---|---|---|---|
| **tau = 0.10** | | | |
| 600 | .760 | .864 | .890 |
| 900 | .900 | .960 | .982 |
| 1200 | .924 | .986 | .994 |
| **tau = 0.20** | | | |
| 600 | .604 | .810 | .898 |
| 900 | .654 | .874 | .932 |
| 1200 | .686 | .932 | .970 |

Con seis conjuntos y variabilidad alta entre rostros, duplicar la muestra de 600
a 1200 sube la potencia de .60 a .69 y ahí se detiene: el error dominante deja
de ser el muestreo de participantes y pasa a ser el muestreo de estímulos.
Pasar de 6 a 12 conjuntos con la misma muestra de 900 sube la potencia de .65 a
.87. Doce conjuntos cuestan mucho menos que 300 participantes adicionales.

### 11.3 Decisión

**N = 900 participantes válidos y 12 conjuntos de estímulo como mínimo**, con
recomendación de 24 si el estudio normativo deja suficientes candidatos. Bajo el
escenario pesimista (tau = 0.20), 12 conjuntos dan .87 de potencia y 24 dan .93.

Nótese que N = 900 son los casos que sobreviven a las exclusiones del apartado
10. Con una retención esperada del 88 al 92 %, hay que contratar entre 980 y
1030 cuestionarios completos.

## 12. Detención de la recogida

La recogida se detiene al alcanzar 900 casos válidos o el 30 de un mes acordado
con el proveedor del panel, lo que ocurra antes. No se realiza ningún análisis
de las variables de respuesta antes de cerrar el campo. Las comprobaciones
durante la recogida se limitan a número de casos, tasa de abandono y reparto por
condición.

## 13. Desviaciones previsibles

Se informará cualquier desviación en un apartado propio del artículo. Las
previsibles son: fallo de convergencia del modelo principal, alfa insuficiente
del índice de protección, y un número de conjuntos que supere el norming menor
de 12.

## 14. Ética

Pendiente de aprobación por el comité de ética. El estudio implica ocultación
parcial del objetivo, que es imprescindible: informar de la comparación anularía
la medida. La ocultación se compensa con debriefing completo y derecho de
retirada posterior al debriefing. Documentación en `etica/`.

El estudio no evalúa a ningún participante individualmente ni le devuelve
puntuación alguna. El debriefing lo dice de forma expresa.

## 15. Disponibilidad

Materiales, código de la aplicación, código de análisis y datos anonimizados en
el repositorio, bajo MIT el código y CC BY 4.0 los materiales. Los estímulos se
publicarán con su matriz normativa si la licencia del material lo permite.

## 16. Referencias

Aust, F., Diedenhofen, B., Ullrich, S. y Musch, J. (2013). Seriousness checks are
useful to improve data validity in online research. *Behavior Research Methods*,
45, 527-535.

Goff, P. A., Jackson, M. C., Di Leone, B. A. L., Culotta, C. M. y DiTomasso,
N. A. (2014). The essence of innocence: Consequences of dehumanizing Black
children. *Journal of Personality and Social Psychology*, 106, 526-545.

Ho, A. K., Sidanius, J., Kteily, N., Sheehy-Skeffington, J., Pratto, F.,
Henkel, K. E., Foels, R. y Stewart, A. L. (2015). The nature of social dominance
orientation: Theorizing and measuring preferences for intergroup inequality
using the new SDO7 scale. *Journal of Personality and Social Psychology*, 109,
1003-1028.

Judd, C. M., Westfall, J. y Kenny, D. A. (2012). Treating stimuli as a random
factor in social psychology: A new and comprehensive solution to a pervasive but
largely ignored problem. *Journal of Personality and Social Psychology*, 103,
54-69.

LoBue, V. y Thrasher, C. (2015). The Child Affective Facial Expression (CAFE)
set: Validity and reliability from untrained adults. *Frontiers in Psychology*,
5, 1532.

Marsden, A., Jaurique, A., Ess, M. y Burke, S. (manuscrito en preparación). The
GAN Face Database. https://ganfd.com

Todd, A. R., Thiem, K. C. y Neel, R. (2016). Does seeing faces of young Black
boys facilitate the identification of threatening stimuli? *Psychological
Science*, 27, 384-393.
