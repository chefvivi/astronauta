import SwiftUI

/// Panel para mandarle una alerta a Mamá cuando yo quiera (ahorita o programada), además de la de las 11:30.
struct CentroDeControlView: View {
    @Environment(\.dismiss) private var cerrar
    @AppStorage("temaMama") private var temaMama = Secretos.temaMama
    @AppStorage("temaPrueba") private var temaPrueba = Secretos.temaPrueba

    enum Destino: String, CaseIterable, Identifiable {
        case prueba = "Prueba (yo)"
        case mama = "Mamá"
        var id: Self { self }
    }

    @State private var destino: Destino = .prueba
    @State private var eleccion = 0
    @State private var tituloPropio = ""
    @State private var mensajePropio = ""
    @State private var programar = false
    @State private var cuando = Date().addingTimeInterval(3600)
    @State private var enviando = false
    @State private var resultado: (ok: Bool, texto: String)?
    @State private var confirmar = false
    @State private var exitos = 0
    @State private var errores = 0

    /// Mensajes listos: las 7 alertas de todos los días (con el día de hoy) y algunos extra.
    private var opciones: [(titulo: String, texto: String)] {
        let n = Mision.dia()
        return Mision.alertas.map { Self.llenar($0, dia: n) } + Self.extras
    }

    private static let extras: [(titulo: String, texto: String)] = [
        ("Mensaje urgente del astronauta", "¡Mamá! ¿Estás ahí? Solo quería decirte que te quiero… y que sigo encerrado. 🥺"),
        ("Buenos días desde el espacio", "Hoy es un gran día para liberar a un astronauta. ☀️"),
        ("Buenas noches desde la celda 01", "El astronauta se va a dormir. Va a soñar con salir a explorar. Buenas noches, Mamá. 🌙"),
        ("Alerta de oferta", "El Centro de Control detectó que el rescate podría estar en oferta. Vale la pena revisar. 👀")
    ]

    private static func llenar(_ a: (titulo: String, texto: String), dia n: Int) -> (titulo: String, texto: String) {
        func f(_ s: String) -> String {
            s.replacingOccurrences(of: "{dia}", with: "\(n)").replacingOccurrences(of: "{dias}", with: n == 1 ? "día" : "días")
        }
        return (f(a.titulo), f(a.texto))
    }

    private var esPropio: Bool { eleccion >= opciones.count }

