import Foundation

/// Los temas de ntfy viven en `Secretos.plist`, que NO se sube a GitHub (está en .gitignore).
/// Si el archivo no existe, se pueden escribir a mano en el Centro de Control.
enum Secretos {
    private static let datos: [String: String] = {
        guard let url = Bundle.main.url(forResource: "Secretos", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dic = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String]
        else { return [:] }
        return dic
    }()

    static var temaMama: String { datos["temaMama"] ?? "" }
    static var temaPrueba: String { datos["temaPrueba"] ?? "" }
}

/// Manda alertas por ntfy, con el mismo formato que la alerta diaria de GitHub Actions.
enum Ntfy {
    static let urlApp = "https://chefvivi.github.io/astronauta/"

    enum Problema: LocalizedError {
        case temaInvalido
        case respuesta(Int)

        var errorDescription: String? {
            switch self {
            case .temaInvalido: return "El tema no es válido. Solo puede tener letras, números, - y _."
            case .respuesta(let codigo): return "ntfy respondió con un error (\(codigo)). Intenta otra vez."
            }
        }
    }

    static func temaValido(_ tema: String) -> Bool {
        let t = tema.trimmingCharacters(in: .whitespaces)
        return (1...64).contains(t.count) && t.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-" || $0 == "_") }
    }

    /// - Parameter cuando: si es `nil` llega ahorita; si no, ntfy la entrega a esa hora (máximo 3 días después).
    static func enviar(tema: String, titulo: String, mensaje: String, cuando: Date? = nil) async throws {
        let tema = tema.trimmingCharacters(in: .whitespaces)
        guard temaValido(tema) else { throw Problema.temaInvalido }

        var parametros: [(String, String)] = [
            ("title", titulo),
            ("priority", "high"),
            ("tags", "rocket"),
            ("click", urlApp),
            ("icon", urlApp + "icons/icon-192.png"),
            ("actions", "view, Liberar al astronauta, \(urlApp), clear=true")
        ]
        if let cuando { parametros.append(("at", String(Int(cuando.timeIntervalSince1970)))) }

        // Codificamos a mano para que caracteres como & o + del mensaje no rompan la URL.
        var permitidos = CharacterSet.urlQueryAllowed
        permitidos.remove(charactersIn: "&=+?#")
        let consulta = parametros
            .map { "\($0.0)=\($0.1.addingPercentEncoding(withAllowedCharacters: permitidos) ?? "")" }
            .joined(separator: "&")

        var solicitud = URLRequest(url: URL(string: "https://ntfy.sh/\(tema)?\(consulta)")!)
        solicitud.httpMethod = "POST"
        solicitud.httpBody = Data(mensaje.utf8)
        solicitud.timeoutInterval = 20

        let (_, respuesta) = try await URLSession.shared.data(for: solicitud)
        let codigo = (respuesta as? HTTPURLResponse)?.statusCode ?? 0
        guard codigo == 200 else { throw Problema.respuesta(codigo) }
    }
}
