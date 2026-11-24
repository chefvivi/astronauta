import SwiftUI

/// Una ráfaga de confeti de estrellas que sale desde un punto de la pantalla.
struct Rafaga: Identifiable {
    let id = UUID()
    let inicio = Date()
    let origen: CGPoint
    let cantidad: Int
    let semilla = Double.random(in: 0...1000)
}

/// Confeti de estrellas de colores. Cada partícula se calcula con física sencilla
/// (velocidad inicial, freno del aire y gravedad), así no hay que guardar estado por partícula.
struct ConfetiView: View {
    var rafagas: [Rafaga]

    private static let colores: [Color] = [Paleta.oro, .white, Paleta.cian, Paleta.azul, Paleta.naranja, Color(hex: 0xBF5AF2), Paleta.verde]

    var body: some View {
        TimelineView(.animation(paused: rafagas.isEmpty)) { tiempo in
            Canvas { g, _ in
                for rafaga in rafagas {
                    dibujar(rafaga, en: &g, t: tiempo.date.timeIntervalSince(rafaga.inicio))
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private func dibujar(_ r: Rafaga, en g: inout GraphicsContext, t: Double) {
        guard t >= 0, t < 4 else { return }
        let freno = 0.9
        let avance = (1 - exp(-freno * t)) / freno
        for i in 0..<r.cantidad {
            let s = r.semilla + Double(i) * 7.13
            let vida = 2.2 + pseudoAzar(s + 1) * 1.6
            guard t < vida else { continue }
            let angulo = pseudoAzar(s + 2) * 2 * .pi
            let velocidad = 220 + pseudoAzar(s + 3) * 520
            let x = r.origen.x + cos(angulo) * velocidad * avance
            let y = r.origen.y + (sin(angulo) * velocidad - 260) * avance + 170 * t * t
            let k = t / vida
            var c = g
            c.opacity = k > 0.7 ? (1 - k) / 0.3 : 1
            c.translateBy(x: x, y: y)
            c.rotate(by: .radians(pseudoAzar(s + 5) * 6 + (pseudoAzar(s + 6) - 0.5) * 10 * t))
            let color = Self.colores[Int(pseudoAzar(s + 7) * Double(Self.colores.count)) % Self.colores.count]
            c.fill(Self.estrella(radio: 3 + pseudoAzar(s + 4) * 6), with: .color(color))
        }
    }

    static func estrella(radio: Double) -> Path {
        var p = Path()
        for i in 0..<10 {
            let r = i.isMultiple(of: 2) ? radio : radio * 0.45
            let a = -Double.pi / 2 + Double(i) * .pi / 5
            let punto = CGPoint(x: cos(a) * r, y: sin(a) * r)
            if i == 0 { p.move(to: punto) } else { p.addLine(to: punto) }
        }
        p.closeSubpath()
        return p
    }
}
