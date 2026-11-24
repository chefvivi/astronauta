import SwiftUI

/// La historia de bienvenida: 7 capítulos tipo "stories" que avanzan solos.
/// Toca a la derecha para avanzar, a la izquierda para regresar.
struct HistoriaView: View {
    var alTerminar: () -> Void

    @State private var indice = 0
    @State private var inicioCapitulo = Date()
    @State private var mostrarBoton = false

    private struct Capitulo {
        let clave: String
        let texto: String
        let duracion: Double
    }

    private let capitulos = [
        Capitulo(clave: "Capítulo 1 · Había una vez", texto: "Había una vez, flotando entre las estrellas, un pequeño astronauta azul.", duracion: 6),
        Capitulo(clave: "Capítulo 2 · El sueño", texto: "Todas las noches soñaba lo mismo: salir a explorar el universo.", duracion: 6.5),
        Capitulo(clave: "Capítulo 3 · Explorar", texto: "Conocer planetas, perseguir cometas y ver de cerca cómo brillan las estrellas.", duracion: 6.5),
        Capitulo(clave: "Capítulo 4 · Pieza por pieza", texto: "Soñaba con que alguien lo armara pieza por pieza, con paciencia y con cariño.", duracion: 6.5),
        Capitulo(clave: "Capítulo 5 · Un hogar", texto: "Tener un hogar. Que jugaran con él. Que alguien lo quisiera de verdad.", duracion: 6.5),
        Capitulo(clave: "Capítulo 6 · El candado", texto: "Pero hoy está encerrado, y su sueño tiene un candado.", duracion: 6.5),
        Capitulo(clave: "Capítulo final · La llave", texto: "Solo una persona tiene la llave…", duracion: 6)
    ]

    private var ultimo: Int { capitulos.count - 1 }

    var body: some View {
        ZStack {
            FondoEspacial(conLuna: false)
            VStack(spacing: 0) {
                barraSuperior
                ZStack {
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        escena
                            .id(indice)
                            .transition(.opacity)
                            .frame(maxWidth: 340)
                            .padding(.horizontal, 24)
                        textos
                            .id("texto-\(indice)")
                            .transition(.opacity)
                        Spacer(minLength: 0)
                    }
                    zonasDeToque
                }
                abajo
            }
            .padding(.horizontal, 16)
        }
        .task(id: indice) {
            inicioCapitulo = .now
            mostrarBoton = false
            if indice == ultimo {
                try? await Task.sleep(for: .seconds(2.4))
                withAnimation(.easeOut(duration: 0.6)) { mostrarBoton = true }
                return
            }
            try? await Task.sleep(for: .seconds(capitulos[indice].duracion))
            guard !Task.isCancelled else { return }
            irA(indice + 1)
        }
    }

    private func irA(_ nuevo: Int) {
        withAnimation(.easeInOut(duration: 0.6)) { indice = min(max(nuevo, 0), ultimo) }
    }

    // MARK: - Partes

    private var barraSuperior: some View {
        HStack(spacing: 12) {
            TimelineView(.animation) { tiempo in
                HStack(spacing: 4) {
                    ForEach(capitulos.indices, id: \.self) { i in
                        GeometryReader { geo in
                            Capsule().fill(.white.opacity(0.22))
                                .overlay(alignment: .leading) {
                                    Capsule().fill(.white).frame(width: geo.size.width * progreso(i, ahora: tiempo.date))
                                }
                        }
                        .frame(height: 3)
                    }
                }
            }
            Button("Saltar", action: alTerminar)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
                .padding(.horizontal, 13)
                .frame(height: 30)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .frame(height: 44)
    }

    private func progreso(_ i: Int, ahora: Date) -> CGFloat {
        if i < indice { return 1 }
        if i > indice { return 0 }
        return CGFloat(min(1, ahora.timeIntervalSince(inicioCapitulo) / capitulos[i].duracion))
    }

    private var textos: some View {
        VStack(spacing: 10) {
            Text(capitulos[indice].clave.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .tracking(1.7)
                .foregroundStyle(Paleta.cian)
            Text(capitulos[indice].texto)
                .font(.system(size: 24, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .frame(maxWidth: 330)
            if indice == ultimo {
                (Text("Tú, Mamá. ").foregroundStyle(LinearGradient(colors: [Color(hex: 0xFFF3B8), Paleta.oro, Color(hex: 0xFFB340)], startPoint: .leading, endPoint: .trailing))
                 + Text("💙"))
                    .font(.system(size: 36, weight: .heavy))
                    .opacity(mostrarBoton ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: mostrarBoton)
            }
        }
        .padding(.top, 8)
    }

    private var abajo: some View {
        ZStack {
            if indice == 0 {
                Text("Toca para avanzar")
                    .font(.system(size: 12))
                    .foregroundStyle(Paleta.texto3)
            }
            if indice == ultimo {
                Button(action: alTerminar) {
                    Text("Conocer al astronauta")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: 400)
                        .frame(height: 56)
                        .background(Paleta.botonAzul, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: Paleta.azul.opacity(0.6), radius: 16, y: 10)
                }
                .opacity(mostrarBoton ? 1 : 0)
                .offset(y: mostrarBoton ? 0 : 16)
                .disabled(!mostrarBoton)
            }
        }
        .frame(height: 70)
    }

    private var zonasDeToque: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Color.clear.contentShape(Rectangle())
                    .frame(width: geo.size.width * 0.3)
                    .onTapGesture { irA(indice - 1) }
                Color.clear.contentShape(Rectangle())
                    .onTapGesture { if indice < ultimo { irA(indice + 1) } }
            }
        }
    }

    @ViewBuilder private var escena: some View {
        switch indice {
        case 0: EscenaCelda()
        case 1: EscenaSueno()
        case 2: EscenaExplorar()
        case 3: EscenaPiezas()
        case 4: EscenaHogar()
        case 5: EscenaCandado()
        default: EscenaLlave()
        }
    }
}

