import SwiftUI

/// Pantalla principal: "Hay un astronauta encerrado".
struct ContentView: View {
    @AppStorage("historiaVista") private var historiaVista = false
    @Environment(\.scenePhase) private var fase
    @Environment(\.openURL) private var abrirURL

    @State private var mostrarHistoria = false
    @State private var mostrarHoja = false
    @State private var liberado = false
    @State private var repeticion = 0
    @State private var aviso: String?
    @State private var rafagas: [Rafaga] = []
    @State private var marcoCelda: CGRect = .zero
    @State private var escribiendo = true
    @State private var suplica = 0
    @State private var cambioModo = 0
    @State private var mostrarCentro = false

    private static let suplicas = ["¡Sácame de aquí! 🥺", "Psst… la llave la tiene Mamá", "Sigo aquí. Flotando. Esperando.", "Hola, Mamá 👋", "¿Ya viste el candado rojo?"]

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { tiempo in
            let n = Mision.dia(tiempo.date)
            ScrollView {
                VStack(spacing: 0) {
                    encabezado
                    titulos(dia: n)
                    celda
                    tarjetas(dia: n)
                    chat(dia: n)
                    botonPrincipal
                    pie
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
                .frame(maxWidth: 460)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .background(FondoEspacial())
        .overlay(ConfetiView(rafagas: rafagas))
        .overlay(alignment: .top) { avisoFlotante }
        .sheet(isPresented: $mostrarHoja) {
            HojaCandado(dia: Mision.dia(), alDejarlo: {
                mostrarHoja = false
                mostrarAviso("Está bien… el astronauta espera un día más 🥲", en: 0.4)
            })
        }
        .fullScreenCover(isPresented: $mostrarHistoria) {
            HistoriaView {
                historiaVista = true
                mostrarHistoria = false
                Task { await Notificaciones.programar() }
            }
        }
        .sensoryFeedback(.success, trigger: cambioModo)
        .onAppear {
            // Abrir la app con el argumento "-liberado YES" muestra directo el modo liberado.
            if UserDefaults.standard.bool(forKey: "liberado") {
                liberado = true
                Task { try? await Task.sleep(for: .seconds(0.6)); repetirLiberacion() }
            }
            if !historiaVista { mostrarHistoria = true }
            Task {
                try? await Task.sleep(for: .seconds(1.7))
                withAnimation(.easeOut(duration: 0.45)) { escribiendo = false }
            }
        }
        .onChange(of: fase) { _, nueva in
            if nueva == .active, historiaVista { Task { await Notificaciones.programar() } }
        }
    }

    // MARK: - Encabezado

    private var encabezado: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "scope").font(.system(size: 15, weight: .semibold))
                (Text("Centro de Control").foregroundStyle(.white) + Text(" · MTY").foregroundStyle(Paleta.texto2))
                    .font(.system(size: 13, weight: .semibold))
            }
            Spacer()
            HStack(spacing: 7) {
                PuntoVivo(color: liberado ? Paleta.verde : Paleta.rojo)
                Text(liberado ? "LIBERADO" : "EN VIVO")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.86))
            }
            .padding(.leading, 9).padding(.trailing, 11)
            .frame(height: 26)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.08)))
        }
        .frame(height: 44)
    }

    private func titulos(dia n: Int) -> some View {
        VStack(spacing: 10) {
            Text(liberado ? "MISIÓN CUMPLIDA" : "MISIÓN · DÍA \(n)")
                .font(.system(size: 12, weight: .semibold))
                .tracking(1.7)
                .foregroundStyle(Paleta.cian)
            Text(liberado ? "¡Astronauta liberado!" : "Hay un astronauta encerrado")
                .font(.system(size: 34, weight: .bold))
                .tracking(-0.8)
                .multilineTextAlignment(.center)
                .foregroundStyle(liberado
                    ? LinearGradient(colors: [Color(hex: 0xFFE58A), .white, Color(hex: 0x9FE3FF)], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [.white, Color(hex: 0xC8D2EA)], startPoint: .top, endPoint: .bottom))
            Text(liberado ? "Gracias, Mamá. Ya va en camino a casa." : "Solo una persona tiene la llave.")
                .font(.system(size: 17))
                .foregroundStyle(Paleta.texto2)
        }
        .contentTransition(.opacity)
        .animation(.easeInOut(duration: 0.5), value: liberado)
        .padding(.top, 22)
    }

    // MARK: - Celda

    private var celda: some View {
        VStack(spacing: 14) {
            CeldaView(liberado: liberado, repeticion: repeticion,
                      alTocarCandado: {
                          Task {
                              try? await Task.sleep(for: .seconds(0.42))
                              mostrarHoja = true
                          }
                      },
                      alTocarAstronauta: {
                          mostrarAviso(liberado ? "¡Gracias, Mamá! 💙" : Self.suplicas[suplica % Self.suplicas.count])
                          suplica += 1
                      })
                .frame(maxWidth: 300)
                .background(
                    RadialGradient(colors: [(liberado ? Paleta.oro : Paleta.azul).opacity(0.28), .clear], center: .center, startRadius: 0, endRadius: 220)
                        .frame(width: 440, height: 440)
                        .allowsHitTesting(false)
                )
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { marcoCelda = $0 }

            Button {
                if liberado { repetirLiberacion() } else { mostrarHoja = true }
            } label: {
                HStack(spacing: 8) {
                    PuntoVivo(color: liberado ? Paleta.verde : Paleta.rojo, pulso: false)
                    Text(liberado ? "Celda 01 · Abierta" : "Celda 01 · Bloqueada").foregroundStyle(Paleta.texto2)
                    + Text(liberado ? " — ver otra vez" : " — toca el candado").foregroundStyle(Paleta.texto3)
                }
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 14)
                .frame(height: 34)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().strokeBorder(.white.opacity(0.08)))
            }
            .buttonStyle(Presionable())
        }
        .padding(.top, 18)
    }

    // MARK: - Tarjetas

    private func tarjetas(dia n: Int) -> some View {
        let animo = Mision.animo(dia: n)
        return VStack(spacing: 12) {
            HStack(spacing: 12) {
                Tarjeta(icono: "calendar", titulo: liberado ? "Estuvo encerrado" : "Días encerrado") {
                    (Text("\(n)") + Text(n == 1 ? " día" : " días").font(.system(size: 15, weight: .semibold)).foregroundStyle(Paleta.texto3))
                        .font(.system(size: 40, weight: .bold))
                } pie: { Text("Desde el 23/11/2026") }
                Tarjeta(icono: "tag", titulo: "Rescate") {
                    Text(liberado ? "Pagado" : "$1,399")
                        .font(.system(size: liberado ? 34 : 40, weight: .bold))
                        .foregroundStyle(liberado ? Paleta.verde : .white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                } pie: { Text(liberado ? "✓ Gracias, Mamá 💙" : "MXN · una sola vez") }
            }

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Label("Ánimo del astronauta", systemImage: "heart")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Paleta.texto2)
                    Spacer()
                    Text(liberado ? "100%" : "\(animo.porcentaje)%")
                        .font(.system(size: 13, weight: .semibold).monospacedDigit())
                        .foregroundStyle(Paleta.texto2)
                }
                Text(liberado ? "Feliz y libre 🤩" : animo.nombre)
                    .font(.system(size: 26, weight: .bold))
                    .padding(.top, 8)
                BarraAnimo(porcentaje: liberado ? 100 : animo.porcentaje, libre: liberado)
                    .padding(.top, 12)
                if !liberado {
                    Divider().overlay(.white.opacity(0.07)).padding(.top, 16)
                    Text("Otro día encerrado en")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Paleta.texto3)
                        .padding(.top, 14)
                    CuentaRegresiva().padding(.top, 8)
                }
                Text(liberado ? "Respira tranquilo: ya está libre." : "A medianoche (hora de Monterrey) se suma un día")
                    .font(.system(size: 12))
                    .foregroundStyle(Paleta.texto3)
                    .padding(.top, 8)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .vidrio()
        }
        .padding(.top, 28)
    }

    // MARK: - Mensaje del astronauta

    private func chat(dia n: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                AstronautaView(piezas: [.casco])
                    .frame(width: 30, height: 40)
                    .frame(width: 22, height: 22)
                    .offset(y: 8)
                (Text("Mensaje del astronauta").foregroundStyle(Paleta.texto2) + Text(" · hoy").foregroundStyle(Paleta.texto3))
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.leading, 4)

            ZStack(alignment: .leading) {
                Text(liberado ? "¡SOY LIBRE! 🚀 Gracias, Mamá. Ya voy directo a la repisa de Vivi. Te debo una galaxia entera." : Mision.mensaje(dia: n))
                    .font(.system(size: 16))
                    .lineSpacing(3)
                    .opacity(escribiendo ? 0 : 1)
                    .offset(y: escribiendo ? 4 : 0)
                if escribiendo { PuntosEscribiendo() }
            }
            .padding(.horizontal, 16).padding(.vertical, 13)
            .frame(minHeight: 46, alignment: .leading)
            .background(.ultraThinMaterial, in: UnevenRoundedRectangle(topLeadingRadius: 22, bottomLeadingRadius: 7, bottomTrailingRadius: 22, topTrailingRadius: 22, style: .continuous))
            .overlay(UnevenRoundedRectangle(topLeadingRadius: 22, bottomLeadingRadius: 7, bottomTrailingRadius: 22, topTrailingRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.09)))
            .padding(.trailing, 36)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 22)
    }

    // MARK: - Botón principal y pie

    private var botonPrincipal: some View {
        VStack(spacing: 10) {
            Button {
                if liberado { repetirLiberacion() } else { abrirURL(Mision.urlProducto) }
            } label: {
                Label(liberado ? "Ver el rescate otra vez" : "Liberar al astronauta",
                      systemImage: liberado ? "arrow.counterclockwise" : "key.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(liberado ? Paleta.botonVerde : Paleta.botonAzul, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: (liberado ? Paleta.verde : Paleta.azul).opacity(0.55), radius: 16, y: 10)
            }
            .buttonStyle(Presionable())
            Text(liberado ? "Misión cumplida · #40921" : "Abre la página del producto · #40921")
                .font(.system(size: 12))
                .foregroundStyle(Paleta.texto3)
        }
        .padding(.top, 28)
    }

    private var pie: some View {
        VStack(spacing: 12) {
            (Text("Misión diseñada por ") + Text("Vivi").bold().foregroundStyle(Paleta.texto2) + Text(" · solo Mamá tiene la llave"))
                .font(.system(size: 12))
                .foregroundStyle(Paleta.texto3)
                // Truco secreto: mantener presionado 1 segundo cambia al modo "liberado".
                .onLongPressGesture(minimumDuration: 1) {
                    liberado.toggle()
                    cambioModo += 1
                    if liberado { repetirLiberacion() }
                }
            Button { mostrarCentro = true } label: {
                Label("Centro de Control · mandar alerta", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .frame(height: 40)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().strokeBorder(.white.opacity(0.1)))
            }
            .buttonStyle(Presionable())
            .sheet(isPresented: $mostrarCentro) { CentroDeControlView() }
            HStack(spacing: 18) {
                Button("▶︎ Ver la historia") { mostrarHistoria = true }
                Button("🔔 Probar notificación") {
                    Task { await Notificaciones.probar() }
                    mostrarAviso("Llega en 5 segundos: bloquea el teléfono 🔒")
                }
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Paleta.cian)
        }
        .padding(.top, 36)
    }

    // MARK: - Acciones

    private func repetirLiberacion() {
        repeticion += 1
        let centro = CGPoint(x: marcoCelda.midX, y: marcoCelda.minY + marcoCelda.height * 0.45)
        let ancho = marcoCelda.maxX + marcoCelda.minX
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            rafagas.append(Rafaga(origen: centro, cantidad: 140))
            try? await Task.sleep(for: .seconds(1.8))
            rafagas.append(Rafaga(origen: CGPoint(x: centro.x, y: centro.y - 60), cantidad: 90))
            try? await Task.sleep(for: .seconds(0.9))
            rafagas.append(Rafaga(origen: CGPoint(x: ancho * 0.2, y: marcoCelda.minY), cantidad: 50))
            rafagas.append(Rafaga(origen: CGPoint(x: ancho * 0.8, y: marcoCelda.minY), cantidad: 50))
            try? await Task.sleep(for: .seconds(4.5))
            rafagas.removeAll { Date().timeIntervalSince($0.inicio) > 4 }
        }
    }

    private func mostrarAviso(_ texto: String, en retraso: Double = 0) {
        Task {
            try? await Task.sleep(for: .seconds(retraso))
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) { aviso = texto }
            try? await Task.sleep(for: .seconds(2.6))
            if aviso == texto { withAnimation(.easeIn(duration: 0.3)) { aviso = nil } }
        }
    }

    @ViewBuilder private var avisoFlotante: some View {
        if let aviso {
            Text(aviso)
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 18).padding(.vertical, 12)
                .background(.thinMaterial, in: Capsule())
                .overlay(Capsule().strokeBorder(.white.opacity(0.1)))
                .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                .padding(.top, 6)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Piezas reutilizables

/// Botones que se encogen un poquito al tocarlos.
struct Presionable: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

/// Punto rojo (o verde) con un anillo que late, como el "EN VIVO".
struct PuntoVivo: View {
    var color: Color
    var pulso = true
    @State private var latir = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 7, height: 7)
            .shadow(color: color.opacity(0.8), radius: 4)
            .background(
                Circle()
                    .stroke(color, lineWidth: 1.5)
                    .frame(width: 15, height: 15)
                    .scaleEffect(latir ? 1.6 : 0.4)
                    .opacity(pulso ? (latir ? 0 : 0.7) : 0)
            )
            .onAppear {
                guard pulso else { return }
                withAnimation(.easeOut(duration: 2.4).repeatForever(autoreverses: false)) { latir = true }
            }
    }
}

