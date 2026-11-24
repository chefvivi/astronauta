import UserNotifications

/// Notificaciones locales: una alerta del Centro de Control todos los días a las 11:30 a. m. (hora de Monterrey).
/// No necesitan internet ni servidor: el iPhone las tiene programadas.
enum Notificaciones {
    static let hora = 11
    static let minuto = 30
    /// iOS permite hasta 64 notificaciones pendientes; programamos 60 días por adelantado
    /// y se vuelven a programar cada vez que se abre la app.
    static let diasPorAdelantado = 60

    static func pedirPermiso() async -> Bool {
        let centro = UNUserNotificationCenter.current()
        let ajustes = await centro.notificationSettings()
        switch ajustes.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        default:
            return (try? await centro.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        }
    }

    /// Programa la alerta de cada día con su propio mensaje (rotan las 7 y una dice el día de encierro).
    static func programar() async {
        guard await pedirPermiso() else { return }
        let centro = UNUserNotificationCenter.current()
        let cal = Mision.calendario
        let ahora = Date()
        let hoy = cal.startOfDay(for: ahora)

        let pendientes = await centro.pendingNotificationRequests()
        centro.removePendingNotificationRequests(withIdentifiers: pendientes.map(\.identifier).filter { $0.hasPrefix("alerta-") })

        for i in 0..<diasPorAdelantado {
            guard let dia = cal.date(byAdding: .day, value: i, to: hoy),
                  let fecha = cal.date(bySettingHour: hora, minute: minuto, second: 0, of: dia),
                  fecha > ahora else { continue }
            let n = Mision.dia(fecha)
            var componentes = cal.dateComponents([.year, .month, .day, .hour, .minute], from: fecha)
            componentes.timeZone = Mision.zona
            let disparo = UNCalendarNotificationTrigger(dateMatching: componentes, repeats: false)
            let solicitud = UNNotificationRequest(identifier: "alerta-\(n)", content: contenido(dia: n), trigger: disparo)
            try? await centro.add(solicitud)
        }
    }

    /// Manda una alerta de prueba en 5 segundos (para verla con el teléfono bloqueado).
    static func probar() async {
        guard await pedirPermiso() else { return }
        let disparo = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let solicitud = UNNotificationRequest(identifier: "prueba-\(UUID().uuidString)", content: contenido(dia: Mision.dia()), trigger: disparo)
        try? await UNUserNotificationCenter.current().add(solicitud)
    }

    private static func contenido(dia n: Int) -> UNMutableNotificationContent {
        let alerta = Mision.alerta(dia: n)
        let c = UNMutableNotificationContent()
        c.title = "🚀 " + alerta.titulo
        c.body = alerta.texto
        c.sound = .default
        c.interruptionLevel = .active
        return c
    }
}

/// Hace que la notificación también se vea si la app está abierta.
final class AvisosDelegado: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}
