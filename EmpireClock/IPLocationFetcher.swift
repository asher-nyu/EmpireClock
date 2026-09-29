import SwiftUI
import Combine

class IPLocationFetcher: ObservableObject {
    @Published var location: String = "Detecting location..."

    init() {
        fetchCity()
    }

    func fetchCity() {
        guard let url = URL(string: "https://ipapi.co/json/") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let city = json["city"] as? String ?? ""
                let region = json["region_code"] as? String ?? ""
                let country = json["country_name"] as? String ?? ""
                let result = [city, region, country].filter { !$0.isEmpty }.joined(separator: ", ")
                DispatchQueue.main.async {
                    self.location = result
                }
            }
        }.resume()
    }
}
