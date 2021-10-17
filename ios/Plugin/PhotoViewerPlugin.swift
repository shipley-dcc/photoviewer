import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(PhotoViewerPlugin)
public class PhotoViewerPlugin: CAPPlugin {
    private let implementation = PhotoViewer()

    // MARK: echo

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }

    // MARK: show

    @objc func show(_ call: CAPPluginCall) {
        guard let imageList = call.options["images"] as? [[String: String]] else {
            let error: String = "Must provide an image list"
            print(error)
            call.reject("Show : \(error)")
            return
        }
        if imageList.count == 0 {
            let error: String = "Must provide a non-empty image list"
            print(error)
            call.reject("Show : \(error)")
            return

        }
        let options: JSObject = call.getObject("options", JSObject())
        var mOptions: [String: Any] = [:]
        let keys = options.keys
        if keys.count > 0 {
            if keys.contains("spancount") {
                mOptions["spancout"] = options["spancout"] as? Int
            }
            if keys.contains("share") {
                mOptions["share"] = options["share"] as? Bool
            }
            if keys.contains("title") {
                mOptions["title"] = options["title"] as? String
            }

        }

        // Display
        DispatchQueue.main.async { [weak self] in
            if imageList.count > 1 {
                guard ((self?.implementation.show(imageList, options: options)) != nil),
                      let collectionController = self?.implementation.collectionController else {
                    call.reject("Show : Unable to show the CollectionViewController")
                    return
                }
                collectionController.modalPresentationStyle = .fullScreen
                self?.bridge?.viewController?.present(collectionController, animated: true, completion: {
                    call.resolve(["result": true])
                })
            } else if imageList.count == 1 {
                guard ((self?.implementation.show(imageList, options: options)) != nil),
                      let oneImageController = self?.implementation.oneImageController else {
                    call.reject("Show : Unable to show the OneImageViewController")
                    return
                }
                oneImageController.modalPresentationStyle = .fullScreen
                self?.bridge?.viewController?.present(oneImageController, animated: true, completion: {
                    call.resolve(["result": true])
                })

            }
        }

    }
}
