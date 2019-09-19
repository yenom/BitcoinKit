//
//  BitArray.swift
//
//  Created by Mauricio Santos on 2/23/15.
//  Modified by BitcoinKit developers
//
//  Github: https://github.com/mauriciosantos/Buckets-Swift/blob/master/Source/BitArray.swift
//
//  Copyright (c) 2015 Mauricio Santos
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// An array of boolean values stored
/// using individual bits, thus providing a
/// very small memory footprint. It has most of the features of a
/// standard array such as constant time random access and
/// amortized constant time insertion at the end of the array.
///
/// Conforms to `MutableCollection`, `RangeReplaceableCollection`, `ExpressibleByArrayLiteral`
/// , `Equatable`, `Hashable`, `CustomStringConvertible`

public struct BitArray: Hashable, RangeReplaceableCollection {

    // MARK: Creating a BitArray

    /// Constructs an empty bit array.
    public init() {}

    /// Constructs a bit array from a `Bool` sequence, such as an array.
    public init<S: Sequence>(_ elements: S) where S.Iterator.Element == Bool {
        for value in elements {
            append(value)
        }
    }

    public init(data: Data) {
        guard let viaBitstring = BitArray(binaryString: data.binaryString) else {
            fatalError("should always be able to init from data, incorrect implementation of either Data.binaryString or `Self.init(binaryString:)`")
        }

        assert(viaBitstring.asData() == data, "assert correctness of conversion")

        self = viaBitstring
    }

    /// A non-optimized initializer taking a binary String, if the string passed contains any other characters than '0' or '1' then the init will fail (return nil)
    public init?<S>(binaryString: S) where S: StringProtocol {
        let mapped: [Bool] = binaryString.compactMap {
            if $0 == "1" {
                return true
            } else if $0 == "0" {
                return false
            } else {
                fatalError("bad char: \($0)")
            }
        }
        self.init(mapped)
    }

    /// A non-optimized initializer taking an array of `UInt11`
    init<S>(_ elements: S) where S: Sequence, S.Iterator.Element == UInt11 {
        let binaryString: String = elements.map { $0.binaryString }.joined()
        guard let bitArray = BitArray(binaryString: binaryString) else { fatalError("Should always be able to create BitArray from [UInt11] binaryString: '\(binaryString)'") }
        self = bitArray
    }

    /// Constructs a new bit array from an `Int` array representation.
    /// All values different from 0 are considered `true`.
    public init(intRepresentation: [Int]) {
        bits.reserveCapacity((intRepresentation.count / Constants.IntSize) + 1)
        for value in intRepresentation {
            append(value != 0)
        }
    }

    /// Constructs a new bit array with `count` bits set to the specified value.
    public init(repeating repeatedValue: Bool, count: Int) {
        precondition(!isEmpty, "Can't construct BitArray with count < 0")

        let numberOfInts = (count / Constants.IntSize) + 1
        let intValue = repeatedValue ? ~0 : 0
        bits = [Int](repeating: intValue, count: numberOfInts)
        self.count = count

        if repeatedValue {
            bits[bits.count - 1] = 0
            let missingBits = count % Constants.IntSize
            self.count = count - missingBits
            for _ in 0..<missingBits {
                append(repeatedValue)
            }
            cardinality = count
        }
    }

    // MARK: Querying a BitArray

    /// Number of bits stored in the bit array.
    public fileprivate(set) var count = 0

    /// The first bit, or nil if the bit array is empty.
    public var first: Bool? {
        return isEmpty ? nil : valueAtIndex(0)
    }

    /// The last bit, or nil if the bit array is empty.
    public var last: Bool? {
        return isEmpty ? nil : valueAtIndex(count - 1)
    }

    /// The number of bits set to `true` in the bit array.
    public fileprivate(set) var cardinality = 0

    // MARK: Adding and Removing Bits

    /// Adds a new `Bool` as the last bit.
    public mutating func append(_ bit: Bool) {
        if realIndexPath(count).arrayIndex >= bits.count {
            bits.append(0)
        }
        setValue(bit, atIndex: count)
        count += 1
    }

    /// Inserts a bit into the array at a given index.
    /// Use this method to insert a new bit anywhere within the range
    /// of existing bits, or as the last bit. The index must be less
    /// than or equal to the number of bits in the bit array. If you
    /// attempt to remove a bit at a greater index, you’ll trigger an error.
    public mutating func insert(_ bit: Bool, at index: Int) {
        checkIndex(index, lessThan: count + 1)
        append(bit)
        for i in stride(from: (count - 2), through: index, by: -1) {
            let iBit = valueAtIndex(i)
            setValue(iBit, atIndex: i + 1)
        }
        setValue(bit, atIndex: index)

    }

    /// Removes the last bit from the bit array and returns it.
    ///
    /// - returns: The last bit, or nil if the bit array is empty.
    @discardableResult
    public mutating func removeLast() -> Bool {
        if let value = last {
            setValue(false, atIndex: count - 1)
            count -= 1
            return value
        }
        preconditionFailure("Array is empty")
    }

