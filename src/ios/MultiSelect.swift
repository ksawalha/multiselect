import UIKit
import MobileCoreServices
import Cordova

@objc(MultiSelect) class MultiSelect: CDVPlugin, UIDocumentPickerDelegate {

    var callbackId: String?

    @objc(chooseFiles:)
    func chooseFiles(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId

        // Check if the user has access to the files
        if !hasFileAccess() {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "File access is restricted. Please check your settings.")
            self.commandDelegate.send(pluginResult, callbackId: self.callbackId)
            return
        }
        
        // Allowed file types (public.item covers generic files, adjust as needed)
        let types: [String] = [kUTTypeItem as String]
        
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item], asCopy: false)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        
        self.viewController.present(documentPicker, animated: true, completion: nil)
    }

    // Called when the user selects files
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        var resultArray: [[String: String]] = []
        
        for url in urls {
            let fileName = url.lastPathComponent
            let fullPath = url.path
            
            let fileData: [String: String] = [
                "filename": fileName,
                "fullPath": fullPath
            ]
            resultArray.append(fileData)
        }
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: resultArray)
        self.commandDelegate.send(pluginResult, callbackId: self.callbackId)
    }

    // Called when the user cancels the file picker
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "User cancelled file selection")
        self.commandDelegate.send(pluginResult, callbackId: self.callbackId)
    }
}