    private var actual: (titulo: String, texto: String) {
        if esPropio {
            let t = tituloPropio.trimmingCharacters(in: .whitespacesAndNewlines)
            return (t.isEmpty ? "Mensaje del Centro de Control" : t, mensajePropio.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return opciones[eleccion]
    }

    private var temaActual: String { destino == .mama ? temaMama : temaPrueba }
    private var listo: Bool { Ntfy.temaValido(temaActual) && !actual.texto.isEmpty && !enviando }
    private var rango: ClosedRange<Date> { Date().addingTimeInterval(60)...Date().addingTimeInterval(3 * 24 * 3600 - 60) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Enviar a", selection: $destino) {
                        ForEach(Destino.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Enviar a")
                } footer: {
                    Text(destino == .mama ? "Le llega a tu mamá en su celular, por ntfy." : "Te llega a ti en ntfy, para probar sin molestar a tu mamá.")
                }
                .listRowBackground(Color.white.opacity(0.07))

                Section("Mensaje") {
                    Picker("Elegir", selection: $eleccion) {
                        ForEach(opciones.indices, id: \.self) { i in Text(opciones[i].titulo).tag(i) }
                        Text("✍️ Escribir el mío").tag(opciones.count)
                    }
                    if esPropio {
                        TextField("Título (opcional)", text: $tituloPropio)
                        TextField("Escribe tu mensaje…", text: $mensajePropio, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
                .listRowBackground(Color.white.opacity(0.07))

                Section("Así le va a llegar") {
                    vistaPrevia
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))

                Section {
                    Toggle("Programar para después", isOn: $programar.animation())
                    if programar {
                        DatePicker("Hora", selection: $cuando, in: rango, displayedComponents: [.date, .hourAndMinute])
                    }
                } header: {
                    Text("¿Cuándo?")
                } footer: {
                    Text("Se puede programar hasta 3 días después. Si no, llega ahorita.")
                }
                .listRowBackground(Color.white.opacity(0.07))

                Section {
                    Button {
                        if destino == .mama { confirmar = true } else { Task { await enviar() } }
                    } label: {
                        HStack {
                            Spacer()
                            if enviando {
                                ProgressView().tint(.white)
                            } else {
                                Label(programar ? "Programar alerta" : "Enviar ahora", systemImage: "paperplane.fill")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            Spacer()
                        }
                        .foregroundStyle(.white)
                        .frame(height: 50)
                        .background(listo ? Paleta.botonAzul : LinearGradient(colors: [.gray.opacity(0.4)], startPoint: .top, endPoint: .bottom),
                                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(Presionable())
                    .disabled(!listo)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())

                    if let resultado {
                        Label(resultado.texto, systemImage: resultado.ok ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(resultado.ok ? Paleta.verde : Paleta.naranja)
                            .font(.system(size: 15, weight: .semibold))
                            .listRowBackground(Color.clear)
                    }
                }

                Section {
                    DisclosureGroup("Temas de ntfy") {
                        campoTema("Mamá", texto: $temaMama)
                        campoTema("Prueba", texto: $temaPrueba)
                    }
                } footer: {
                    Text("Se guardan solo en este iPhone. No se suben a GitHub.")
                }
                .listRowBackground(Color.white.opacity(0.07))
            }
            .scrollContentBackground(.hidden)
            .background(FondoEspacial(conLuna: false))
            .navigationTitle("Centro de Control")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { cerrar() }
                }
            }
            .confirmationDialog("¿Mandarle esta alerta a tu mamá?", isPresented: $confirmar, titleVisibility: .visible) {
                Button(programar ? "Sí, programarla" : "Sí, mandarla") { Task { await enviar() } }
                Button("Cancelar", role: .cancel) {}
            }
            .sensoryFeedback(.success, trigger: exitos)
            .sensoryFeedback(.error, trigger: errores)
            .onChange(of: destino) { resultado = nil }
            .onChange(of: eleccion) { resultado = nil }
        }
    }

    /// Imitación de cómo se ve la notificación en el celular.
    private var vistaPrevia: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(Color(hex: 0x338574))
                .frame(width: 38, height: 38)
                .overlay(Image(systemName: "terminal.fill").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white))
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("🚀 " + actual.titulo)
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Text(programar ? cuando.formatted(date: .omitted, time: .shortened) : "Ahora")
                        .font(.system(size: 13))
                        .foregroundStyle(Paleta.texto3)
                }
                Text(actual.texto.isEmpty ? "Escribe tu mensaje…" : actual.texto)
                    .font(.system(size: 15))
                    .foregroundStyle(actual.texto.isEmpty ? Paleta.texto3 : Paleta.texto2)
                    .lineLimit(4)
            }
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func campoTema(_ nombre: String, texto: Binding<String>) -> some View {
        LabeledContent(nombre) {
            TextField("nombre-del-tema", text: texto)
                .multilineTextAlignment(.trailing)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(Ntfy.temaValido(texto.wrappedValue) ? Paleta.texto2 : Paleta.naranja)
        }
    }

    private func enviar() async {
        enviando = true
        resultado = nil
        let quien = destino == .mama ? "a tu mamá" : "a tu tema de prueba"
        do {
            try await Ntfy.enviar(tema: temaActual, titulo: actual.titulo, mensaje: actual.texto, cuando: programar ? cuando : nil)
            resultado = (true, programar
                ? "Programada \(quien) para \(cuando.formatted(date: .abbreviated, time: .shortened))"
                : "¡Enviada \(quien)!")
            exitos += 1
        } catch {
            resultado = (false, error.localizedDescription)
            errores += 1
        }
        enviando = false
    }
}

#Preview {
    CentroDeControlView()
        .preferredColorScheme(.dark)
}
