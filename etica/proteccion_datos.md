# Protección de datos y evaluación de riesgos

## Qué se recoge

| Dato | Finalidad | ¿Identifica? |
|---|---|---|
| Respuestas a los ítems | Análisis | No |
| Latencias por pantalla | Control de calidad | No |
| Casilla del diseño y cara asignada | Análisis | No |
| Resolución de pantalla, tipo de dispositivo | Control de calidad | No |
| Zona horaria e idioma del navegador | Comprobación de residencia declarada | No |
| Identificador aleatorio (UUID) | Vincular envío parcial y final | No |
| Parámetro `fuente` de la URL | Trazar el canal de reclutamiento | No |

## Qué no se recoge

Nombre, correo, teléfono, dirección IP, huella de navegador, identificador de
panel, cookies de terceros. La aplicación no carga recursos externos: no hay
tipografías remotas, ni analíticas, ni CDN. Google Apps Script no expone la IP
del solicitante al script cuando el despliegue tiene acceso público, y el
receptor no la registra.

## Dónde residen

Google Workspace, región de la Unión Europea. Verificar en la consola de
administración que la ubicación de datos del dominio está fijada en la UE antes
de abrir el campo. Si el dominio no lo permite, sustituir el receptor por una
alternativa autoalojada.

## Riesgos identificados

1. **Reidentificación por combinación.** Comunidad autónoma, edad exacta, género
   y recuerdo de voto pueden identificar a alguien en celdas pequeñas. Mitigación:
   antes de publicar los datos, agrupar la edad en tramos de cinco años y
   colapsar las comunidades autónomas con menos de 20 casos.
2. **Incomodidad del participante.** El estudio trata sobre racismo y sobre
   menores desprotegidos. Mitigación: aviso previo, abandono libre en cualquier
   momento, debriefing que declara de forma expresa que no se evalúa a nadie
   individualmente.
3. **Ocultación parcial del objetivo.** Imprescindible para la validez.
   Mitigación: debriefing completo y derecho de retirada posterior al debriefing,
   sin coste para el participante.
4. **Uso indebido de los estímulos.** Rostros sintéticos de apariencia
   adolescente. No se generan en este proyecto: proceden de AI-Faces by Illinois,
   una base publicada y revisada, bajo CC BY-NC 4.0. No se redistribuyen en el
   repositorio; el script los reconstruye desde OSF.
5. **Malinterpretación pública de los resultados.** Un efecto medio de grupo no
   permite inferir el sesgo de ningún individuo. Mitigación: declararlo en el
   debriefing, en el resumen divulgativo y en cualquier nota de prensa.

## Retención

Datos brutos: [número] años en la unidad compartida del grupo, con acceso
restringido. Copia semanal durante la recogida. Datos anonimizados: publicación
permanente en repositorio abierto con DOI.
