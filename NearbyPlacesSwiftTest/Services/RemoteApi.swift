//
//  RemoteApi.swift
//
//  Created by Abhishek Darak
//

import Alamofire
import SwiftyJSON

/// Singleton class for interacting with the older sync API call
class RemoteApi {

    /// singleton accessor
    static let shared = RemoteApi()

    private let reachabilityManager = NetworkReachabilityManager()

    private let apiBaseUrl = "https://api.yelp.com/v3/"
    var basicAuthUserName = ""
    var basicAuthPassword = ""

    /// Format string that requires secured_id string param
    
    private let findDevicesMethod = "businesses/search"
    
    private var session = Session()
    
    // /v1/users/:user_id/activity?auth_token=:token
    /// Format string that requires user ID and authentication token params
    
    private let createUserApplicationMethod = "authentication"

    private let searchVenueMethod = "businesses/search"
    
    private let unauthorizedStatusCode = 401
    private let unprocessableEntityStatusCode = 422  /// From RemoteApi.swift

    private let invalidServerResponseString = NSLocalizedString("Invalid server response", comment: "error message")
    private let failedToAuthenticateString = NSLocalizedString("Failed to authenticate with server", comment: "error message")
    private let noInternetConnectionString = NSLocalizedString("No Internet Connection", comment: "error message")
    
    // Translation strings for request errors
    private let notSignedInString = NSLocalizedString("Not Signed In", comment: "short title")
    private let fetchUserInformationFailureString = NSLocalizedString("Failed to fetch user information", comment: "error message")
    
    // Translation strings for alerts and request errors
    static let signInFailedTitleString = NSLocalizedString("Sign In Failed", comment: "short title")
    static let inviteCodeFailedTitleString = NSLocalizedString("Hmm...please enter a valid invite code.", comment: "short title")
   
    static let userSessionExpiredTitleString = NSLocalizedString("User Session Expired", comment: "short title")
    static let userSessionExpiredMessageString = NSLocalizedString("Please log in again", comment: "error message")

    /// Whether or not the device currently has internet connectivity
    var hasConnectivity: Bool {
        return self.reachabilityManager != nil && self.reachabilityManager!.isReachable
    }


    private init() {
        
    }

    /**
        Generic request method to be used by any requests made to the API.

        - Parameters:
            - methodPath: The relative URL to request from, including leading slash. The API base URL is prepended to it.
            - options: An optional RequestOptions struct of changed request options. Pass nil to use the defaults.

            - onSuccess: The callback to pass the JSON response and run once the request completes successfully.
            - successJson: A JSON object already parsed by SwiftyJSON.

            - onError: The callback to pass the Error response and run when the request fails.

                By default, the request is considered a failure when:
                * Response HTTP status code of outside of 200-299
                * Response Content-Type doesn't match request Accept header

                These can be changed by passing a modified RequestOptions object to the 'options' parameter.
            - errorResponse: The error response from the request.

            - onNoConnectivity: The callback for when the we have no internet connection.

            - onUnauthorized: The callback for when the request receives an HTTP status code of exactly 401 (Unauthorized).
    */
    private func request(methodPath: String,
                        options: RemoteRequestOptions? = nil,
                        onSuccess: @escaping (_ successJson: JSON) -> Void,
                        onError: @escaping (_ errorResponse: Error) -> Void,
                        onNoConnectivity: @escaping () -> Void,
                        onUnauthorized: @escaping () -> Void)
    {
        print("\nRemoteApi.request")

        if methodPath.contains("%d") || methodPath.contains("%@")
        {
            print("\t-- ERROR --\n\tURL did not have one or more params properly inserted into format string for URL method path")
            onError(ApiError.invalidUrl)

            return
        }

        let urlString = apiBaseUrl + methodPath
        let requestOptions = options == nil ? RemoteRequestOptions() : options!
        let isVerboseApiDebugOutputEnabled = true
        print(requestOptions.headers)
        let request = AF.request(
                urlString,
                method: requestOptions.method,
                parameters: requestOptions.data,
               // encoding: requestOptions.method == .post ? JSONEncoding.default : URLEncoding(destination: .queryString),
                headers: requestOptions.headers
            )
            .validate(statusCode: requestOptions.successStatusCodes)
            .validate(contentType: [requestOptions.headers["Accept"] ?? RemoteRequestOptions().headers["Accept"]!])
            .responseJSON { response in

                if isVerboseApiDebugOutputEnabled {
                    print("\nRESPONSE:\n")
                    debugPrint(response)
                    print("\nRESPONSE DATA:\n\n" + (response.data?.toString() ?? "no data"))
                }

                switch response.result {
                    case .success(let successValue):
                        onSuccess(JSON(successValue))
                    case .failure(let errorValue):
                        if let statusCode = response.response?.statusCode, statusCode == self.unauthorizedStatusCode {
                            onUnauthorized()
                        }
                        else if self.hasConnectivity {
                            onError(errorValue)
                        }
                        else {
                            print("\n-- NO INTERNET CONNECTION --")
                            onNoConnectivity()
                        }
                }
        }

        if isVerboseApiDebugOutputEnabled {
            print("\nREQUEST:\n")
            debugPrint(request)
        }
    }
    
