import Foundation
import UIKit

// MARK: - Mock Business Types

enum ChartsPeriod: Int, CaseIterable {
    case week, month, year
    var title: String {
        switch self {
        case .week: return "周"
        case .month: return "月"
        case .year: return "年"
        }
    }
}

struct ChartPoint: Equatable {
    let label: String
    let amount: Double
}

struct CategoryInfo {
    let assetName: String
    let symbolName: String
}

enum BookkeepingCategories {
    static func category(named name: String) -> CategoryInfo {
        CategoryInfo(assetName: name, symbolName: "dollarsign.circle")
    }
}

enum CategoryIconImage {
    static func image(assetName: String, symbolName: String) -> UIImage {
        UIImage(systemName: symbolName) ?? UIImage()
    }
}

// MARK: - BookkeepingCategory (业务类型桩)

struct BookkeepingCategory {
    let name: String
    let assetName: String
    let symbolName: String
}

// MARK: - ZodiacAvatars (业务类型桩)

struct ZodiacSign {
    let name: String
    let symbol: String
    let tintHex: UInt32
}

enum ZodiacAvatars {
    static func sign(named name: String) -> ZodiacSign? {
        let signs: [ZodiacSign] = [
            .init(name: "白羊座", symbol: "♈", tintHex: 0xDC2626),
            .init(name: "金牛座", symbol: "♉", tintHex: 0x16A34A),
            .init(name: "双子座", symbol: "♊", tintHex: 0x2563EB),
            .init(name: "巨蟹座", symbol: "♋", tintHex: 0x7C3AED),
            .init(name: "狮子座", symbol: "♌", tintHex: 0xEA580C),
            .init(name: "处女座", symbol: "♍", tintHex: 0x0891B2),
            .init(name: "天秤座", symbol: "♎", tintHex: 0xDB2777),
            .init(name: "天蝎座", symbol: "♏", tintHex: 0x991B1B),
            .init(name: "射手座", symbol: "♐", tintHex: 0x4F46E5),
            .init(name: "摩羯座", symbol: "♑", tintHex: 0x374151),
            .init(name: "水瓶座", symbol: "♒", tintHex: 0x0284C7),
            .init(name: "双鱼座", symbol: "♓", tintHex: 0x7C3AED),
        ]
        return signs.first { $0.name == name }
    }
}