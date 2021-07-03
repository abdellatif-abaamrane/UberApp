//
//  Extension.swift
//  Twitter
//
//  Created by macbook-pro on 13/05/2020.
//

import UIKit
import CoreImage
import MapKit


extension UIColor {
    static var blackUber = UIColor(red: 30.0/255.0, green: 28.0/255.0, blue: 39.0/255.0, alpha: 1.0)
    static var blueCyan = UIColor(red: 29.0/255.0, green: 161.0/255.0, blue: 242.0/255.0, alpha: 1.0)
}
extension UIView {
    func getTextFeild() -> UITextField? {
        subviews.first { $0 is UITextField } as? UITextField
    }
}
extension UIImage {
    convenience init?(color: UIColor, size: CGFloat) {
        let scaledSize = size/UIScreen.main.scale
        let data = UIGraphicsImageRenderer(size: CGSize(width: scaledSize, height: scaledSize)).pngData { context in
            color.setFill()
            context.fill(CGRect(origin: CGPoint(x: (scaledSize/8)*3, y: (scaledSize/8)*3), size: CGSize(width: scaledSize/4, height: scaledSize/4)))
        }
        self.init(data:data)
    }
    convenience init?(image: UIImage, size: CGFloat) {
        let scaledSize = size/UIScreen.main.nativeScale
        let data = UIGraphicsImageRenderer(size: CGSize(width: scaledSize, height: scaledSize)).pngData { context in
            context.cgContext.draw(image.cgImage!, in: CGRect(origin: CGPoint(x: scaledSize/4, y: scaledSize/4),
                                                              size: CGSize(width: scaledSize/2, height: scaledSize/2)))
        }
        self.init(data:data)
    }
    func getColor(location: CGPoint) -> UIColor? {
        guard let cgImage = cgImage ,
              let dataProvider = cgImage.dataProvider ,
              let dataPixel = dataProvider.data   else { return nil }
        let locationPixelX = location.x * scale
        let locationPixelY = location.y * scale
        
        // Get How many byte from begin to location
        let pixel = cgImage.bytesPerRow * Int(locationPixelY-1) + Int(locationPixelX)*(cgImage.bitsPerPixel/8)
        
        // Check if pixel great then total data
        guard pixel <= CFDataGetLength(dataPixel) else { return nil }
        
        //
        guard let pointer = CFDataGetBytePtr(dataPixel) else {
            return nil
        }
        
        
        func convert(_ color: UInt8) -> CGFloat {
            return CGFloat(color)/255
        }
        
        let compenent = cgImage.bytesPerRow * Int(locationPixelY-1) + Int(locationPixelX)*(cgImage.bitsPerPixel/8) - 3
        
        let red = convert(pointer[compenent])
        let green = convert(pointer[compenent+1])
        let blue = convert(pointer[compenent+2])
        let alpha = convert(pointer[compenent+3])
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    func averageColor(_ completionHandler: @escaping (UIColor?)-> Void) {
        DispatchQueue.global().async {
            guard let inputImage = CIImage(image: self) else { completionHandler(nil); return }
            let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

            guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { completionHandler(nil); return}
            guard let outputImage = filter.outputImage else { completionHandler(nil); return }

            var bitmap = [UInt8](repeating: 0, count: 4)
            let context = CIContext(options: [.workingColorSpace: kCFNull!])
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

            completionHandler(UIColor(red: CGFloat(bitmap[0]) / 255,
                                       green: CGFloat(bitmap[1]) / 255,
                                       blue: CGFloat(bitmap[2]) / 255,
                                       alpha: CGFloat(bitmap[3]) / 255))
        }
        
    }
    
}
    
func delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}
extension UIImageView {
    func fetchImage(url:URL) {
        NetworkClient.shared.getProfileImage(url: url) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let response = response as? HTTPURLResponse,
               (200..<300).contains(response.statusCode),
               let data = data,
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}
extension MKMarkerAnnotationView {
    override func fetchImage(url:URL) {
        NetworkClient.shared.getProfileImage(url: url) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let response = response as? HTTPURLResponse,
               (200..<300).contains(response.statusCode),
               let data = data,
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    let image = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { context in
                        UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: 30, height: 30))).addClip()
                        image.draw(in: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
                        let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
                        UIColor.blackUber.setStroke()
                        path.lineWidth = 2
                        path.stroke()
                    }
                    self.glyphImage = image
                }
            }
        }
    }
}