    /// Removes the bit at the given index and returns it.
    /// The index must be less than the number of bits in the
    /// bit array. If you attempt to remove a bit at a
    /// greater index, you’ll trigger an error.
    @discardableResult
    public mutating func remove(at index: Int) -> Bool {
        checkIndex(index)
        let bit = valueAtIndex(index)

        for i in (index + 1)..<count {
            let iBit = valueAtIndex(i)
            setValue(iBit, atIndex: i - 1)
        }

        removeLast()
        return bit
    }

    /// Removes all the bits from the array, and by default
    /// clears the underlying storage buffer.
    public mutating func removeAll(keepingCapacity keep: Bool = false) {
        if !keep {
            bits.removeAll(keepingCapacity: false)
        } else {
            bits[0 ..< bits.count] = [0]
        }
        count = 0
        cardinality = 0
    }

    // MARK: Private Properties and Helper Methods

    /// Structure holding the bits.
    fileprivate var bits = [Int]()

    fileprivate func valueAtIndex(_ logicalIndex: Int) -> Bool {
        let indexPath = realIndexPath(logicalIndex)
        var mask = 1 << indexPath.bitIndex
        mask = mask & bits[indexPath.arrayIndex]
        return mask != 0
    }

    fileprivate mutating func setValue(_ newValue: Bool, atIndex logicalIndex: Int) {
        let indexPath = realIndexPath(logicalIndex)
        let mask = 1 << indexPath.bitIndex
        let oldValue = mask & bits[indexPath.arrayIndex] != 0

        switch (oldValue, newValue) {
        case (false, true):
            cardinality += 1
        case (true, false):
            cardinality -= 1
        default:
            break
        }

        if newValue {
            bits[indexPath.arrayIndex] |= mask
        } else {
            bits[indexPath.arrayIndex] &= ~mask
        }
    }

    fileprivate func realIndexPath(_ logicalIndex: Int) -> (arrayIndex: Int, bitIndex: Int) {
        return (logicalIndex / Constants.IntSize, logicalIndex % Constants.IntSize)
    }

    fileprivate func checkIndex(_ index: Int, lessThan: Int? = nil) {
        let bound = lessThan == nil ? count : lessThan
        precondition(!isEmpty && index < bound!, "Index out of range (\(index))")
    }

    // MARK: Constants

    fileprivate struct Constants {
        // Int size in bits
        static let IntSize = MemoryLayout<Int>.size * 8
    }
}

extension BitArray: MutableCollection {

    // MARK: MutableCollection Protocol Conformance

    /// Always zero, which is the index of the first bit when non-empty.
    public var startIndex: Int {
        return 0
    }

    /// Always `count`, which the successor of the last valid
    /// subscript argument.
    public var endIndex: Int {
        return count
    }

    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return i + 1
    }

    /// Provides random access to individual bits using square bracket noation.
    /// The index must be less than the number of items in the bit array.
    /// If you attempt to get or set a bit at a greater
    /// index, you’ll trigger an error.
    public subscript(index: Int) -> Bool {
        get {
            checkIndex(index)
            return valueAtIndex(index)
        }
        set {
            checkIndex(index)
            setValue(newValue, atIndex: index)
        }
    }
}

extension BitArray: ExpressibleByArrayLiteral {

    // MARK: ExpressibleByArrayLiteral Protocol Conformance

    /// Constructs a bit array using a `Bool` array literal.
    /// `let example: BitArray = [true, false, true]`
    public init(arrayLiteral elements: Bool...) {
        bits.reserveCapacity((elements.count / Constants.IntSize) + 1)
        for element in elements {
            append(element)
        }
    }
}

extension BitArray: CustomStringConvertible {

    // MARK: CustomStringConvertible Protocol Conformance

    /// A string containing a suitable textual
    /// representation of the bit array.
    public var description: String { return binaryString }
    public var binaryString: String { return map { "\($0 == true ? 1 : 0)" }.joined() }
}

/// Returns `true` if and only if the bit arrays contain the same bits in the same order.
public func == (lhs: BitArray, rhs: BitArray) -> Bool {
    if lhs.count != rhs.count || lhs.cardinality != rhs.cardinality {
        return false
    }
    return lhs.elementsEqual(rhs)
}

public extension BitArray {
    func asBoolArray() -> [Bool] {
        return self.map { $0 }
    }

    // https://stackoverflow.com/a/28930093/1311272
    func asBytesArray() -> [UInt8] {
        let numBits = self.count
        let numBytes = (numBits + 7) / 8
        var bytes = [UInt8](repeating: 0, count: numBytes)

        for (index, bit) in self.enumerated() where bit == true {
            bytes[index / 8] += UInt8(1 << (7 - index % 8))
        }

        return bytes
    }

    func asData() -> Data {
        return Data(self.asBytesArray())
    }
}
