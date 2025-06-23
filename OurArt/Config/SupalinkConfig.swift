import Foundation

struct SupalinkConfig {
    static let shared = SupalinkConfig()
    
    let apiKey: String = "YOUR_SUPALINK_API_KEY"
    let domain: String = "ourart.app"
    
    private init() {}
    
    func createLink(path: String, parameters: [String: String]? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = domain
        components.path = path
        
        if let parameters = parameters {
            components.queryItems = parameters.map { 
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        
        return components.url
    }
} 