    func getDataFromYelpAPI(lat: String, lon: String, term: String, success: @escaping (_ successParam: NearbyRestaurants) -> Void,
                                failure: @escaping (_ failureParam: String) -> Void,
                                unauthorized: @escaping () -> Void)
     {
         print("\nRemoteApi.getDataFromYelpAPI")

         var requestOptions = RemoteRequestOptions()
         // We get a 422 Unprocessable Entity response status on invalid username or password,
         // so allow that as a successful request so we can specifically deal with it
        
        print("\nlat \(lat)")
         requestOptions.successStatusCodes.append(unprocessableEntityStatusCode)
         requestOptions.method = HTTPMethod.get
         requestOptions.data = [
             "latitude": lat,
             "longitude": lon,
            "term": term
         ]

         request(methodPath: searchVenueMethod,
             options: requestOptions,
             onSuccess: { (jsonResult) in
                 print("\nRemoteApi.getDataFromYelpAPI onSuccess callback")

                 // Attempt to create an object expecting proper response contents
                 if let nearbyRestaurants = NearbyRestaurants(fromJson: jsonResult) {
                     print("\tParsed data")
                     success(nearbyRestaurants)
                 }
                 // If we didn't get the expected response, attempt to parse the response as the generic error contents the API returns
                 else if let errorResponse = GenericError(fromJson: jsonResult) {
                     failure(errorResponse.Message)
                 }
                 // Fallback failure
                 else {
                     print("\nRemoteApi.createUserApplication onSuccess callback")
                     print("\tFailed to parse any meaningful response from the response JSON of:\n\(jsonResult)")
                     failure(RemoteApi.signInFailedTitleString)
                 }
             },
             onError: { (errorResult) in
                 print("\nRemoteApi.createUserApplication onError callback")
                 print("\tError: \(errorResult)")
                 failure(RemoteApi.signInFailedTitleString)
             },
             onNoConnectivity: {
                 print("\nRemoteApi.createUserApplication onNoConnectivity callback")
                 failure("no_network")
                 //failure(self.noInternetConnectionString)
             },
             onUnauthorized: {
                 print("\nRemoteApi.createUserApplication onUnauthorized callback")
                 unauthorized()
             }
         )
     }

    /// API functions starts here
    
    /**
        Confirms we can get a connection to the API.

        - Parameters:
            - success: Callback for when the connection is successful. No closure parameter.

            - failure: Callback for when we fail to connect.
            - errorObject: An object that conforms to Error, usually an AFError.
    */
    func testConnection(success: @escaping () -> Void, failure: @escaping (_ errorObject: Error?) -> Void)
    {
        print("\nRemoteApi.testConnection")

        var options = RemoteRequestOptions()

        // 401 (Unauthorized) means we have a good connection, in this case
        options.successStatusCodes = [401]

        request(methodPath: "",
            options: options,
            onSuccess: { (jsonResult) in
                print("\nRemoteApi.testConnection onSuccess callback")
                success()
            },
            onError: { (errorResult) in
                print("\nRemoteApi.testConnection onFailure callback")
                failure(errorResult)
            },
            onNoConnectivity: {
                print("\nRemoteApi.testConnection onNoConnectivity callback")
                failure(nil)
            },
            onUnauthorized: {
                // Shouldn't happen since we put 401 in the success status codes
                print("\nRemoteApi.testConnection onUnauthorized callback")
            }
        )
    }