extension MKAnnotationView {
    @objc func fetchImage(url:URL) {
        NetworkClient.shared.getProfileImage(url: url) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let response = response as? HTTPURLResponse,
               (200..<300).contains(response.statusCode),
               let data = data,
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    let image = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { context in
                        UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: 30, height: 30))).addClip()
                        image.draw(in: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
                        let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
                        UIColor.blackUber.setStroke()
                        path.lineWidth = 2
                        path.stroke()
                    }
                    self.image = image
                }
            }
        }
    }
}

extension MKPlacemark {
    var address: String? {
        get {
            guard let subThoroughfare = subThoroughfare else { return nil }
            guard let thoroughfare = thoroughfare else { return nil }
            guard let locality = locality else { return nil }
            guard let adminArea = administrativeArea else { return nil }
            return "\(subThoroughfare) \(thoroughfare), \(locality), \(adminArea) "
        }
    }
}
extension UIViewController {
    func shouldPresentLoadingView(_ present: Bool, message: String? = nil) {
        if present {
            let blur = UIBlurEffect(style: .systemThinMaterialDark)
            let effectView = UIVisualEffectView(effect: blur)
            effectView.translatesAutoresizingMaskIntoConstraints = false
            effectView.alpha = 0

            let indicator = UIActivityIndicatorView(style: .large)
            indicator.color = .white
            indicator.hidesWhenStopped = true
            
            let label = UILabel()
            label.text = message
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = .white
            
            let stackView = UIStackView(arrangedSubviews: [indicator,label])
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.distribution = .fillProportionally
            stackView.spacing = 8
            stackView.translatesAutoresizingMaskIntoConstraints = false
            effectView.contentView.addSubview(stackView)
            view.addSubview(effectView)
            NSLayoutConstraint.activate([
                stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                effectView.topAnchor.constraint(equalTo: view.topAnchor),
                effectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                effectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                effectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: view.bounds.width),
            ])
            view.layoutIfNeeded()
            delay(0.1) {
                UIView.animate(withDuration: 0.4) {
                    effectView.alpha = 1
                } completion: { finish in
                    if finish {
                        indicator.startAnimating()
                    }
                }
            }
            
            

        } else {
            guard let effectView = view.subviews.first(where: { $0 is UIVisualEffectView }) as? UIVisualEffectView else { return }
            UIView.animate(withDuration: 0.4) {
                effectView.alpha = 0
            } completion: { _ in
                effectView.removeFromSuperview()
            }
        }
    }
}
extension MKMapView {
    func zoomToFit(annotations: [MKAnnotation],polyline: MKPolyline?, bottomPading: CGFloat) {
        var zoomRect = MKMapRect.null
        
        annotations.forEach { (annotation) in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y,
                                      width: 0.01, height: 0.01)
            zoomRect = zoomRect.union(pointRect)
        }
        if let polyline = polyline {
            let points = Array(UnsafeMutableBufferPointer(start: polyline.points(), count: polyline.pointCount))
            points.forEach { (point) in
                let pointRect = MKMapRect(x: point.x, y: point.y,
                                          width: 0.01, height: 0.01)
                zoomRect = zoomRect.union(pointRect)
            }
        }
        
        let insets = UIEdgeInsets(top: 40, left: 40, bottom: bottomPading, right: 40)
        setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
    }
    func snapshot(location: CLLocationCoordinate2D,_ completionHandler: @escaping (Result<UIImage,Error>)->Void) {
        let options = MKMapSnapshotter.Options()
        options.camera =  MKMapCamera(lookingAtCenter: location, fromDistance: 400, pitch: 0, heading: 0)
       let shotter = MKMapSnapshotter(options: options)
        shotter.start(with: .main) { snapshot, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            guard let snapshot = snapshot else { return }
            completionHandler(.success(snapshot.image))
        }
    }
    
}