private struct Tarjeta<Valor: View, Pie: View>: View {
    let icono: String
    let titulo: String
    @ViewBuilder var valor: Valor
    @ViewBuilder var pie: Pie

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Label(titulo, systemImage: icono)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Paleta.texto2)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            valor.padding(.top, 10)
            pie
                .font(.system(size: 12))
                .foregroundStyle(Paleta.texto3)
                .padding(.top, 8)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .vidrio()
    }
}

private struct BarraAnimo: View {
    var porcentaje: Int
    var libre: Bool
    @State private var brillo = false

    private var colores: [Color] {
        if libre { return [Paleta.verde, Paleta.cian] }
        if porcentaje < 25 { return [Paleta.rojo, Paleta.naranja] }
        if porcentaje < 60 { return [Paleta.naranja, Paleta.oro] }
        return [Color(hex: 0x3D7BFF), Paleta.cian]
    }

    var body: some View {
        GeometryReader { geo in
            let ancho = geo.size.width * CGFloat(porcentaje) / 100
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.08))
                Capsule()
                    .fill(LinearGradient(colors: colores, startPoint: .leading, endPoint: .trailing))
                    .frame(width: ancho)
                    .overlay(
                        LinearGradient(colors: [.clear, .white.opacity(0.45), .clear], startPoint: .leading, endPoint: .trailing)
                            .frame(width: ancho * 0.4)
                            .offset(x: brillo ? ancho : -ancho * 0.4)
                    )
                    .clipShape(Capsule())
                    .animation(.easeOut(duration: 0.9), value: porcentaje)
            }
        }
        .frame(height: 8)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.2).delay(1).repeatForever(autoreverses: false)) { brillo = true }
        }
    }
}

