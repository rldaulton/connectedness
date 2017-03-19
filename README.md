# connectedness
Check network connection and speed with a single method call. ```connectedness``` first checks your access to the network (wifi or mobile 1X/3G/LTE), then determines your network's speed by loading a dummy resource. 

It checks this network speed with a default timeout of 5 seconds, then compares your speed to the approximate national average 3G network - if it is slower than this average, an error is thrown for you to handle as you please. 

## Requirements

* Xcode 7 or higher
* iOS 8.0 or higher
* Swift 2.3

## Installation

#### Manual Only

Add the ```connectedness.swift``` file into your project.

## Usage
1.) Determine Resource
#### In order to check the speed of your network, a dummy resource must be downloaded from somewhere online. 
Replace the link in the ```testDownloadSpeedWithTimout...()``` function with a link to your own resource. A random ```.txt``` file will do.
```swift
public func testDownloadSpeedWithTimout(timeout: NSTimeInterval, completionHandler:(megabytesPerSecond: Double?, error: NSError?) -> ()) {
        let url = NSURL(string: "http://insert.your.site.here/yourfile")!
...
```
2.) Determine what you want your network speed to be compared against by changing the value associated with the ```if megabytesPerSecond!>= ... {```. Also, change the number associated with ```testDownloadSpeedWithTimout(...)``` to increase or decrease the timeout time, in seconds. See below.
```swift
connectedSpeed().testDownloadSpeedWithTimout(5.0) { (megabytesPerSecond, error) -> () in
        if ((error == nil) && isReachable && !needsConnection){
            if megabytesPerSecond!>=0.05{
 ...
 ```
 The default ```0.05``` measures out approximately to the national average 3G network. Lower this number to compare against slower speeds, and raise it to compare against higher speeds. This is most useful when you may want to tell users that their slow speed will negatively affect their user experience and tell them to try for a better signal.
 
 For example, a value of ```1.1``` equates to a wifi connection speed of around 35 Mbps. These numbers are not exact.

3.) Simply call the ```connectedToNetwork()``` from anywhere in your project. Connection will be determined first, then speed will be measured.  

```swift
func viewDidLoad(){
  connectedToNetwork()
}
```
Debugger prints your connectivity nicely
```    
       | Connected |
=======Network Speed=======
Mbps: 1.00830526622741
error: nil
=======-------------=======
```
## Author

[Ryan Daulton](https://www.linkedin.com/in/ryan-daulton-744a8368)

## License

connectedness is available under the MIT license. See the LICENSE file for more info.