// MARK: - Utilidades para las escenas

/// Lienzo de 320 × 320 puntos que se escala al ancho disponible (como el viewBox de un SVG).
struct Lienzo<Contenido: View>: View {
    var ancho: CGFloat = 320
    var alto: CGFloat = 320
    @ViewBuilder var contenido: Contenido

    var body: some View {
        GeometryReader { geo in
            contenido
                .frame(width: ancho, height: alto)
                .scaleEffect(geo.size.width / ancho, anchor: .topLeading)
        }
        .aspectRatio(ancho / alto, contentMode: .fit)
    }
}

/// Algo que se repite sin parar: `fase` va de 0 a 1 cada `periodo` segundos.
struct Ciclo<Contenido: View>: View {
    var periodo: Double
    var retraso: Double = 0
    @ViewBuilder var contenido: (Double) -> Contenido

    var body: some View {
        TimelineView(.animation) { tiempo in
            let t = tiempo.date.timeIntervalSinceReferenceDate - retraso
            contenido((t / periodo).truncatingRemainder(dividingBy: 1))
        }
    }
}

/// Destello dorado que aparece un momento.
private struct Destello: View {
    var retraso: Double
    var tamano: CGFloat = 22
    @State private var visible = false

    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: tamano, weight: .bold))
            .foregroundStyle(Paleta.oro)
            .scaleEffect(visible ? 1.2 : 0.01)
            .rotationEffect(.degrees(visible ? 45 : 0))
            .opacity(visible ? 1 : 0)
            .task {
                try? await Task.sleep(for: .seconds(retraso))
                withAnimation(.easeOut(duration: 0.25)) { visible = true }
                try? await Task.sleep(for: .seconds(0.3))
                withAnimation(.easeIn(duration: 0.35)) { visible = false }
            }
    }
}

private struct Planeta: View {
    var colores: [Color]
    var body: some View {
        Circle()
            .fill(RadialGradient(colors: colores, center: UnitPoint(x: 0.35, y: 0.3), startRadius: 0, endRadius: 60))
            .overlay(Circle().fill(RadialGradient(stops: [.init(color: .clear, location: 0.5), .init(color: Paleta.fondo.opacity(0.75), location: 1)],
                                                  center: UnitPoint(x: 0.35, y: 0.3), startRadius: 0, endRadius: 60)))
    }
}

