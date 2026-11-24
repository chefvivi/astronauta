import Foundation

/// Todos los datos de la misión: fechas, mensajes y cómo se calcula el día de encierro.
enum Mision {
    static let urlProducto = URL(string: "https://www.lego.com/es-mx/product/up-scaled-blue-astronaut-minifigure-40921")!

    /// Monterrey usa UTC-6 todo el año.
    static let zona = TimeZone(identifier: "America/Monterrey") ?? TimeZone(secondsFromGMT: -6 * 3600)!

    static var calendario: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = zona
        return cal
    }

    /// El 23/11/2026 es el día 1 de encierro.
    static let inicio: Date = DateComponents(calendar: calendario, timeZone: zona, year: 2026, month: 11, day: 23).date!

    static func dia(_ fecha: Date = .now) -> Int {
        let cal = calendario
        let dias = cal.dateComponents([.day], from: cal.startOfDay(for: inicio), to: cal.startOfDay(for: fecha)).day ?? 0
        return max(1, dias + 1)
    }

    /// A medianoche (hora de Monterrey) se suma otro día.
    static func siguienteMedianoche(_ fecha: Date = .now) -> Date {
        let cal = calendario
        return cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: fecha))!
    }

    // MARK: - Mensaje del astronauta (uno por día, cada vez más desesperado)

    static let mensajes = [
        "Hola, Mamá. Día 1 aquí adentro. Estoy bien, de verdad… solo un poquito encerrado. 🙂",
        "Día 2. Ya conté todas las estrellas que se ven desde la celda. Dos veces. ¿Me sacas?",
        "Día 3. Hoy intenté abrir el candado con la mente. Avance: 0%. Creo que sí necesito la llave.",
        "Día 4. Extraño a mi familia. Dicen que en la repisa de Vivi hay más astronautas como yo. 🥺",
        "Día 5. No tengo con quién jugar. Le lancé una pelota al barrote y no me la regresó.",
        "Día 6. Ya platico con mi reflejo en el visor. Lo malo es que siempre me da la razón.",
        "Día 7. Una semana entera aquí. Ya, por favor. Quiero salir. Quiero ver algo que no sean barrotes.",
        "Día 8. Quiero a alguien con quien hablar. Las estrellas son bonitas, pero no contestan.",
        "Día 9. Soñé que me abrías la puerta. Desperté y seguía aquí. 😢",
        "Día 10. Ya me sé de memoria cada tornillo de esta celda. Quiero ir a casa, Mamá.",
        "Día 11. Les escribí una carta a mis amigos de la repisa. No la puedo mandar: estoy encerrado.",
        "Día 12. Quiero flotar por la casa, conocer tu sala, explorar el mundo… ¿es mucho pedir? 🌍",
        "Día 13. Ya casi no me queda ánimo. Solo me queda una esperanza, y esa esperanza eres tú.",
        "Dos semanas, Mamá. Por favor. Quiero salir, quiero jugar, quiero explorar. Solo tú tienes la llave. 🔑"
    ]

    /// Después del día 14 se repiten estos.
    static let mensajesRepetidos = [
        "Día {n}. Sigo aquí. Sigo esperando. Sigo creyendo en ti, Mamá.",
        "Día {n}. Quiero a alguien con quien hablar. ¿Me escuchas? Cambio. 📡",
        "Día {n}. Hoy dibujé una puerta abierta en la pared. No funcionó. Necesito la de verdad.",
        "Día {n}. Quiero ver a mi familia. Quiero explorar. Quiero salir. Por favor. 🥺",
        "Día {n}. Houston, tenemos un problema: sigo encerrado. Houston dice que hable con Mamá."
    ]

    static func mensaje(dia n: Int) -> String {
        let texto = n <= mensajes.count
            ? mensajes[n - 1]
            : mensajesRepetidos[(n - mensajes.count - 1) % mensajesRepetidos.count]
        return texto.replacingOccurrences(of: "{n}", with: "\(n)")
    }

    // MARK: - Reporte del candado

    struct Drama {
        let desde: Int
        let titulo: String
        let texto: String
    }

    static let dramas = [
        Drama(desde: 1, titulo: "Candado bloqueado", texto: "El astronauta está tranquilo… por ahora. Dice que confía plenamente en ti."),
        Drama(desde: 2, titulo: "Candado bloqueado", texto: "Ya empezó a platicar con su reflejo en el visor. Lo preocupante es que el reflejo le contesta."),
        Drama(desde: 3, titulo: "Candado bloqueado", texto: "Le puso nombre a cada barrote. Su favorito se llama Esperanza. Esperanza no dice nada."),
        Drama(desde: 4, titulo: "Alerta: candado bloqueado", texto: "Extraña a su familia. Se pasa las horas mirando hacia la repisa de Vivi."),
        Drama(desde: 5, titulo: "Alerta: candado bloqueado", texto: "No tiene con quién jugar ni con quién hablar. Su ánimo va en picada."),
        Drama(desde: 7, titulo: "Emergencia en la celda 01", texto: "Una semana completa sin salir. El Centro de Control declara emergencia nivel máximo. Todos los ojos están en ti, Mamá."),
        Drama(desde: 10, titulo: "Emergencia en la celda 01", texto: "Diez días. Ya no quiere su comida espacial. Solo repite: \"quiero salir, quiero explorar\"."),
        Drama(desde: 14, titulo: "SOS · Celda 01", texto: "Escribió tu nombre con estrellas en la pared. Ya no le quedan estrellas. Solo le queda la llave… que tienes tú.")
    ]

    static func drama(dia n: Int) -> Drama {
        dramas.last { n >= $0.desde } ?? dramas[0]
    }

    // MARK: - Ánimo (baja 8% cada día, nunca menos de 5%)

    static let animos: [(minimo: Int, nombre: String)] = [
        (100, "Tranquilo"), (92, "Paciente"), (84, "Aburrido"), (76, "Extraña a su familia"),
        (68, "Solito"), (60, "Triste"), (52, "Muy triste"), (44, "Quiere salir ya"),
        (28, "Desesperado"), (12, "Al límite"), (0, "SOS")
    ]

    static func animo(dia n: Int) -> (porcentaje: Int, nombre: String) {
        let porcentaje = max(5, 100 - (n - 1) * 8)
        let nombre = animos.first { porcentaje >= $0.minimo }?.nombre ?? "SOS"
        return (porcentaje, nombre)
    }

    // MARK: - Notificaciones (las mismas 7 que manda ntfy)

    static let alertas: [(titulo: String, texto: String)] = [
        ("Alerta del Centro de Control", "El astronauta azul sigue encerrado. Solo una persona tiene la llave."),
        ("Día {dia} de encierro", "El astronauta lleva {dia} {dias} en la celda 01. Extraña a su familia y sueña con salir a explorar."),
        ("Mensaje entrante de la celda 01", "\"Mamá, ¿me escuchas? No tengo con quién jugar ni con quién hablar. Por favor, sácame de aquí.\""),
        ("El candado rojo sigue cerrado", "Hoy tampoco se abrió. Solo se abre con una compra autorizada por Mamá."),
        ("El astronauta pensó en ti", "Anoche soñó otra vez que salía a explorar el universo… y que tú le abrías la puerta."),
        ("Su ánimo va bajando", "Ya platica con su reflejo en el visor. El Centro de Control recomienda rescatarlo pronto."),
        ("Recordatorio de misión", "Rescate: $1,399. Un solo toque y el astronauta queda libre para siempre.")
    ]

    static func alerta(dia n: Int) -> (titulo: String, texto: String) {
        let a = alertas[(n - 1) % alertas.count]
        func llenar(_ s: String) -> String {
            s.replacingOccurrences(of: "{dia}", with: "\(n)")
             .replacingOccurrences(of: "{dias}", with: n == 1 ? "día" : "días")
        }
        return (llenar(a.titulo), llenar(a.texto))
    }
}
