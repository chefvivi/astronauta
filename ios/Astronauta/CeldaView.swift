import SwiftUI

/// La celda con el astronauta, los barrotes y el candado rojo.
/// Se dibuja en un lienzo de 320 × 360 puntos (igual que el SVG de la web) y se escala al ancho disponible.
struct CeldaView: View {
    /// Si es `true`, cada vez que cambia `repeticion` se reproduce la animación de liberación.
    var liberado = false
    var repeticion = 0
    var alTocarCandado: () -> Void = {}
    var alTocarAstronauta: () -> Void = {}

    @Environment(\.accessibilityReduceMotion) private var reducirMovimiento
    @State private var flotar = false
    @State private var inclinar = false
    @State private var mecer = false
    @State private var anillo = false
    @State private var intentos = 0
    @State private var brinco = 0

    // Liberación
    @State private var argollaArriba = false
    @State private var candadoCae = false
    @State private var puertasAbiertas = false
    @State private var brilloLibre = false
    @State private var vuelo = Vuelo()

    struct Vuelo {
        var x: CGFloat = 0, y: CGFloat = 0, escala: CGFloat = 1, giro: Double = 0, opacidad: Double = 1
    }

    private static let pivote = UnitPoint(x: 0.5, y: 10.0 / 90.0)

    var body: some View {
        GeometryReader { geo in
            lienzo
                .frame(width: 320, height: 360)
                .scaleEffect(geo.size.width / 320, anchor: .topLeading)
        }
        .aspectRatio(320 / 360, contentMode: .fit)
        .onAppear(perform: animacionesContinuas)
        .task(id: repeticion) {
            guard liberado else { return }
            await reproducirLiberacion()
        }
    }

    private var lienzo: some View {
        ZStack {
            interior
                .frame(width: 272, height: 328)
                .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
                .position(x: 160, y: 180)

            AstronautaView()
                .frame(width: 143, height: 190)
                .keyframeAnimator(initialValue: 1.0, trigger: brinco) { vista, escala in
                    vista.scaleEffect(escala)
                } keyframes: { _ in
                    KeyframeTrack {
                        CubicKeyframe(1.08, duration: 0.18)
                        CubicKeyframe(0.97, duration: 0.18)
                        CubicKeyframe(1.0, duration: 0.24)
                    }
                }
                .rotationEffect(.degrees(inclinar ? 6 : -5))
                .offset(y: flotar ? 7 : -7)
                .scaleEffect(vuelo.escala)
                .rotationEffect(.degrees(vuelo.giro))
                .offset(x: vuelo.x, y: vuelo.y)
                .opacity(vuelo.opacidad)
                .position(x: 160, y: 165)
                .onTapGesture {
                    brinco += 1
                    alTocarAstronauta()
                }

            ZStack {
                Puerta(barrotes: [55, 95, 135], rielDesde: 20, rielHasta: 159)
                    .offset(x: puertasAbiertas ? -158 : 0)
                Puerta(barrotes: [175, 215, 255], rielDesde: 161, rielHasta: 300)
                    .offset(x: puertasAbiertas ? 158 : 0)
            }
            .frame(width: 320, height: 360)
            .mask(
                RoundedRectangle(cornerRadius: 44, style: .continuous)
                    .frame(width: 272, height: 328)
                    .position(x: 160, y: 180)
            )
            .allowsHitTesting(false)

            marco

            if !liberado {
                Circle()
                    .stroke(Paleta.rojo.opacity(0.55), lineWidth: 2)
                    .frame(width: 60, height: 60)
                    .scaleEffect(anillo ? 1.55 : 0.7)
                    .opacity(anillo ? 0 : 0.75)
                    .position(x: 160, y: 295)
                    .allowsHitTesting(false)
            }

            CandadoView(argollaArriba: argollaArriba)
                .frame(width: 80, height: 90)
                .keyframeAnimator(initialValue: 0.0, trigger: intentos) { vista, angulo in
                    vista.rotationEffect(.degrees(angulo), anchor: Self.pivote)
                } keyframes: { _ in
                    KeyframeTrack {
                        CubicKeyframe(-16, duration: 0.06)
                        CubicKeyframe(14, duration: 0.08)
                        CubicKeyframe(-11, duration: 0.08)
                        CubicKeyframe(8, duration: 0.08)
                        CubicKeyframe(-5, duration: 0.08)
                        CubicKeyframe(2, duration: 0.07)
                        CubicKeyframe(0, duration: 0.07)
                    }
                }
                .rotationEffect(.degrees(mecer ? 2.2 : -2.2), anchor: Self.pivote)
                .offset(y: candadoCae ? 150 : 0)
                .rotationEffect(.degrees(candadoCae ? 38 : 0))
                .opacity(candadoCae ? 0 : 1)
                .contentShape(Rectangle())
                .onTapGesture {
                    guard !liberado else { return }
                    intentos += 1
                    alTocarCandado()
                }
                .sensoryFeedback(.error, trigger: intentos)
                .position(x: 160, y: 297)
                .accessibilityLabel("Candado rojo")
                .accessibilityHint("Toca para intentar abrirlo")
                .accessibilityAddTraits(.isButton)
        }
    }

