//
//  NetworkManager.swift
//  sora
//
//  Created by Elias CHETOUANI on 06/05/2024.
//

import Foundation
import FirebaseFunctions

class NetworkManager: ObservableObject {
    
    // let options = HTTPSCallableOptions(requireLimitedUseAppCheckTokens: true)

    lazy var functions = Functions.functions()
    
    func textToVideo() {
    //   functions.useEmulator(withHost: "127.0.0.1", port: 5001)

        functions.httpsCallable("textToVideo").call() { result, error in
            if let error = error {
                print("Error calling function: \(error.localizedDescription)")
                return
            }
            guard let resultData = result?.data else {
                print("No data received from function")
                return
            }
            do {
                // Assuming the result data is a dictionary containing an array of voices
              //  let jsonData = try JSONSerialization.data(withJSONObject: resultData, options: [])

            } catch {
                print("Error decoding data: \(error.localizedDescription)")
            }
        }
    }
    
    func downloadVideo(from url: URL, completion: @escaping (URL?, Error?) -> Void) {
        let downloadTask = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            guard let tempURL = tempURL, error == nil else {
                completion(nil, error)
                return
            }
            
            // Determine a permanent file location to save the downloaded video
            let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let videoPath = documentsPath.appendingPathComponent(url.lastPathComponent)
            
            try? fileManager.moveItem(at: tempURL, to: videoPath)
            
            DispatchQueue.main.async {
                completion(videoPath, nil)
            }
        }
        downloadTask.resume()
    }
    
}