private let coloresPlanetaCoral = [Color(hex: 0xFFC59B), Color(hex: 0xE9845F), Color(hex: 0x8F3F66)]
private let coloresPlanetaAzul = [Color(hex: 0x9BE6FF), Color(hex: 0x2F8FBF), Color(hex: 0x1B3A6B)]

// MARK: - Capítulo 1 · Había una vez

private struct EscenaCelda: View {
    @State private var acercar = false
    var body: some View {
        Lienzo {
            CeldaView()
                .frame(width: 150)
                .scaleEffect(acercar ? 1.1 : 0.45)
                .opacity(acercar ? 1 : 0)
                .position(x: 160, y: 160)
                .allowsHitTesting(false)
        }
        .onAppear { withAnimation(.easeOut(duration: 6)) { acercar = true } }
    }
}

// MARK: - Capítulo 2 · El sueño

private struct EscenaSueno: View {
    @State private var flotar = false
    @State private var burbujas = 0

    var body: some View {
        Lienzo {
            AstronautaView()
                .frame(width: 103, height: 136)
                .rotationEffect(.degrees(70))
                .offset(y: flotar ? 6 : -6)
                .position(x: 128, y: 214)

            ForEach(0..<3, id: \.self) { i in
                Ciclo(periodo: 2.6, retraso: Double(i) * 0.85) { f in
                    Text(i == 2 ? "Z" : "z")
                        .font(.system(size: [16, 22, 28][i], weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(hex: 0xCFE0FF))
                        .opacity(f < 0.25 ? f / 0.25 : 1 - (f - 0.25) / 0.75)
                        .offset(x: -14 * f, y: 8 - 34 * f)
                }
                .frame(width: 40, height: 40)
                .position(x: [146, 134, 118][i], y: [176, 158, 136][i])
            }

            Circle().fill(.white.opacity(0.28)).frame(width: 8, height: 8)
                .scaleEffect(burbujas >= 1 ? 1 : 0.01).position(x: 184, y: 182)
            Circle().fill(.white.opacity(0.22)).frame(width: 14, height: 14)
                .scaleEffect(burbujas >= 2 ? 1 : 0.01).position(x: 199, y: 163)
            Sueno(visible: burbujas >= 3)
                .scaleEffect(burbujas >= 3 ? 1 : 0.01)
                .position(x: 238, y: 104)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.25).repeatForever(autoreverses: true)) { flotar = true }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.9)) { burbujas = 1 }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(1.1)) { burbujas = 2 }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(1.4)) { burbujas = 3 }
        }
    }

    /// La nube del sueño: un planeta, estrellitas y él volando.
    private struct Sueno: View {
        var visible: Bool
        var body: some View {
            ZStack {
                ZStack {
                    Circle().frame(width: 60, height: 60).offset(x: -34, y: 8)
                    Circle().frame(width: 72, height: 72).offset(x: -4, y: -14)
                    Circle().frame(width: 64, height: 64).offset(x: 30, y: 0)
                    Circle().frame(width: 60, height: 60).offset(x: 2, y: 20)
                    Circle().frame(width: 48, height: 48).offset(x: -20, y: 24)
                }
                .foregroundStyle(.white)
                .opacity(0.15)

                Group {
                    Planeta(colores: coloresPlanetaCoral).frame(width: 30, height: 30).offset(x: -18, y: 6)
                    Ellipse().stroke(Color(hex: 0xFFD7B0, opacity: 0.8), lineWidth: 2.4)
                        .frame(width: 52, height: 13).rotationEffect(.degrees(-18)).offset(x: -18, y: 6)
                    Ciclo(periodo: 3) { f in
                        AstronautaView()
                            .frame(width: 26, height: 34)
                            .rotationEffect(.degrees(40 + sin(f * 2 * .pi) * 9))
                            .offset(x: 22 + sin(f * 2 * .pi) * 7, y: -4 - cos(f * 2 * .pi) * 4)
                    }
                    .frame(width: 120, height: 120)
                }
                .opacity(visible ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.5), value: visible)
            }
            .frame(width: 140, height: 110)
        }
    }
}

