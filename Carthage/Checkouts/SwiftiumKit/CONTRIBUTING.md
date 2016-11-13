# Contributing

PR are welcome, public APIs should be tested and documented
Don't forget to update the CHANGELOG.md

# Documenting APIs:

@see http://nshipster.com/swift-documentation/

````
extension String {
    /**
     Repeats a string `times` times.
    
     Usage:
     ````
     let string = repeatString(str :".", times: 12)
     ````
     - Parameter str:   The string to repeat.
     - Parameter times: The number of times to repeat `str`.
     
     - Throws: `MyError.InvalidTimes` if the `times` parameter
     is less than zero.
     
     - Returns: A new string with `str` repeated `times` times.
     */
    func repeatString(str: String, times: Int) throws -> String {
        return "miam"
    }
}
````
