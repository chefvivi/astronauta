# 🧑‍🚀 Libera al Astronauta

Hay un astronauta azul encerrado en una celda con un candado rojo.
Solo una persona tiene la llave: **mi mamá**. Y la única forma de liberarlo es comprarlo.

Hice esta mini app para convencer a mi mamá de que me regale la *Minifigura Gigante de Astronauta Azul* (#40921). Ella la instala en su celular y cada día el "Centro de Control" le recuerda que el astronauta sigue encerrado… hasta que lo libere.

**App:** https://chefvivi.github.io/astronauta/

---

## Qué hace

- **Una sola pantalla, estilo app de Apple:** fondo de espacio profundo, tarjetas de vidrio (glassmorphism), tipografía del sistema (SF Pro en iPhone, Inter en Android) y esquinas muy redondeadas.
- **Animaciones del espacio a 60 fps:** estrellas con parallax en tres capas que brillan al azar, estrellas fugaces, una luna que rota lento al fondo y el astronauta flotando en gravedad cero. Si el celular tiene activado "Reducir movimiento", las animaciones se apagan.
- **El candado:** al tocarlo se sacude, el celular vibra (en Android) y aparece el aviso *"Candado bloqueado: solo se abre con una compra autorizada por Mamá"*. El reporte se pone más dramático conforme pasan los días.
- **Tarjetas en vivo:**
  - **Días encerrado**, contando desde el 23/11/2026.
  - **Rescate:** $1,399 MXN.
  - **Oxígeno hasta Black Friday:** cuenta regresiva (días, horas, minutos, segundos) al 27/11/2026 a las 00:00 de Monterrey, con una barra que se va vaciando.
- **Mensaje del astronauta:** un mensaje distinto cada día (rotan 10).
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

## Cómo instalarla

### iPhone (Safari)
1. Abre https://chefvivi.github.io/astronauta/ en **Safari**.
2. Toca **Compartir** (el cuadrito con la flecha).
3. Toca **Agregar a inicio** y luego **Agregar**.
4. Ábrela desde el ícono del astronauta: se ve a pantalla completa, como una app.

### Android (Chrome)
1. Abre https://chefvivi.github.io/astronauta/ en **Chrome**.
2. Toca **Instalar** en el aviso de abajo, o en el menú **⋮ → Agregar a la pantalla principal → Instalar**.
3. Ábrela desde el ícono del astronauta.

## Hosting (GitHub Pages)

La app está publicada con GitHub Pages desde la rama `main` (carpeta raíz). Cada vez que subo un cambio a `main`, la página se actualiza sola en uno o dos minutos.

Para probarla en mi compu:

```bash
python3 -m http.server 8765
```

y abrir http://localhost:8765

---

Misión diseñada por Vivi · solo Mamá tiene la llave 🔑
