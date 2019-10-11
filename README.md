# FlexyNetwork
Protocol oriented iOS Networking Framework for common tasks written in swift

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate Alamofire into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'FlexyNetwork'
```

# Usage

### Define your request by implementing HTTPRequestRepresentable protocol (or any of its sub-protocols)
For example, let's consider following image request:

```swift
struct ExampleRequest: HTTPGETRequest {
    var parameters: JSON?
    var headerFields: [String : String]?
    
    var path: String {
        return "https://avatars.mds.yandex.net/get-pdb/51720/e8b9e4c0-18e8-41d9-97e2-806660d42973/s1200"
    }
}
```

### Define your response model by implementing FlexDecodable protocol

```swift
public protocol FlexDecodable {
    static var jsonDecoder: JSONDecoder? { get }
    static func decodeFrom(_ data: Data) throws -> Self
}
```

Swift `Decodable` protocol, `UIImage`, `String`, `Dictionary` and `Array` are already extended to confirm to the protocol. However, if you want to change jsonDecoder for your model, you can implement the property in your model. Or you can define protocol like this:

```swift
protocol SnakeCaseDecodable: FlexDecodable {}

extension SnakeCaseDecodable {
    static var jsonDecoder: JSONDecoder? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return decoder
    }
}
```

As our example is about image request, so there is nothing to do.

### Build `FlexNetService` using `APIBuilder` and handle response

```swift
APIBuilder()
  .setRequest(ExampleRequest())
  .build(for: UIImage.self, orError: FlexNever.self)
  .sendRequest()?.onSuccess({ (image) in
    print(image)
  })
```

`APIBuilder` builds service from objects that implement:

- [x] `Logger` -  protocol for logging request and response
- [x] `HeadersHandler` - protocol for handling headers from response
- [x] `RequestPreparator` - protocol for preparing request before sending it
- [x] `NestedModelGetter` - protocol that allows you to get nested data from response
- [x] `SuccessResponseChecker` - protocol for defining whether reposnse is successful or not
- [x] `HTTPRequestRepresentable`

`FlexNetService` supports numerous callbacks:

- [x] onSuccess is called when request is successfull according to your `SuccessResponseChecker` implementation
- [x] onFailure is called when request is failed according to your `SuccessResponseChecker` implementation
- [x] onError is called when there is some client-side error happened
- [x] onEnd is called when reqeust is finished regardless success or failure
- [x] onLastPage is called when using `PagedRequest` and there is no pages left
- [x] onProgress is called when progress on POST request has changed

## Easy SSL Pinning

In order to use SSL Pinning in your reqeusts just set public keys provider closure of `FlexNetServiceConfiguration` class:

```swift
FlexNetServiceConfiguration.publicKeysForSSLPinningProvider = { host in
    return [SSLPinningService.PublicKey("key", ofType: .RSA)]
}
```



