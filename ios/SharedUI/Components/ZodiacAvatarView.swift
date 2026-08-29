/// 星座头像圆形视图。

import UIKit
import SnapKit

/// 展示星座符号的圆形头像。
final class ZodiacAvatarView: UIView {
    private let symbolLabel = UILabel()

    /// 初始化头像视图。
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        symbolLabel.textAlignment = .center
        symbolLabel.font = .systemFont(ofSize: AppFont.sizeXl, weight: .semibold)
        addSubview(symbolLabel)
        symbolLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 绑定星座；nil 时显示昵称首字。
    func apply(zodiacName: String?, nickname: String, diameter: CGFloat = 56) {
        layer.cornerRadius = diameter / 2
        if let name = zodiacName, let sign = ZodiacAvatars.sign(named: name) {
            backgroundColor = UIColor(hex: sign.tintHex, alpha: 0.18)
            symbolLabel.text = sign.symbol
            symbolLabel.textColor = UIColor(hex: sign.tintHex)
            symbolLabel.font = .systemFont(ofSize: diameter * 0.42, weight: .semibold)
        } else {
            backgroundColor = AppColor.primaryMuted
            symbolLabel.text = String(nickname.prefix(1))
            symbolLabel.textColor = AppColor.primary
            symbolLabel.font = .systemFont(ofSize: diameter * 0.38, weight: .semibold)
        }
    }
}
