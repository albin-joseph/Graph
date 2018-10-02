/*
 * Copyright (C) 2015 - 2018, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation

@dynamicMemberLookup
public struct GraphJSON: Equatable, CustomStringConvertible {
  
  /// A desiption of the object, used when printing.
  public var description: String {
    return GraphJSON.stringify(object, options: .prettyPrinted) ?? "{}"
  }
  
  /// A reference to the core object.
  public private(set) var object: Any
  
  /// A global GraphJSON object representing null.
  public static let isNil = GraphJSON(NSNull())
  
  /// An Array representation of the object.
  public var asArray: [Any]? {
    return object as? [Any]
  }
  
  /// A Dictionary representation of the object.
  public var asDictionary: [String: Any]? {
    return object as? [String: Any]
  }
  
  /// A String representation of the object.
  public var asString: String? {
    return object as? String
  }
  
  /// An Int representation of the object.
  public var asInt: Int? {
    return object as? Int
  }
  
  /// A Double representation of the object.
  public var asDouble: Double? {
    return object as? Double
  }
  
  /// A Float representation of the object.
  public var asFloat: Float? {
    return object as? Float
  }
  
  /// A Bool representation of the object.
  public var asBool: Bool? {
    return object as? Bool
  }
  
  /// A Data representation of the object.
  public var asNSData: Data? {
    return GraphJSON.serialize(object)
  }
  
  /**
   Parses a given Data object.
   - Parameter _ data: A Data object.
   - Parameter options: JSONSerialization.ReadingOptions.
   - Returns: A GraphJSON object on success, nil otherwise.
   */
  public static func parse(_ data: Data, options: JSONSerialization.ReadingOptions = .allowFragments) -> GraphJSON? {
    guard let v = try? JSONSerialization.jsonObject(with: data, options: options) else {
      return nil
    }
    
    return GraphJSON(v)
  }
  
  /**
   Parses a given String object.
   - Parameter _ string: A Data object.
   - Parameter options: JSONSerialization.ReadingOptions.
   - Returns: A GraphJSON object on success, nil otherwise.
   */
  public static func parse(_ string: String, options: JSONSerialization.ReadingOptions = .allowFragments) -> GraphJSON? {
    guard let v = string.data(using: String.Encoding.utf8) else {
      return nil
    }
    
    return parse(v, options: options)
  }
  
  /**
   Serializes an Any object into a Data object.
   - Parameter _ object: An Any object.
   - Returns: A Data object if successful, nil otherwise.
   */
  public static func serialize(_ object: Any, options: JSONSerialization.WritingOptions = []) -> Data? {
    guard JSONSerialization.isValidJSONObject(object) else {
      return nil
    }
    
    return try? JSONSerialization.data(withJSONObject: object, options: options)
  }
  
  /**
   Stringifies an instance of Any object into a String.
   - Parameter _ object: An Any object.
   - Returns: A String object if successful, nil otherwise.
   */
  public static func stringify(_ object: Any, options: JSONSerialization.WritingOptions = []) -> String? {
    if let v = object as? GraphJSON {
      return stringify(v.object, options: options)
    
    } else if let data = GraphJSON.serialize(object, options: options) {
      if let v = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
        return v
      }
    }
    
    return nil
  }
  
  /// An initializer that accepts a given Any object.
  public init(_ object: Any) {
    if let v = object as? GraphJSON {
      self.object = v.object
    
    } else {
      self.object = object
    }
  }
  
  /**
   A subscript operator for Array style access.
   - Parameter index: An Int.
   - Returns: A GraphJSON object.
   */
  public subscript(index: Int) -> GraphJSON {
    get {
      guard let v = asArray else {
        return .isNil
      }
      
      guard v.indices.contains(index) else {
        return .isNil
      }
      
      return GraphJSON(v[index])
    }
    set(value) {
      guard var v = asArray else {
        print("[GraphJSON: Can't set value '\(value.object)' for index '\(index)' on non-array type]")
        return
      }
      
      guard v.indices.contains(index) else {
        print("[GraphJSON: Can't set value '\(value.object)' for non-existent index '\(index)']")
        return
      }
      
      v[index] = value.object
      object = v
    }
  }
  
  /**
   Access properties using the dynamic property subscript operator.
   - Parameter dynamicMember member: A property name value.
   - Returns: A GraphJSON object.
   */
  public subscript(dynamicMember member: String) -> GraphJSON {
    get{
      return self[member]
    }
    set(value) {
      self[member] = value
    }
  }
  
  /**
   A subscript operator for Dictionary style access.
   - Parameter key: A String.
   - Returns: A GraphJSON object.
   */
  public subscript(key: String) -> GraphJSON {
    get {
      guard let v = asDictionary else {
        return .isNil
      }
      
      guard nil != v[key] else {
        return .isNil
      }
      
      return GraphJSON(v[key]!)
    }
    set(value) {
      guard var v = asDictionary else {
        print("[GraphJSON: Can't set value '\(value.object)' for key '\(key)' on non-dictionary type]")
        return
      }
      v[key] = value.object
      object = v
    }
  }
}

public func ==(left: GraphJSON, right: GraphJSON) -> Bool {
  return GraphJSON.stringify(left.object) == GraphJSON.stringify(right.object)
}

extension GraphJSON: ExpressibleByNilLiteral {
  public init(nilLiteral: ()) {
    self.init(NSNull() as Any)
  }
}

extension GraphJSON: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    self.init(value)
  }
  
  public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
    self.init(value)
  }
  
  public init(unicodeScalarLiteral value: StringLiteralType) {
    self.init(value)
  }
}

extension GraphJSON: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: IntegerLiteralType) {
    self.init(value)
  }
}

extension GraphJSON: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: BooleanLiteralType) {
    self.init(value)
  }
}

extension GraphJSON: ExpressibleByFloatLiteral {
  public init(floatLiteral value: FloatLiteralType) {
    self.init(value)
  }
}

extension GraphJSON: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (String, Any)...) {
    let dictionary = elements.reduce(into: [String: Any]()) { $0[$1.0] = $1.1 }
    self.init(dictionary)
  }
}

extension GraphJSON: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Any...) {
    self.init(elements)
  }
}