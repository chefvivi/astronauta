import SwiftUI

/// Número "aleatorio" que siempre da lo mismo para la misma semilla (0...1).
func pseudoAzar(_ semilla: Double) -> Double {
    let x = sin(semilla * 12.9898) * 43758.5453
    return x - floor(x)
}

/// Estrellas en tres capas con parallax, brillo aleatorio y estrellas fugaces.
struct CieloView: View {
    @Environment(\.accessibilityReduceMotion) private var reducirMovimiento

    private struct Estrella {
        let x, y, radio, brillo, frecuencia, fase: Double
        let capa: Int
        let color: Color
    }

    // Capa lejana, media y cercana: cada una se mueve a distinta velocidad.
    private static let velocidades: [Double] = [2.2, 5, 9]
    private static let estrellas: [Estrella] = {
        let capas: [(cantidad: Int, radio: ClosedRange<Double>, brillo: ClosedRange<Double>)] = [
            (120, 0.35...0.8, 0.25...0.6),
            (50, 0.6...1.15, 0.4...0.85),
            (16, 1.0...1.7, 0.65...1.0)
        ]
        let tonos: [Color] = [.white, .white, Color(hex: 0xD2E1FF), Color(hex: 0xFFF1D6)]
        var lista: [Estrella] = []
        var s = 1.0
        for (capa, c) in capas.enumerated() {
            for _ in 0..<c.cantidad {
                func r() -> Double { s += 1; return pseudoAzar(s) }
                lista.append(Estrella(
                    x: r(), y: r(),
                    radio: c.radio.lowerBound + r() * (c.radio.upperBound - c.radio.lowerBound),
                    brillo: c.brillo.lowerBound + r() * (c.brillo.upperBound - c.brillo.lowerBound),
                    frecuencia: 0.5 + r() * 1.3, fase: r() * 6.28,
                    capa: capa, color: tonos[Int(r() * Double(tonos.count)) % tonos.count]))
            }
        }
        return lista
    }()

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 60, paused: reducirMovimiento)) { tiempo in
            Canvas { g, size in
                let t = reducirMovimiento ? 0 : tiempo.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 100_000)
                dibujarEstrellas(&g, size: size, t: t)
                if !reducirMovimiento { dibujarFugaz(&g, size: size, t: t) }
            }
        }
        .allowsHitTesting(false)
    }

    private func dibujarEstrellas(_ g: inout GraphicsContext, size: CGSize, t: Double) {
        for e in Self.estrellas {
            var x = (e.x * size.width - t * Self.velocidades[e.capa]).truncatingRemainder(dividingBy: size.width)
            if x < 0 { x += size.width }
            let y = e.y * size.height
            let titileo = reducirMovimiento ? 1 : 0.62 + 0.38 * sin(t * e.frecuencia + e.fase)
            let alfa = e.brillo * titileo
            g.fill(Path(ellipseIn: CGRect(x: x - e.radio, y: y - e.radio, width: e.radio * 2, height: e.radio * 2)),
                   with: .color(e.color.opacity(alfa)))
            if e.radio > 1.25 {
                let halo = e.radio * 3.2
                g.fill(Path(ellipseIn: CGRect(x: x - halo, y: y - halo, width: halo * 2, height: halo * 2)),
                       with: .color(e.color.opacity(alfa * 0.12)))
            }
        }
    }

    /// Una estrella fugaz cada ~9 segundos, en un lugar distinto cada vez.
    private func dibujarFugaz(_ g: inout GraphicsContext, size: CGSize, t: Double) {
        let periodo = 9.0, duracion = 0.9
        let ciclo = floor(t / periodo)
        let fase = t - ciclo * periodo - pseudoAzar(ciclo) * 4
        guard fase > 0, fase < duracion else { return }
        let k = fase / duracion
        let angulo = (200 + pseudoAzar(ciclo + 0.5) * 18) * .pi / 180
        let velocidad = 900 + pseudoAzar(ciclo + 0.7) * 400
        let inicio = CGPoint(x: size.width * (0.35 + pseudoAzar(ciclo + 0.3) * 0.75), y: size.height * pseudoAzar(ciclo + 0.9) * 0.35)
        let dx = cos(angulo), dy = -sin(angulo)
        let cabeza = CGPoint(x: inicio.x + dx * velocidad * fase, y: inicio.y + dy * velocidad * fase)
        let largo = 160.0
        let cola = CGPoint(x: cabeza.x - dx * largo, y: cabeza.y - dy * largo)
        let alfa = sin(.pi * k)
        var trazo = Path()
        trazo.move(to: cabeza)
        trazo.addLine(to: cola)
        g.stroke(trazo, with: .linearGradient(
            Gradient(colors: [.white.opacity(0.9 * alfa), Color(hex: 0xB4D2FF, opacity: 0)]),
            startPoint: cabeza, endPoint: cola), style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
    }
}

