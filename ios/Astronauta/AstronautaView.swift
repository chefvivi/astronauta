import SwiftUI

/// Piezas del astronauta (se usan para la escena donde lo arman pieza por pieza).
enum Pieza: CaseIterable {
    case mochila, piernas, brazoIzquierdo, torso, brazoDerecho, casco
}

/// Astronauta original dibujado con Canvas: casco redondo, visor oscuro y traje azul.
/// Usa el mismo sistema de coordenadas que el SVG de la web (128 × 170, centro en 0,0).
struct AstronautaView: View {
    var piezas: Set<Pieza> = Set(Pieza.allCases)

    var body: some View {
        Canvas { g, size in
            g.scaleBy(x: size.width / 128, y: size.height / 170)
            g.translateBy(x: 64, y: 86)
            for pieza in Pieza.allCases where piezas.contains(pieza) {
                Self.dibujar(pieza, en: &g)
            }
        }
        .aspectRatio(128 / 170, contentMode: .fit)
    }

    // MARK: - Colores

    private static func vertical(_ colores: [UInt32], _ y0: CGFloat, _ y1: CGFloat) -> GraphicsContext.Shading {
        .linearGradient(Gradient(colors: colores.map { Color(hex: $0) }), startPoint: CGPoint(x: 0, y: y0), endPoint: CGPoint(x: 0, y: y1))
    }
    private static let traje = vertical([0x5B90FF, 0x1D4FD6], -8, 48)
    private static let extremidad = GraphicsContext.Shading.linearGradient(
        Gradient(colors: [Color(hex: 0x4D86FF), Color(hex: 0x2254D9)]), startPoint: CGPoint(x: -50, y: -20), endPoint: CGPoint(x: 50, y: 70))
    private static let blanco = vertical([0xFFFFFF, 0xC2CCE0], -40, 80)
    private static let mochilaColor = vertical([0xE4EAF6, 0x97A4C0], -12, 48)
    private static let cascoColor = GraphicsContext.Shading.radialGradient(
        Gradient(stops: [.init(color: .white, location: 0), .init(color: Color(hex: 0xE3E9F5), location: 0.6), .init(color: Color(hex: 0xA6B2CA), location: 1)]),
        center: CGPoint(x: -13, y: -64), startRadius: 0, endRadius: 70)
    private static let visorColor = GraphicsContext.Shading.linearGradient(
        Gradient(stops: [.init(color: Color(hex: 0x2C3D6E), location: 0), .init(color: Color(hex: 0x0C1226), location: 0.55), .init(color: Color(hex: 0x05070F), location: 1)]),
        startPoint: CGPoint(x: -10, y: -64), endPoint: CGPoint(x: 8, y: -20))

    private static func circulo(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
    }

    // MARK: - Dibujo

    static func dibujar(_ pieza: Pieza, en g: inout GraphicsContext) {
        switch pieza {
        case .mochila:
            g.fill(Path(roundedRect: CGRect(x: -40, y: -12, width: 80, height: 60), cornerRadius: 18), with: mochilaColor)

        case .piernas:
            var izquierda = Path(); izquierda.move(to: CGPoint(x: -14, y: 38)); izquierda.addLine(to: CGPoint(x: -17, y: 64))
            var derecha = Path(); derecha.move(to: CGPoint(x: 14, y: 38)); derecha.addLine(to: CGPoint(x: 18, y: 62))
            let estilo = StrokeStyle(lineWidth: 22, lineCap: .round)
            g.stroke(izquierda, with: extremidad, style: estilo)
            g.stroke(derecha, with: extremidad, style: estilo)
            g.fill(Path(roundedRect: CGRect(x: -30, y: 60, width: 26, height: 17), cornerRadius: 8.5), with: blanco)
            let giro = CGAffineTransform(translationX: 19, y: 66).rotated(by: -6 * .pi / 180).translatedBy(x: -19, y: -66)
            g.fill(Path(roundedRect: CGRect(x: 6, y: 58, width: 26, height: 17), cornerRadius: 8.5).applying(giro), with: blanco)

        case .brazoIzquierdo:
            var brazo = Path()
            brazo.move(to: CGPoint(x: -29, y: 6))
            brazo.addQuadCurve(to: CGPoint(x: -51, y: 38), control: CGPoint(x: -48, y: 18))
            g.stroke(brazo, with: extremidad, style: StrokeStyle(lineWidth: 18, lineCap: .round))
            g.fill(circulo(-51, 41, 10), with: blanco)

        case .torso:
            g.fill(Path(roundedRect: CGRect(x: -34, y: -8, width: 68, height: 56), cornerRadius: 24), with: traje)
            g.fill(Path(roundedRect: CGRect(x: -14, y: 5, width: 28, height: 18), cornerRadius: 5.5), with: .color(Color(hex: 0xE6ECF8)))
            g.fill(circulo(-7, 14, 2.6), with: .color(Paleta.rojo))
            g.fill(circulo(0, 14, 2.6), with: .color(Paleta.oro))
            g.fill(circulo(7, 14, 2.6), with: .color(Paleta.verde))
            // Parche de la bandera de México
            g.fill(Path(CGRect(x: 13, y: 29, width: 4, height: 8)), with: .color(Color(hex: 0x006847)))
            g.fill(Path(CGRect(x: 17, y: 29, width: 4, height: 8)), with: .color(.white))
            g.fill(Path(CGRect(x: 21, y: 29, width: 4, height: 8)), with: .color(Color(hex: 0xCE1126)))

        case .brazoDerecho:
            var brazo = Path()
            brazo.move(to: CGPoint(x: 29, y: 5))
            brazo.addQuadCurve(to: CGPoint(x: 55, y: -21), control: CGPoint(x: 49, y: -1))
            g.stroke(brazo, with: extremidad, style: StrokeStyle(lineWidth: 18, lineCap: .round))
            g.fill(circulo(56, -25, 10), with: blanco)

        case .casco:
            g.fill(Path(ellipseIn: CGRect(x: -25, y: -15.5, width: 50, height: 15)), with: .color(Color(hex: 0xC4CEE3)))
            g.fill(circulo(0, -44, 38), with: cascoColor)
            g.fill(circulo(-37, -44, 4.5), with: .color(Color(hex: 0xAAB6CC)))
            g.fill(circulo(37, -44, 4.5), with: .color(Color(hex: 0xAAB6CC)))
            let visor = Path(ellipseIn: CGRect(x: 2 - 27.5, y: -42 - 22.5, width: 55, height: 45))
            g.fill(visor, with: visorColor)
            g.stroke(visor, with: .color(Color(hex: 0x9AA6BF)), lineWidth: 2.5)
            var brillo = Path()
            brillo.move(to: CGPoint(x: -15, y: -53))
            brillo.addQuadCurve(to: CGPoint(x: 8, y: -59.5), control: CGPoint(x: -6, y: -61))
            g.stroke(brillo, with: .color(.white.opacity(0.6)), style: StrokeStyle(lineWidth: 3.6, lineCap: .round))
            g.fill(circulo(14, -53, 2.2), with: .color(.white.opacity(0.55)))
        }
    }
}

#Preview {
    ZStack {
        Paleta.fondo.ignoresSafeArea()
        AstronautaView().frame(width: 200)
    }
}