// MARK: - Capítulo 3 · Explorar

private struct EscenaExplorar: View {
    @State private var llegar = false
    @State private var derivar = false
    @State private var cometa = false
    @State private var flotar = false

    var body: some View {
        Lienzo {
            Planeta(colores: coloresPlanetaAzul).frame(width: 40, height: 40)
                .position(x: 70, y: 74).offset(x: derivar ? -60 : 0, y: derivar ? 10 : 0)
            ZStack {
                Planeta(colores: coloresPlanetaCoral).frame(width: 124, height: 124)
                Ellipse().stroke(Color(hex: 0xFFD7B0, opacity: 0.55), lineWidth: 5)
                    .frame(width: 204, height: 38).rotationEffect(.degrees(-16))
            }
            .position(x: 252, y: 240).offset(x: derivar ? -26 : 0, y: derivar ? 6 : 0)

            Capsule()
                .fill(LinearGradient(colors: [.white.opacity(0.9), .white.opacity(0)], startPoint: .leading, endPoint: .trailing))
                .frame(width: 80, height: 3)
                .rotationEffect(.degrees(-27))
                .position(x: 296, y: 47)
                .offset(x: cometa ? -360 : 0, y: cometa ? 180 : 0)
                .opacity(cometa ? 0 : 1)

            AstronautaView()
                .frame(width: 109, height: 145)
                .rotationEffect(.degrees(52))
                .offset(y: flotar ? 6 : -6)
                .scaleEffect(llegar ? 1 : 0.6)
                .offset(x: llegar ? 0 : -230, y: llegar ? 0 : 170)
                .position(x: 150, y: 150)
        }
        .onAppear {
            withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 2.6)) { llegar = true }
            withAnimation(.linear(duration: 6.5)) { derivar = true }
            withAnimation(.easeIn(duration: 2.2).delay(1.2)) { cometa = true }
            withAnimation(.easeInOut(duration: 3.25).repeatForever(autoreverses: true)) { flotar = true }
        }
    }
}

// MARK: - Capítulo 4 · Pieza por pieza

private struct EscenaPiezas: View {
    @State private var armado = false
    @State private var brinco = 0

    private let piezas: [(pieza: Pieza, desde: CGSize, giro: Double, retraso: Double)] = [
        (.mochila, CGSize(width: -150, height: -90), -60, 0.25),
        (.piernas, CGSize(width: 30, height: 170), 20, 0.65),
        (.brazoIzquierdo, CGSize(width: -170, height: 30), -80, 1.05),
        (.torso, CGSize(width: 170, height: 70), 50, 1.45),
        (.brazoDerecho, CGSize(width: 170, height: -70), 90, 1.85),
        (.casco, CGSize(width: 0, height: -210), -35, 2.3)
    ]
    private let destellos: [(x: CGFloat, y: CGFloat, retraso: Double)] = [
        (160, 182, 0.85), (160, 251, 1.25), (100, 219, 1.65), (125, 194, 2.05), (224, 141, 2.45), (160, 74, 2.9)
    ]

    var body: some View {
        Lienzo {
            ZStack {
                ForEach(piezas.indices, id: \.self) { i in
                    let p = piezas[i]
                    AstronautaView(piezas: [p.pieza])
                        .frame(width: 147, height: 196)
                        .rotationEffect(.degrees(armado ? 0 : p.giro))
                        .offset(armado ? .zero : p.desde)
                        .opacity(armado ? 1 : 0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.62).delay(p.retraso), value: armado)
                }
            }
            .keyframeAnimator(initialValue: CGFloat(0), trigger: brinco) { vista, y in
                vista.offset(y: y)
            } keyframes: { _ in
                KeyframeTrack {
                    CubicKeyframe(-16, duration: 0.25)
                    CubicKeyframe(3, duration: 0.2)
                    CubicKeyframe(0, duration: 0.2)
                }
            }
            .position(x: 160, y: 171)

            ForEach(destellos.indices, id: \.self) { i in
                Destello(retraso: destellos[i].retraso).position(x: destellos[i].x, y: destellos[i].y)
            }
        }
        .onAppear { armado = true }
        .task {
            try? await Task.sleep(for: .seconds(3.4))
            brinco += 1
        }
    }
}