/// Luna que rota lento: la textura de cráteres se desliza dentro de un círculo con sombra fija.
struct LunaView: View {
    @Environment(\.accessibilityReduceMotion) private var reducirMovimiento
    @State private var girando = false

    var body: some View {
        GeometryReader { geo in
            let lado = geo.size.width
            ZStack {
                RadialGradient(colors: [Color(hex: 0x8E98B2), Color(hex: 0x5D6884), Color(hex: 0x363F5C), Color(hex: 0x1F2640)],
                               center: UnitPoint(x: 0.7, y: 0.3), startRadius: 0, endRadius: lado * 0.75)
                HStack(spacing: 0) {
                    Crateres().frame(width: lado, height: lado)
                    Crateres().frame(width: lado, height: lado)
                }
                .frame(width: lado * 2, height: lado, alignment: .leading)
                .offset(x: girando ? -lado / 2 : lado / 2)
                RadialGradient(stops: [.init(color: .clear, location: 0.34), .init(color: Paleta.fondo.opacity(0.55), location: 0.64), .init(color: Paleta.fondo.opacity(0.94), location: 0.82)],
                               center: UnitPoint(x: 0.74, y: 0.26), startRadius: 0, endRadius: lado * 0.72)
            }
            .frame(width: lado, height: lado)
            .clipShape(Circle())
            .shadow(color: Color(hex: 0x648CFF, opacity: 0.12), radius: 45)
        }
        .onAppear {
            guard !reducirMovimiento else { return }
            withAnimation(.linear(duration: 260).repeatForever(autoreverses: false)) { girando = true }
        }
        .allowsHitTesting(false)
    }

    private struct Crateres: View {
        var body: some View {
            Canvas { g, size in
                let s = size.width / 200
                var semilla = 11.0
                func r() -> Double { semilla += 1; return pseudoAzar(semilla) }
                for _ in 0..<6 {
                    let rx = 16 + r() * 26, ry = 10 + r() * 20
                    let cx = rx + r() * (200 - 2 * rx), cy = ry + r() * (200 - 2 * ry)
                    g.fill(Path(ellipseIn: CGRect(x: (cx - rx) * s, y: (cy - ry) * s, width: rx * 2 * s, height: ry * 2 * s)),
                           with: .color(Color(hex: 0x202A4A, opacity: 0.16 + r() * 0.14)))
                }
                for _ in 0..<30 {
                    let radio = 1.5 + r() * r() * 13
                    let cx = radio + 2 + r() * (196 - 2 * radio), cy = 4 + r() * 192
                    g.fill(Path(ellipseIn: CGRect(x: (cx - radio) * s, y: (cy - radio) * s, width: radio * 2 * s, height: radio * 2 * s)),
                           with: .color(Color(hex: 0x1B2240, opacity: 0.26)))
                    let borde = radio * 0.78
                    g.stroke(Path(ellipseIn: CGRect(x: (cx + radio * 0.2 - borde) * s, y: (cy - radio * 0.2 - borde) * s, width: borde * 2 * s, height: borde * 2 * s)),
                             with: .color(.white.opacity(0.08)), lineWidth: max(0.5, radio * 0.14) * s)
                }
            }
        }
    }
}
