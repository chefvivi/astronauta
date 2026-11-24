import SwiftUI

extension Color {
    /// Color a partir de un hexadecimal, por ejemplo `Color(hex: 0x0A84FF)`.
    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: opacity)
    }
}

/// Colores de la app (los mismos que la versión web).
enum Paleta {
    static let fondo = Color(hex: 0x03040B)
    static let texto2 = Color(red: 235 / 255, green: 235 / 255, blue: 245 / 255, opacity: 0.64)
    static let texto3 = Color(red: 235 / 255, green: 235 / 255, blue: 245 / 255, opacity: 0.40)
    static let azul = Color(hex: 0x0A84FF)
    static let cian = Color(hex: 0x64D2FF)
    static let rojo = Color(hex: 0xFF453A)
    static let verde = Color(hex: 0x30D158)
    static let naranja = Color(hex: 0xFF9F0A)
    static let oro = Color(hex: 0xFFD60A)

    static let botonAzul = LinearGradient(colors: [Color(hex: 0x2F8FFF), Color(hex: 0x0A6CFF)], startPoint: .top, endPoint: .bottom)
    static let botonVerde = LinearGradient(colors: [Color(hex: 0x3DDC6E), Color(hex: 0x20B14B)], startPoint: .top, endPoint: .bottom)
}

/// Tarjeta de vidrio (glassmorphism) con esquinas muy redondeadas.
struct Vidrio: ViewModifier {
    var radio: CGFloat = 26
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radio, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radio, style: .continuous)
                    .strokeBorder(.white.opacity(0.09), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.45), radius: 24, y: 16)
    }
}

extension View {
    func vidrio(radio: CGFloat = 26) -> some View { modifier(Vidrio(radio: radio)) }
}

/// Fondo de espacio profundo: degradado sutil, nebulosa, estrellas y luna.
struct FondoEspacial: View {
    var conLuna = true
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x060818), Paleta.fondo], startPoint: .top, endPoint: .bottom)
            RadialGradient(colors: [Color(hex: 0x121B4A), .clear], center: .top, startRadius: 0, endRadius: 520)
            RadialGradient(colors: [Color(hex: 0x5E5CE6, opacity: 0.16), .clear], center: UnitPoint(x: 0.85, y: 0.2), startRadius: 0, endRadius: 260)
            RadialGradient(colors: [Color(hex: 0x0A84FF, opacity: 0.10), .clear], center: UnitPoint(x: 0.1, y: 0.6), startRadius: 0, endRadius: 240)
            CieloView()
            if conLuna {
                GeometryReader { geo in
                    LunaView()
                        .frame(width: 420, height: 420)
                        .position(x: 20, y: geo.size.height + 40)
                        .opacity(0.5)
                }
            }
        }
        .ignoresSafeArea()
    }
}
