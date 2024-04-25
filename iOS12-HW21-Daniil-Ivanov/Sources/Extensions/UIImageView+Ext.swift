//
//  UIImageView+Ext.swift
//  iOS12-HW21-Daniil-Ivanov
//
//  Created by Daniil (work) on 19.04.2024.
//

import UIKit
import SkeletonView

extension UIImageView {
    func setImage(url: URL, placeholder: UIImage?) {
        var url = url
        self.image = placeholder

        if url.scheme == "http" {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            components?.scheme = "https"

            if let secureUrl = try? components?.asURL() {
                url = secureUrl
            }
        }

        Task { [weak self] in
            guard let self else { return }
            self.startShimmerAnimation()
            let (data, _) = try await URLSession.shared.data(from: url)
            self.image = UIImage(data: data)
            self.stopShimmerAnimation()
        }
    }

    private func startShimmerAnimation() {
        let animation = SkeletonAnimationBuilder()
            .makeSlidingAnimation(withDirection: .leftRight)
        let color = UIColor(red: 0.882, green: 0.89, blue: 0.914, alpha: 1)
        let gradient = SkeletonGradient(baseColor: color, secondaryColor: .white)

        self.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
    }

    private func stopShimmerAnimation() {
        self.hideSkeleton()
    }
}
