# F1 Management – Pitwall Pro (plugin para KOReader)

Juego de gestión de Fórmula 1 por texto, pensado para lectores e-ink (Kindle, Kobo y otros dispositivos con KOReader). Tomas decisiones de pista, mejoras tu auto en pits, negocias contratos de prensa y compites por la popularidad y el campeonato.

No tiene audio ni animaciones, para que funcione bien en pantallas e-ink.

## Características

- Creas tu piloto con nombre y nacionalidad. Empiezas en la posición 22 con popularidad 0.
- **Escudería:** mejoras motor, aceleración, velocidad final y dirección. También puedes reemplazar piezas por otras más potentes, reparar el motor o cambiarlo por uno nuevo.
- **Prensa:** tres tipos de contratos (marca personal, publicidad y chismes), con un máximo de uno por género. Los contratos aceptados pagan por carrera y se pueden cancelar.
- **Tabla clasificatoria** con los puntos de todos los pilotos.
- **Siguiente carrera:** trazado en ASCII, récord de vuelta y clima con probabilidad de lluvia.
- **Qualy y carrera:** siete decisiones por sesión, como entrar por dentro o por fuera de una curva, atacar, apostar al desgaste o a la lluvia, o seguir a los técnicos. Antes de cada sesión eliges neumáticos, y antes de la qualy también la estrategia.
- **Pits obligatorios:** al menos una entrada por carrera. El combustible se llena y eliges neumáticos distintos a los actuales.
- **Conferencia de prensa** después de cada carrera, con tres respuestas mezcladas. Algunas son bizarras.
- Incidentes con mensajes de estilo bizarro.
- Partida guardada en los ajustes de KOReader.

## Instalación

1. Descarga el plugin desde la última release del repositorio. Puedes usar el `.zip` o clonar el repositorio.
2. Copia la carpeta `f1management.koplugin` dentro de la carpeta `koreader/plugins/` de tu dispositivo.
3. Reinicia KOReader.
4. Abre el menú principal y entra en **F1 Management**.

El nombre de la carpeta debe terminar en `.koplugin` y contener `_meta.lua` y `main.lua`.

## Uso

Abre **F1 Management → Nueva temporada** para empezar, o **Continuar temporada** si ya tienes una partida guardada. Para borrar la partida usa **Borrar partida**.

## Estructura del repositorio

```
f1management/
├── README.md
└── f1management.koplugin/
    ├── _meta.lua
    └── main.lua
```

## Limitaciones

- Los pilotos, equipos y récords de vuelta son de referencia y pueden no coincidir con el plantel o los datos vigentes.
- Los trazados se muestran como diagramas ASCII aproximados, no como mapas reales.
- Los textos de la conferencia de prensa son limitados y se repiten.
- La simulación es simplificada y no reproduce la física real de un auto de F1.

## Créditos

Desarrollo original. Ajusta esta sección con tu nombre y las licencias que correspondan.

## Licencia

Pendiente. Define una licencia (por ejemplo MIT) antes de publicar.