    /// Returns a string formatted for use with the registerUser method's 'date_of_birth' field
    private func dateToBirthDateString(_ inputDate: Date) -> String
    {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // locale to POSIX ensures that the user's locale won't be used
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: inputDate)
    }
    
    
    /// Simple class for parsing and then holding the contents of a generic error response from the API
    class GenericError {
        private let message: String
        private let errorTitle: String?
        private let errorDetail: String?
        private let errorSourcePointerSegments: [String]?

        private let errorSourcePointerSeparator = "/"

        /// Returns the most detailed error message that can be built from the error response contents
        var Message: String {
            if let detail = errorDetail {
                if let segments = errorSourcePointerSegments, segments.count > 0 {
                    // Return the last segment (the most specific one) in front of the error message from the 'detail' key
                    return "\(segments.last!.capitalized) - \(detail)"
                }

                // If we don't have segments, then just return the detailed error message
                return detail
            }

            // Lastly, return the least specific error message if all others didn't work out
            return message
        }

        /// Failable initializer to create an object from an API response with error information JSON content
        init?(fromJson errorJson: JSON) {
            print("\nRemoteApiResponse GenericError.init")

            if let parsedMessage = errorJson["message"].string {
                print("\tMessage: \(parsedMessage)")
                message = parsedMessage
            }
            else {
                print("\tNo message found, abandoning init")
                return nil
            }

            if let errors = errorJson["errors"].array, errors.count > 0 {
                // We only expect to ever get back one JSON object inside 'errors', so if we get more, display so in the console
                if errors.count > 1 {
                    print("\t-- WARNING --\n\tUNEXPECTEDLY FOUND MORE THAN ONE ERROR OBJECT IN JSON RESPONSE")
                }

                let firstError = errors.first!

                if let title = firstError["title"].string, let pointer = firstError["source"]["pointer"].string {
                    errorTitle = title

                    // Break the URL-esque string into segments. The later segments are more specific to the error area than the earlier ones.
                    errorSourcePointerSegments = pointer
                        // Explode on separators
                        .components(separatedBy: errorSourcePointerSeparator)
                        // Remove empty strings
                        .filter({ (segment) -> Bool in return !segment.isEmpty })
                        // Replace any underscores with spaces
                        .map({ $0.replacingOccurrences(of: "_", with: " ") })

                    // Detail can be a string
                    if let detail = firstError["detail"].string {
                        errorDetail = detail
                    }
                    // Or an array of strings
                    else if let detail = firstError["detail"].array?.first?.string {
                        errorDetail = detail
                    }
                    else {
                        errorDetail = nil
                    }

                    print("\tTitle: \(title)\n\tDetail: \(errorDetail ?? "not found")\n\tPointer: \(errorSourcePointerSegments!.joined(separator: errorSourcePointerSeparator))")
                    print("\tParsing successful")
                }
                else {
                    print("\t-- ERROR --\n\tFailed to parse string(s) out of error object nested in response JSON:\n\(firstError)")

                    errorTitle = nil
                    errorDetail = nil
                    errorSourcePointerSegments = nil
                }
            }
            else {
                print("\tJSON contained no error object to parse")
                print("\tParsing successful")

                errorTitle = nil
                errorDetail = nil
                errorSourcePointerSegments = nil
            }
        }
    }
  


    /// Returns a string formatted for use with the getUserActivity method
    private func dateToUserActivityFilterDateString(_ inputDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Set to UTC timezone
        formatter.locale = Locale(identifier: "en_US_POSIX") // locale to POSIX ensures that the user's locale won't be used
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: inputDate)
    }
    
    //TODO Remove This
    /// This custom adapter allows us to modify the request after it's been built, but before it gets sent, so we can add the HMAC Authorization HTTP header.
    private class AuthInterceptor: RequestInterceptor {
        private let accessToken: String
        private let tokenType: String

        init (accessToken: String, tokenType: String) {
            self.accessToken = accessToken
            self.tokenType = tokenType
        }
    }

}

/// Available request options, pre-filled with the defaults.
private struct RemoteRequestOptions {
    /// HTTP request method
    var method = HTTPMethod.get

    /// The parameters to send
    var data: Parameters? = nil
    var apikey: String? = "pVsDVsr01tInNWBJAzOVdpHXLziseRLVKuGw-FejC9RriegZt16nCOOg2_LJgw8fpaIarBcHbLKb80w4PGfr9imQTqI_mvLDWSWtqYlaIOquvzEt4Uxh5sq_Hfo0YXYx"

    /// HTTP headers
    ///
    /// Only response types that match the 'Accept' entry of this dictionary (or the default value, if missing)
    /// will result in RemoteApi.request() calling the onSuccess callback.
    var headers: HTTPHeaders = [
       // "Content-Type": "application/json",
        "authorization": "Bearer pVsDVsr01tInNWBJAzOVdpHXLziseRLVKuGw-FejC9RriegZt16nCOOg2_LJgw8fpaIarBcHbLKb80w4PGfr9imQTqI_mvLDWSWtqYlaIOquvzEt4Uxh5sq_Hfo0YXYx",
        "Accept": "application/json"
        //"Authorization": "Basic \(RemoteRequestOptions.getAuth)"
    ]
   
    
    /// Returns the current datetime as a string in the format the API requires
    static var getAuth: String {
        let userName = RemoteApi.shared.basicAuthUserName
        let password = RemoteApi.shared.basicAuthPassword
        if userName.isEmpty == false && password.isEmpty == false{
            let credentialData = "\(userName):\(password)".data(using: .utf8)
            guard let cred = credentialData else { return "" }
            let base64Credentials = cred.base64EncodedData(options: [])
            guard let base64Date = Data(base64Encoded: base64Credentials) else { return "" }
            return base64Date.base64EncodedString()
        }
        return ""
    }
    /// HTTP status codes that will be accepted
    ///
    /// Only these status codes will result in RemoteApi.request() calling the onSuccess callback.
    var successStatusCodes = Array(200..<300)
}