/// Horas, minutos y segundos para que se sume otro día.
private struct CuentaRegresiva: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { tiempo in
            let faltan = max(0, Int(Mision.siguienteMedianoche(tiempo.date).timeIntervalSince(tiempo.date)))
            HStack(spacing: 0) {
                unidad(faltan / 3600, "HORAS")
                unidad(faltan % 3600 / 60, "MIN")
                unidad(faltan % 60, "SEG")
            }
        }
    }

    private func unidad(_ valor: Int, _ nombre: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(String(format: "%02d", valor))
                .font(.system(size: 32, weight: .semibold).monospacedDigit())
                .contentTransition(.numericText(countsDown: true))
            Text(nombre)
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.9)
                .foregroundStyle(Paleta.texto3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PuntosEscribiendo: View {
    var body: some View {
        Ciclo(periodo: 1.2) { f in
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    let fase = (f - Double(i) * 0.12 + 1).truncatingRemainder(dividingBy: 1)
                    let subir = fase < 0.3 ? sin(fase / 0.3 * .pi) : 0
                    Circle()
                        .fill(.white.opacity(0.45 + 0.55 * subir))
                        .frame(width: 7, height: 7)
                        .offset(y: -4 * subir)
                }
            }
        }
        .frame(height: 20)
    }
}

