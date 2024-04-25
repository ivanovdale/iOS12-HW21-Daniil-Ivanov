import Foundation

struct Cards: Decodable {
    let cards: [Card]
}

struct Card: Decodable {
    let name: String
    let manaCost: String?
    let type: String
    let rarity: String
    let setName: String
    let originalText: String?
    let imageUrl: String?
}

extension Cards: CustomStringConvertible {
    public var description: String {
        cards.map { $0.description }.joined(separator: "\n")
    }
}

extension Card: CustomStringConvertible {
    public var description: String {
        let text = self.originalText?.isEmpty == false ? "Текст: \(self.originalText!)\n" : ""

        return """
        Имя карты: \(self.name)
        Мановая стоимость: \(self.manaCost ?? "Unknown")
        Тип: \(self.type)
        Рарность: \(self.rarity)
        Название сета: \(self.setName)
        \(text)
        """
    }
}
