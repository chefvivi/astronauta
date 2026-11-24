# 🧑‍🚀 Libera al Astronauta

Hay un astronauta azul encerrado en una celda con un candado rojo.
Solo una persona tiene la llave: **mi mamá**. Y la única forma de liberarlo es comprarlo.

Hice esta mini app para convencer a mi mamá de que me regale la *Minifigura Gigante de Astronauta Azul* (#40921). Ella la instala en su celular y cada día el "Centro de Control" le recuerda que el astronauta sigue encerrado. Cada día que pasa suma un día más de encierro y él se pone más desesperado… hasta que lo libere.

**App:** https://chefvivi.github.io/astronauta/

---

## Qué hace

- **Historia de bienvenida:** la primera vez que se abre la app sale una mini historia animada, tipo *stories*, en 7 capítulos: un astronauta que flota entre las estrellas, sueña con salir a explorar, conocer planetas, que alguien lo arme pieza por pieza, tener un hogar, que jueguen con él y lo quieran… pero hoy está encerrado, y solo una persona tiene la llave. Se avanza sola, se puede tocar para avanzar o regresar, mantener presionado para pausar o saltarla. Se puede volver a ver desde el botón *Ver la historia del astronauta* (o abriendo la app con `?historia=1`). Todo está dibujado en SVG y animado con CSS, así que no pesa nada y se ve nítido en cualquier pantalla.
- **Una sola pantalla, estilo app de Apple:** fondo de espacio profundo, tarjetas de vidrio (glassmorphism), tipografía del sistema (SF Pro en iPhone, Inter en Android) y esquinas muy redondeadas.
- **Animaciones del espacio a 60 fps:** estrellas con parallax en tres capas que brillan al azar, estrellas fugaces, una luna que rota lento al fondo y el astronauta flotando en gravedad cero. Si el celular tiene activado "Reducir movimiento", las animaciones se apagan.
- **El candado:** al tocarlo se sacude, el celular vibra (en Android) y aparece el aviso *"Candado bloqueado: solo se abre con una compra autorizada por Mamá"*. El reporte se pone más dramático conforme pasan los días.
- **Tarjetas en vivo:**
  - **Días encerrado:** el 23/11/2026 es el día 1 y cada medianoche (hora de Monterrey) se suma otro día, sin fecha límite.
  - **Rescate:** $1,399 MXN.
  - **Ánimo del astronauta:** baja cada día (Tranquilo → Aburrido → Extraña a su familia → Triste → Desesperado → SOS), con una barra que se va vaciando y cambia de color.
  - **Otro día encerrado en:** cuenta regresiva (horas, minutos, segundos) hasta la siguiente medianoche.
- **Mensaje del astronauta:** uno distinto cada día y cada vez más desesperado: quiere salir, ver a su familia, tener con quién jugar y con quién hablar, explorar. Después del día 14 se repiten los más dramáticos.
- **Botón "Liberar al astronauta":** abre la página del producto.
- **Modo liberado:** con `?liberado=1` los barrotes se abren, el candado se cae, el astronauta sale volando y hay confeti de estrellas. Es para enseñárselo a mi mamá el día que me lo compre:
  https://chefvivi.github.io/astronauta/?liberado=1

El astronauta es una ilustración original en SVG (casco redondo, visor oscuro y traje azul). No usa la minifigura, logos ni marcas.

## Archivos

| Archivo | Para qué sirve |
|---|---|
| `index.html` | Toda la app: HTML, CSS y JavaScript en un solo archivo |
| `manifest.json` | Hace que se pueda instalar como app (nombre, íconos, colores) |
| `sw.js` | Service worker: guarda la app para que abra rápido y sin internet |
| `icons/` | Íconos originales (192, 512, maskable, apple-touch-icon y SVG) |
| `.github/workflows/alerta-astronauta.yml` | La alerta diaria por ntfy |
| `ios/` | La versión nativa en SwiftUI |

## Cómo instalarla

### iPhone (Safari)
1. Abre https://chefvivi.github.io/astronauta/ en **Safari**.
2. Toca **Compartir** (el cuadrito con la flecha).
3. Toca **Agregar a inicio**. Si aparece la opción **Abrir como app web**, déjala activada, y toca **Agregar**.
4. Ábrela desde el ícono del astronauta: se abre a pantalla completa, sin la barra de Safari, como una app.

### Android (Chrome)
1. Abre https://chefvivi.github.io/astronauta/ en **Chrome**.
2. Toca **Instalar** en el aviso de abajo, o en el menú **⋮ → Agregar a la pantalla principal → Instalar**.
3. Ábrela desde el ícono del astronauta.

## Notificaciones diarias (ntfy)

Para que mi mamá vea al astronauta seguido, cada mañana le llega una alerta del "Centro de Control". No llega desde mi número ni con mi nombre: llega por **ntfy**, una app gratis de notificaciones.

- Un GitHub Action ([`.github/workflows/alerta-astronauta.yml`](.github/workflows/alerta-astronauta.yml)) corre **todos los días a las 11:30 a. m. de Monterrey** (17:30 UTC) y manda un `POST` a `https://ntfy.sh/$NTFY_TOPIC`.
- El nombre del tema va en el secret **`NTFY_TOPIC`** del repo, así que no aparece en el código. Es un nombre largo y difícil de adivinar.
- Cada alerta trae:
  - un título y un mensaje que rotan entre **7 variantes** (una dice el número de día de encierro),
  - prioridad alta, la etiqueta 🚀 y el ícono del astronauta,
  - al tocarla se abre la app, y en Android trae el botón **Liberar al astronauta**.
- **Para mandar una de prueba:** en GitHub, *Actions → Alerta del astronauta → Run workflow*. Ahí se puede elegir qué mensaje mandar (1 a 7) o dejarlo vacío para mandar el del día.
- GitHub a veces retrasa unos minutos las tareas programadas, así que la alerta puede llegar un poquito después de las 11:30.

### Cómo suscribirse
1. Instala **ntfy** desde la App Store (iPhone) o Play Store (Android).
2. Ábrela, toca **+**, escribe el nombre del tema y toca **Subscribe** (con el servidor `ntfy.sh`, que viene por defecto).
3. Cuando lo pida, permite las notificaciones.

## Versión nativa para iPhone (SwiftUI)

En la carpeta [`ios/`](ios/) está la misma app hecha en **SwiftUI** (estoy aprendiendo Swift). Tiene el mismo diseño y las mismas animaciones:

- Cielo con estrellas en tres capas que brillan y estrellas fugaces (`Canvas` + `TimelineView`) y una luna que rota lento.
- El astronauta dibujado con `Canvas`, flotando en gravedad cero dentro de la celda.
- El candado se sacude (`keyframeAnimator`), el iPhone vibra (`sensoryFeedback`) y sale la hoja con el reporte del día.
- Tarjetas de vidrio (`.ultraThinMaterial`) con los días encerrado, el rescate, el ánimo y la cuenta regresiva para el siguiente día.
- El mensaje del astronauta, la historia de bienvenida de 7 capítulos y el modo liberado con confeti de estrellas.
- **Notificaciones locales** con `UNUserNotificationCenter` todos los días a las **11:30 a. m. de Monterrey**, cada día con su mensaje (las mismas 7 de ntfy). Se programan 60 días por adelantado y se vuelven a programar cada vez que se abre la app. No necesitan internet. Hay un botón **Probar notificación** que manda una en 5 segundos.
- Truco: mantener presionado 1 segundo el texto *"Misión diseñada por Vivi"* cambia al modo liberado. También se puede abrir con el argumento `-liberado YES`.

| Archivo | Qué tiene |
|---|---|
| `AstronautaApp.swift` | Punto de entrada de la app |
| `ContentView.swift` | La pantalla principal, las tarjetas y la hoja del candado |
| `CeldaView.swift` | La celda, los barrotes, el candado y la animación de liberación |
| `AstronautaView.swift` | El dibujo del astronauta (por piezas) |
| `HistoriaView.swift` | La historia de bienvenida |
| `Cielo.swift` | Estrellas, estrellas fugaces y luna |
| `ConfetiView.swift` | Confeti de estrellas |
| `Mision.swift` | Fechas, días de encierro, mensajes y ánimo |
| `Notificaciones.swift` | Notificaciones diarias |
| `Estilo.swift` | Colores y el estilo de vidrio |

### Instalarla en mi iPhone con Xcode (Apple ID gratis)
1. Abre `ios/Astronauta.xcodeproj` en Xcode.
2. En **Xcode → Settings → Accounts**, toca **+** y agrega tu Apple ID.
3. Selecciona el proyecto **Astronauta** → target **Astronauta** → **Signing & Capabilities** → en **Team** elige tu nombre (*Personal Team*). Si dice que el Bundle Identifier ya está ocupado, cámbialo (por ejemplo `com.tunombre.astronauta`).
4. Conecta el iPhone con cable, desbloquéalo y toca **Confiar**.
5. En el iPhone activa **Ajustes → Privacidad y seguridad → Modo de desarrollador** (se reinicia).
6. En Xcode elige tu iPhone arriba y dale **▶︎ Run**.
7. Si al abrirla dice que el desarrollador no es de confianza: **Ajustes → General → VPN y gestión de dispositivos →** tu Apple ID **→ Confiar**.
8. Con un Apple ID gratis la app dura 7 días; después solo vuelve a darle **Run** desde Xcode.

## Hosting (GitHub Pages)

La app está publicada con GitHub Pages desde la rama `main` (carpeta raíz). Cada vez que subo un cambio a `main`, la página se actualiza sola en uno o dos minutos.

Para probarla en mi compu:

```bash
python3 -m http.server 8765
```

y abrir http://localhost:8765

---

Misión diseñada por Vivi · solo Mamá tiene la llave 🔑