// MARK: - Capítulo 5 · Un hogar

private struct EscenaHogar: View {
    @State private var girar = false
    @State private var trazo = false

    var body: some View {
        Lienzo {
            Circle()
                .fill(RadialGradient(colors: [Color(hex: 0xFFB35C, opacity: 0.28), .clear], center: .center, startRadius: 0, endRadius: 150))
                .frame(width: 300, height: 300)
                .position(x: 160, y: 180)
            Circle()
                .stroke(.white.opacity(0.22), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [2, 10]))
                .frame(width: 144, height: 144)
                .rotationEffect(.degrees(trazo ? 360 : 0))
                .position(x: 160, y: 150)
            ZStack {
                AstronautaView()
                    .frame(width: 79, height: 105)
                    .rotationEffect(.degrees(girar ? -360 : 0))
                    .offset(y: -72)
            }
            .frame(width: 200, height: 200)
            .rotationEffect(.degrees(girar ? 360 : 0))
            .position(x: 160, y: 150)

            Image(systemName: "house.fill")
                .font(.system(size: 52))
                .foregroundStyle(LinearGradient(colors: [Color(hex: 0xFFD9A0), Color(hex: 0xFFB35C)], startPoint: .top, endPoint: .bottom))
                .shadow(color: Color(hex: 0xFFB35C, opacity: 0.6), radius: 14)
                .position(x: 160, y: 272)

            ForEach(0..<5, id: \.self) { i in
                let x: [CGFloat] = [128, 196, 160, 110, 214]
                let dx: [CGFloat] = [-24, 22, -6, -30, 30]
                let colores = [Color(hex: 0xFF6B8A), Color(hex: 0xFF9FB3), Paleta.rojo, Color(hex: 0xFF9FB3), Color(hex: 0xFF6B8A)]
                Ciclo(periodo: 3.2, retraso: [0, 0.7, 1.4, 2.1, 2.6][i]) { f in
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(colores[i])
                        .scaleEffect(0.3 + 0.9 * f)
                        .offset(x: dx[i] * f, y: -150 * f)
                        .opacity(f < 0.2 ? f / 0.2 : 1 - (f - 0.2) / 0.8)
                }
                .frame(width: 40, height: 40)
                .position(x: x[i], y: 258)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.4).repeatForever(autoreverses: false)) { girar = true }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) { trazo = true }
        }
    }
}

// MARK: - Capítulo 6 · El candado

private struct EscenaCandado: View {
    @State private var barrotes = false
    @State private var candado = false
    @State private var triste = false
    @State private var pulso = false
    @State private var sacudir = 0