/// La hoja que sale al tocar el candado. Se pone más dramática según los días.
private struct HojaCandado: View {
    let dia: Int
    var alDejarlo: () -> Void
    @Environment(\.openURL) private var abrirURL
    @State private var alarma = false

    var body: some View {
        let drama = Mision.drama(dia: dia)
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(LinearGradient(colors: [Paleta.rojo.opacity(0.22), Paleta.rojo.opacity(0.1)], startPoint: .top, endPoint: .bottom))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(Paleta.rojo.opacity(0.28)))
                .overlay(Image(systemName: "lock.fill").font(.system(size: 28)).foregroundStyle(Paleta.rojo))
                .frame(width: 64, height: 64)
                .shadow(color: Paleta.rojo.opacity(alarma ? 0.45 : 0), radius: 17)
                .padding(.top, 28)
            Text(drama.titulo)
                .font(.system(size: 22, weight: .bold))
                .padding(.top, 16)
            (Text("Solo se abre con una ") + Text("compra autorizada por Mamá").bold().foregroundStyle(.white) + Text("."))
                .font(.system(size: 16))
                .foregroundStyle(Paleta.texto2)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
            VStack(alignment: .leading, spacing: 3) {
                Text("REPORTE DEL DÍA \(dia)")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.1)
                    .foregroundStyle(Color(hex: 0xFF8A80))
                Text(drama.texto)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: 0xFFD6CC))
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Paleta.rojo.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Paleta.rojo.opacity(0.16)))
            .padding(.top, 14)

            Button { abrirURL(Mision.urlProducto) } label: {
                Label("Usar la llave", systemImage: "key.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).frame(height: 54)
                    .background(Paleta.botonAzul, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(Presionable())
            .padding(.top, 20)
            Button(action: alDejarlo) {
                Text("Dejarlo un día más")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Paleta.cian)
                    .frame(maxWidth: .infinity).frame(height: 54)
                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(Presionable())
            .padding(.top, 8)
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 12)
        .presentationDetents([.height(480)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(34)
        .presentationBackground(.ultraThinMaterial)
        .onAppear {
            guard drama.desde >= 4 else { return }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { alarma = true }
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