    private var interior: some View {
        ZStack {
            RadialGradient(colors: [Color(hex: 0x1B2A60), Color(hex: 0x0B1130), Color(hex: 0x05070F)],
                           center: UnitPoint(x: 0.5, y: 0.4), startRadius: 0, endRadius: 236)
            Path { p in
                p.move(to: CGPoint(x: 96, y: 0)); p.addLine(to: CGPoint(x: 176, y: 0))
                p.addLine(to: CGPoint(x: 226, y: 328)); p.addLine(to: CGPoint(x: 46, y: 328)); p.closeSubpath()
            }
            .fill(LinearGradient(colors: [Color(hex: 0x9FC0FF, opacity: 0.16), .clear], startPoint: .top, endPoint: .bottom))
            Path { p in
                for y in [102.0, 210] { p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: 272, y: y)) }
                for x in [68.0, 204] { p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: 328)) }
            }
            .stroke(.white.opacity(0.045), lineWidth: 1)
            RadialGradient(colors: [Paleta.oro.opacity(0.32), Paleta.cian.opacity(0.08), .clear],
                           center: UnitPoint(x: 0.5, y: 0.45), startRadius: 0, endRadius: 210)
                .opacity(brilloLibre ? 1 : 0)
            Ellipse().fill(Paleta.azul.opacity(0.10)).frame(width: 260, height: 44).position(x: 136, y: 314)
            Ellipse()
                .fill(RadialGradient(colors: [.black.opacity(0.6), .clear], center: .center, startRadius: 0, endRadius: 46))
                .frame(width: 92, height: 16)
                .scaleEffect(flotar ? 1.04 : 0.82)
                .opacity(flotar ? 0.8 : 0.45)
                .position(x: 136, y: 298)
        }
    }

    private var marco: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 44, style: .continuous)
                .stroke(LinearGradient(colors: [Color(hex: 0xC9D2E2), Color(hex: 0x5A6378), Color(hex: 0x9AA4B8), Color(hex: 0x3E465A)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 6)
                .frame(width: 272, height: 328)
                .position(x: 160, y: 180)
            RoundedRectangle(cornerRadius: 39, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
                .frame(width: 262, height: 318)
                .position(x: 160, y: 180)
            Capsule()
                .fill(Color(hex: 0x1A1F2E))
                .overlay(Capsule().stroke(Color(hex: 0x5A6378), lineWidth: 1))
                .frame(width: 44, height: 10)
                .position(x: 160, y: 16)
            Circle()
                .fill(brilloLibre ? Paleta.verde : Paleta.rojo)
                .frame(width: 6, height: 6)
                .shadow(color: brilloLibre ? Paleta.verde : Paleta.rojo, radius: 4)
                .position(x: 160, y: 16)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Animaciones

    private func animacionesContinuas() {
        guard !reducirMovimiento else { return }
        withAnimation(.easeInOut(duration: 3.25).repeatForever(autoreverses: true)) { flotar = true }
        withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) { inclinar = true }
        withAnimation(.easeInOut(duration: 2.1).repeatForever(autoreverses: true)) { mecer = true }
        withAnimation(.easeOut(duration: 2.6).repeatForever(autoreverses: false)) { anillo = true }
    }

    private func sinAnimar(_ cambios: () -> Void) {
        var t = Transaction()
        t.disablesAnimations = true
        withTransaction(t, cambios)
    }

    /// Se cae el candado, se abren los barrotes y el astronauta sale volando y regresa libre.
    private func reproducirLiberacion() async {
        sinAnimar {
            argollaArriba = false; candadoCae = false; puertasAbiertas = false; brilloLibre = false; vuelo = Vuelo()
        }
        if reducirMovimiento {
            sinAnimar {
                argollaArriba = true; candadoCae = true; puertasAbiertas = true; brilloLibre = true
                vuelo = Vuelo(y: -8, escala: 1.1)
            }
            return
        }
        try? await Task.sleep(for: .seconds(0.4))
        withAnimation(.easeOut(duration: 0.35)) { argollaArriba = true }
        try? await Task.sleep(for: .seconds(0.4))
        withAnimation(.easeIn(duration: 1.1)) { candadoCae = true }
        try? await Task.sleep(for: .seconds(0.35))
        withAnimation(.easeOut(duration: 1.4)) { puertasAbiertas = true }
        withAnimation(.easeInOut(duration: 1.6).delay(0.3)) { brilloLibre = true }
        try? await Task.sleep(for: .seconds(0.95))
        withAnimation(.easeOut(duration: 0.35)) { vuelo = Vuelo(y: 10, escala: 0.95, giro: -4) }
        try? await Task.sleep(for: .seconds(0.35))
        withAnimation(.easeIn(duration: 0.9)) { vuelo = Vuelo(x: 46, y: -560, escala: 0.6, giro: 32) }
        try? await Task.sleep(for: .seconds(0.95))
        sinAnimar { vuelo = Vuelo(x: -40, y: -460, escala: 0.75, giro: -24) }
        withAnimation(.spring(response: 1.4, dampingFraction: 0.72)) { vuelo = Vuelo(y: -8, escala: 1.1) }
    }
}

/// Media puerta de barrotes (tres barrotes y dos rieles).
private struct Puerta: View {
    let barrotes: [CGFloat]
    let rielDesde: CGFloat
    let rielHasta: CGFloat

    var body: some View {
        Canvas { g, _ in
            let metal = Gradient(stops: [
                .init(color: Color(hex: 0x363E51), location: 0), .init(color: Color(hex: 0xDBE2EE), location: 0.45),
                .init(color: Color(hex: 0x8C96AA), location: 0.7), .init(color: Color(hex: 0x3F475A), location: 1)
            ])
            for x in barrotes {
                g.fill(Path(roundedRect: CGRect(x: x, y: 8, width: 10, height: 344), cornerRadius: 5),
                       with: .linearGradient(metal, startPoint: CGPoint(x: x, y: 0), endPoint: CGPoint(x: x + 10, y: 0)))
            }
            let riel = Gradient(colors: [Color(hex: 0xD9E0EC), Color(hex: 0x7F899D), Color(hex: 0x3B4356)])
            for y in [62.0, 266] {
                g.fill(Path(roundedRect: CGRect(x: rielDesde, y: y, width: rielHasta - rielDesde, height: 10), cornerRadius: 5),
                       with: .linearGradient(riel, startPoint: CGPoint(x: 0, y: y), endPoint: CGPoint(x: 0, y: y + 10)))
                for x in barrotes {
                    g.fill(Path(ellipseIn: CGRect(x: x + 5 - 2.6, y: y + 5 - 2.6, width: 5.2, height: 5.2)),
                           with: .color(Color(hex: 0xEEF2F8, opacity: 0.85)))
                }
            }
        }
        .frame(width: 320, height: 360)
    }
}

/// Candado rojo. El pivote (donde cuelga) está en (40, 10) dentro de un cuadro de 80 × 90.
struct CandadoView: View {
    var argollaArriba = false

    var body: some View {
        ZStack {
            ZStack {
                Argolla().stroke(Color(hex: 0x5D6577), style: StrokeStyle(lineWidth: 7, lineCap: .round))
                Argolla().stroke(LinearGradient(colors: [Color(hex: 0x8D96A8), Color(hex: 0xF0F3F8), Color(hex: 0x8D96A8)],
                                                startPoint: .leading, endPoint: .trailing),
                                 style: StrokeStyle(lineWidth: 5, lineCap: .round))
            }
            .offset(y: argollaArriba ? -9 : 0)

            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: 0xFF6B61), Color(hex: 0xD70015)], startPoint: .top, endPoint: .bottom))
                .frame(width: 40, height: 34)
                .position(x: 40, y: 43)
            RoundedRectangle(cornerRadius: 3.75)
                .fill(.white.opacity(0.24))
                .frame(width: 33, height: 7.5)
                .position(x: 40, y: 32.75)
            Circle().fill(Color(hex: 0x5A0610)).frame(width: 8.4, height: 8.4).position(x: 40, y: 41)
            RoundedRectangle(cornerRadius: 1.9).fill(Color(hex: 0x5A0610)).frame(width: 3.8, height: 10).position(x: 40, y: 47)
        }
        .frame(width: 80, height: 90)
    }

    private struct Argolla: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.move(to: CGPoint(x: 29, y: 32))
            p.addLine(to: CGPoint(x: 29, y: 12))
            p.addArc(center: CGPoint(x: 40, y: 12), radius: 11, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
            p.addLine(to: CGPoint(x: 51, y: 32))
            return p
        }
    }
}

#Preview {
    ZStack {
        FondoEspacial()
        CeldaView().padding(40)
    }
}
