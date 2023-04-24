//
//  WebcamCalloutView.swift
//  AuvergneWebcams
//
//  Created by Drusy on 15/02/2018.
//

import Foundation
import MapboxMaps

class WebcamCalloutView: UIView {
    let tipHeight: CGFloat = 10.0
    let tipWidth: CGFloat = 20.0
    var calloutDidTapped: (() -> Void)?

    private let webcam: Webcam
    private let mainBody: WebcamView

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        setNeedsDisplay()
    }

    required init(webcam: Webcam) {
        self.webcam = webcam
        self.mainBody = WebcamView.loadFromXib()
        super.init(frame: CGRect(x: 0, y: 0, width: 250, height: 150 + tipHeight))

        mainBody.configure(withWebcam: webcam)
        mainBody.layer.cornerRadius = 6.0
        mainBody.layer.masksToBounds = true

        backgroundColor = UIColor.clear

        addSubview(mainBody)
        fit(toSubview: mainBody, bottom: tipHeight)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(WebcamCalloutView.onTapGesture))
        addGestureRecognizer(tapGesture)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func dismissCallout(animated: Bool) {
        if (superview != nil) {
            if animated {
                UIView.animate(
                    withDuration: 0.2,
                    animations: { [weak self] in
                        self?.alpha = 0
                    },
                    completion: { [weak self] _ in
                        self?.removeFromSuperview()
                })
            } else {
                removeFromSuperview()
            }
        }
    }

    // MARK: - Callout interaction handlers

    @objc
    private func onTapGesture() {
        calloutDidTapped?()
    }

    // MARK: - Custom view styling

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let fillColor = UIColor.awDarkGray.withAlphaComponent(0.7)

        let tipLeft = rect.origin.x + (rect.size.width / 2.0) - (tipWidth / 2.0)
        let tipBottom = CGPoint(x: rect.origin.x + (rect.size.width / 2.0), y: rect.origin.y + rect.size.height)
        let heightWithoutTip = rect.size.height - tipHeight - 1

        let currentContext = UIGraphicsGetCurrentContext()!

        let tipPath = CGMutablePath()
        tipPath.move(to: CGPoint(x: tipLeft, y: heightWithoutTip))
        tipPath.addLine(to: CGPoint(x: tipBottom.x, y: tipBottom.y))
        tipPath.addLine(to: CGPoint(x: tipLeft + tipWidth, y: heightWithoutTip))
        tipPath.closeSubpath()

        fillColor.setFill()
        currentContext.addPath(tipPath)
        currentContext.fillPath()
    }
}
