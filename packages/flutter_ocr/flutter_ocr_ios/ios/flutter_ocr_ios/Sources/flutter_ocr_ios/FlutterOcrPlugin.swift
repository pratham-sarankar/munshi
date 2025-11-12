import Flutter
import UIKit
import Vision

public class FlutterOcrPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_ocr_ios", binaryMessenger: registrar.messenger())
        let instance = FlutterOcrPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformName":
            result("iOS")
            
        case "recognizeTextFromImage":
            if let args = call.arguments as? [String: Any],
               let path = args["imagePath"] as? String {
                recognizeText(path: path, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGS",
                                    message: "Image path is missing",
                                    details: nil))
            }
            
        default:
            result(FlutterError(code: "METHOD_NOT_IMPLEMENTED",
                                message: "Method \(call.method) not implemented on iOS",
                                details: nil))
        }
    }
    
    private func recognizeText(path: String, result: @escaping FlutterResult) {
        guard let uiImage = UIImage(contentsOfFile: path),
              let cgImage = uiImage.cgImage else {
            result(FlutterError(code: "IMAGE_ERROR",
                                message: "Failed to load image.",
                                details: nil))
            return
        }
        
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                result(FlutterError(code: "OCR_ERROR",
                                    message: error.localizedDescription,
                                    details: nil))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                result("")
                return
            }
            
            let text = observations.compactMap {
                $0.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            result(text)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.minimumTextHeight = 0.01
        
        // Just run this directly — no queues, no concurrency issues
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            result(FlutterError(code: "OCR_REQUEST_FAILED",
                                message: error.localizedDescription,
                                details: nil))
        }
    }
}