    var body: some View {
        Lienzo {
            Circle()
                .fill(RadialGradient(colors: [Paleta.rojo.opacity(0.30), .clear], center: .center, startRadius: 0, endRadius: 150))
                .frame(width: 300, height: 300)
                .opacity(pulso ? 0.45 : 1)
                .position(x: 160, y: 160)

            AstronautaView()
                .frame(width: 122, height: 161)
                .rotationEffect(.degrees(triste ? 9 : 0))
                .offset(y: triste ? 12 : 0)
                .position(x: 160, y: 159)

            Canvas { g, _ in
                let metal = Gradient(colors: [Color(hex: 0x363E51), Color(hex: 0xDBE2EE), Color(hex: 0x8C96AA), Color(hex: 0x3F475A)])
                for x in [52.0, 92, 132, 178, 218, 258] {
                    g.fill(Path(roundedRect: CGRect(x: x, y: 10, width: 10, height: 300), cornerRadius: 5),
                           with: .linearGradient(metal, startPoint: CGPoint(x: x, y: 0), endPoint: CGPoint(x: x + 10, y: 0)))
                }
                let riel = Gradient(colors: [Color(hex: 0xD9E0EC), Color(hex: 0x7F899D), Color(hex: 0x3B4356)])
                for y in [62.0, 232] {
                    g.fill(Path(roundedRect: CGRect(x: 34, y: y, width: 252, height: 10), cornerRadius: 5),
                           with: .linearGradient(riel, startPoint: CGPoint(x: 0, y: y), endPoint: CGPoint(x: 0, y: y + 10)))
                }
            }
            .frame(width: 320, height: 320)
            .offset(y: barrotes ? 0 : -400)
            .position(x: 160, y: 160)

            CandadoView()
                .frame(width: 80, height: 90)
                .scaleEffect(1.25)
                .keyframeAnimator(initialValue: 0.0, trigger: sacudir) { vista, angulo in
                    vista.rotationEffect(.degrees(angulo), anchor: UnitPoint(x: 0.5, y: 0.11))
                } keyframes: { _ in
                    KeyframeTrack {
                        CubicKeyframe(-14, duration: 0.12)
                        CubicKeyframe(11, duration: 0.15)
                        CubicKeyframe(-6, duration: 0.15)
                        CubicKeyframe(0, duration: 0.18)
                    }
                }
                .offset(y: candado ? 0 : -400)
                .position(x: 160, y: 268)
        }
        .sensoryFeedback(.error, trigger: sacudir)
        .task {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.5)) { barrotes = true }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.55).delay(1.3)) { candado = true }
            withAnimation(.easeInOut(duration: 2.6).delay(1.8)) { triste = true }
            withAnimation(.easeInOut(duration: 1.2).delay(1.3).repeatForever(autoreverses: true)) { pulso = true }
            try? await Task.sleep(for: .seconds(2.3))
            sacudir += 1
        }
    }
}

// MARK: - Capítulo final · La llave

private struct EscenaLlave: View {
    @State private var aparecer = false
    @State private var flotar = false
    @State private var rayos = false

    var body: some View {
        Lienzo {
            ZStack {
                ForEach(0..<12, id: \.self) { i in
                    Capsule()
                        .fill(Color(hex: 0xFFE9A0, opacity: 0.06))
                        .frame(width: 10, height: 110)
                        .offset(y: -115)
                        .rotationEffect(.degrees(Double(i) * 30))
                }
            }
            .rotationEffect(.degrees(rayos ? 360 : 0))
            .position(x: 160, y: 150)

            Circle()
                .fill(RadialGradient(colors: [Paleta.oro.opacity(0.38), .clear], center: .center, startRadius: 0, endRadius: 100))
                .frame(width: 200, height: 200)
                .position(x: 160, y: 150)

            Image(systemName: "key.fill")
                .font(.system(size: 120))
                .foregroundStyle(LinearGradient(colors: [Color(hex: 0xFFF1B0), Paleta.oro, Color(hex: 0xD99A00)], startPoint: .top, endPoint: .bottom))
                .shadow(color: Paleta.oro.opacity(0.5), radius: 18)
                .rotationEffect(.degrees(flotar ? -24 : -32))
                .offset(y: flotar ? -6 : 4)
                .scaleEffect(aparecer ? 1 : 0.2)
                .rotationEffect(.degrees(aparecer ? 0 : -90))
                .opacity(aparecer ? 1 : 0)
                .position(x: 160, y: 150)

            ForEach(0..<4, id: \.self) { i in
                let puntos: [CGPoint] = [CGPoint(x: 80, y: 80), CGPoint(x: 246, y: 96), CGPoint(x: 232, y: 222), CGPoint(x: 92, y: 214)]
                Ciclo(periodo: 2.6, retraso: Double(i) * 0.6) { f in
                    Image(systemName: "sparkle")
                        .font(.system(size: [16, 20, 13, 11][i], weight: .bold))
                        .foregroundStyle(Color(hex: 0xFFF3B8))
                        .opacity(0.2 + 0.8 * abs(sin(f * .pi)))
                }
                .frame(width: 30, height: 30)
                .position(puntos[i])
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1, dampingFraction: 0.6).delay(0.2)) { aparecer = true }
            withAnimation(.easeInOut(duration: 2).delay(1.4).repeatForever(autoreverses: true)) { flotar = true }
            withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) { rayos = true }
        }
    }
}

#Preview {
    HistoriaView(alTerminar: {})
}
