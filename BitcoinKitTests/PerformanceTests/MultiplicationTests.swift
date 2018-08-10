//
//  MultiplicationTests.swift
//  BitcoinKitTests
//
//  Created by Alexander Cyon on 2018-07-18.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//


import XCTest
@testable import BitcoinKit

class MultiplicationTests: XCTestCase {

    // Using `Release` optimization flags and NOT using `Debug Executable` when running tests yields the following results:
    // On Macbook Pro 2016, 2.9 GHZ, 16 GB 2133 MHZ Ram:
    // Using `measure` closure: Takes real time ~0.3 seconds, measured time ~0.02 seconds
    func test30HighMultiplications() {
        let expected = ["1JPbzbsAx1HyaDQoLMapWGoqf9pD5uha5m", "1Knh2eFMtzMEtmvGHW14ELG8F9Ny6jV4s3", "15K4QVHD5T1KvW4it56qNuGJoTGMpUaFMj", "1F3zbGb5JLBnmCAAYjCCv35zkggrXfi8LR", "1LWBSfTeaLRNS1vyGSKy2BVW2nd6W9sk8Q", "1J2zofmGpMUSaNGdTZEhMRYXdWsBQFMpS", "1XunvtCGpmb7uw9qxWwaZFfHNFdUmuMVG", "1MFyofP8SVtsEYDHQbZg7XJgfDeSP4ysPm", "1GLiZZVt326aA8JHG2dEJHC591DXDQNKTs", "18PUeum1Su423DmV2jEGdSd3ewiPfsZZ7z", "1zrbUnLczbHkA6pzXuZDD6jNsoKMqGBcy", "1PMB9Etp3xaDKxpmofy1MmjJF1kvCtH8UA", "122Vo9PeKd4j8zSGBeQHdmks6GnkpycXNz", "1KWhn5gquQvXyXp9BMgJ6HYfNwpHZDmJ5c", "1E1oVu22jUEvmQTFDy9bTgabSfmns6fQFY", "1ADGZZSKRqz3ydkn714Qzw1FJSbUZZGEr1", "14X7DSjXSQBqvFVshZuNwVW6GZyNp79AjF", "12TqhXBmGoaaJoudt1MdysYb2JqGWUGoL1", "1Fp1zhPoKnKfm8MLYkQZ33GZRbJpE9inpB", "17QPbFArTP6M6QRg2ZE18D3fvzZYxnRUSb", "18yhGBghaycjg3UhR2fiquffntYQpUGDE7", "1E7rN6ZJ7g6mHYEZ643bJSFXSkwLw6Zzam", "16oS9HkwfDmrCSGkaFe7KDQgkMFy5GXFoc", "12gG3cNVexUjXCY3KqHi891Kiafsb8AaBy", "1N1sRyurQe7YouraPgh4rxV8JfARdv7zAH", "14AJuXrdKFD8RzVtsF89FYVN4DSmb9xEPf", "12GQjWsXZ7rfRYCR4E5bHMg8AkoSxmPBox", "1NMiUoStJMYxfWw6APLRoMs24Fqsr9tmg7", "1KVPFr2XEwessL8J4zmqi5yFqD2BYVJ2Dk", "1LJ5utuGegyKa6YbVTtxzZndFnSdHNzC5C"]

        var calculated = [String]()
        let count = expected.count
        self.measure {
            for i in 1...count {
                let D: Data = curveN(minus: i)
                let privateKey = PrivateKey(data: D, network: .mainnet)
                let publicKey = privateKey.publicKey()
                if calculated.count < count {
                    calculated.append(publicKey.toAddress())
                }
            }
        }
        XCTAssertEqual(calculated.count, expected.count)
        for i in 0..<count {
            XCTAssertEqual(calculated[i], expected[i])
        }
    }

    // Using `Release` optimization flags and NOT using `Debug Executable` when running tests yields the following results:
    // On Macbook Pro 2016, 2.9 GHZ, 16 GB 2133 MHZ Ram:
    // Using `measure` closure: Takes real time ~10 seconds, measured time ~1 seconds
    func test1000LowMultiplications() {
        continueAfterFailure = false
        var calculated = [String]()

        let count = lastTwoCharsBase58UncompressedAddress.count
        self.measure {
            for i in 1...count {
                let privateKeyWif = privateKeyWifFromInt(i)
                let privateKey = try! PrivateKey(wif: privateKeyWif)
                let publicKey = PublicKey(privateKey: privateKey, network: .mainnet)
                let uncompressedBase58Address = publicKey.toAddress()
                let lastTwoChars = String(uncompressedBase58Address.suffix(2))
                if calculated.count < count {
                    calculated.append(lastTwoChars)
                }
            }
        }
        XCTAssertEqual(calculated.count, lastTwoCharsBase58UncompressedAddress.count)
        for i in 0..<count {
            XCTAssertEqual(calculated[i], lastTwoCharsBase58UncompressedAddress[i])
        }
    }
}

private let lastTwoCharsBase58UncompressedAddress = ["Zm", "4m", "V1", "eC", "Yk", "6n", "41", "rv", "2e", "o7", "4i", "sp", "sj", "xk", "fE", "8H", "j1", "ex", "qs", "cw", "bp", "ky", "kg", "x4", "Fc", "o2", "Jj", "uG", "mt", "bW", "Vc", "UJ", "vT", "F7", "ND", "Zu", "xc", "5d", "Cn", "z7", "hb", "Eg", "H7", "cB", "DK", "Dz", "Ne", "5z", "3w", "NS", "L7", "Fo", "1b", "1J", "3e", "Kj", "Wg", "aY", "Sy", "xH", "Ab", "CC", "yr", "kb", "3Y", "ZR", "1P", "c7", "yn", "NC", "7K", "5Z", "Zt", "kY", "6i", "8R", "Ln", "3G", "cJ", "8z", "dX", "EE", "23", "Sp", "mD", "nJ", "CQ", "A1", "QS", "Dy", "4z", "xm", "iA", "Cx", "7g", "JD", "qu", "wE", "5v", "7D", "pr", "sX", "3v", "pX", "LT", "8S", "JH", "Ee", "Bg", "ym", "nd", "p4", "SN", "LQ", "95", "ux", "py", "Rp", "ur", "K6", "Tu", "Nb", "w5", "rS", "Ev", "6N", "X7", "H4", "AE", "qN", "tw", "ec", "ce", "ZT", "4S", "WY", "Mw", "qN", "7h", "Qd", "fE", "99", "TK", "DW", "jv", "QD", "Tx", "3v", "cj", "uK", "Bq", "p9", "hm", "KS", "EJ", "CL", "Nv", "nf", "NY", "yu", "xp", "EQ", "zf", "L6", "85", "xY", "YU", "Np", "Ne", "oD", "Rz", "7R", "JM", "kZ", "oK", "Hm", "yB", "VA", "AT", "8H", "K3", "9c", "4y", "4a", "rj", "9L", "bx", "Fk", "x7", "DM", "fc", "D5", "HR", "6f", "1Z", "ox", "9Z", "8Y", "Jn", "8W", "qw", "ZE", "zP", "ZW", "nr", "bL", "14", "gQ", "3J", "VH", "Xz", "zZ", "Pw", "oZ", "xH", "7a", "i3", "9y", "ry", "B7", "hv", "CR", "Gs", "rK", "ve", "vH", "wi", "CB", "xM", "xi", "yd", "BL", "M8", "XJ", "Fe", "jn", "3g", "hx", "1J", "Vk", "Lq", "pC", "di", "q3", "AB", "PJ", "e6", "E5", "wb", "4k", "2w", "EB", "6R", "pY", "zc", "qL", "rb", "RU", "h4", "VP", "2j", "rj", "mL", "f3", "te", "TP", "xB", "Ug", "Qo", "5W", "9S", "kc", "yk", "fE", "qx", "4Q", "KM", "ug", "Eo", "hv", "Z1", "pf", "vR", "FX", "8Y", "eE", "YY", "MV", "Wq", "v9", "X2", "vX", "Yt", "Cz", "52", "GP", "5X", "nx", "KK", "ft", "5P", "XY", "dY", "Lx", "8e", "U1", "aB", "At", "Bu", "Cq", "ty", "co", "Am", "oW", "oA", "HX", "V9", "Z3", "s9", "1g", "fj", "ER", "N9", "ws", "e7", "qP", "m5", "Sr", "Ns", "ud", "Cw", "DR", "15", "v1", "9u", "WD", "j5", "9i", "5q", "r3", "Dm", "8s", "3s", "Va", "sa", "3G", "8W", "Bq", "rm", "5S", "wR", "AG", "KM", "kJ", "id", "K7", "pE", "N9", "Gn", "pU", "P5", "cV", "2e", "HS", "wo", "9D", "T1", "3L", "RG", "bD", "Eh", "oM", "2U", "Rn", "HV", "9u", "Sb", "dF", "mx", "wC", "Cv", "Yb", "mM", "iQ", "X4", "pN", "vR", "6E", "hT", "dc", "nw", "6s", "sd", "z3", "DB", "ZF", "uv", "C2", "58", "bX", "Kt", "yP", "ha", "o7", "qP", "TX", "62", "K5", "GA", "x5", "tZ", "S2", "CC", "6d", "w8", "ZR", "8L", "VZ", "uA", "1u", "26", "Az", "7M", "R7", "d5", "Jk", "Tw", "rM", "uL", "vx", "st", "pB", "Xq", "1y", "eq", "QQ", "tG", "5i", "K3", "Ra", "PT", "Ln", "qi", "oB", "by", "4a", "Yk", "dN", "qX", "w2", "34", "nr", "TY", "pY", "Zw", "mu", "M1", "wa", "aN", "VM", "5Q", "EH", "Rk", "Eb", "4W", "jX", "HH", "dA", "dX", "3U", "5E", "Vq", "NU", "D3", "PE", "7W", "7F", "dq", "BN", "2k", "M5", "DH", "BD", "f5", "iR", "eL", "eT", "kj", "8z", "nW", "Cr", "yE", "hB", "VK", "Go", "tH", "BD", "gn", "tU", "oP", "3g", "ae", "Yz", "KB", "36", "2Q", "fy", "WD", "SZ", "xY", "Jj", "tk", "tQ", "Bu", "1C", "cw", "Cp", "2s", "BJ", "jx", "rV", "d8", "1q", "Jo", "Ep", "zm", "WR", "2W", "1y", "Zi", "RT", "aC", "PT", "S5", "Gu", "j9", "JR", "JN", "Ce", "tY", "8u", "QK", "CT", "4Z", "sJ", "tQ", "Kf", "PQ", "Ar", "Mx", "dk", "po", "XW", "Uk", "4A", "ch", "yN", "Sq", "Ew", "kJ", "Lh", "3N", "KC", "dy", "62", "k3", "rK", "Tn", "rZ", "aA", "3A", "Ky", "5b", "Dr", "VN", "y4", "i4", "Bb", "rU", "kS", "88", "9H", "pk", "gf", "Bx", "sa", "R9", "GN", "3q", "op", "yi", "zH", "Wa", "WB", "D4", "K4", "bn", "CH", "RE", "7B", "3J", "ft", "Qe", "vS", "Yg", "6S", "Zm", "AD", "EF", "Ua", "a8", "pL", "nq", "vh", "2Q", "Ye", "Uc", "MM", "Sd", "Jd", "kw", "th", "Yr", "z4", "rY", "r1", "Kp", "8m", "ca", "DP", "JU", "qA", "8M", "jT", "zB", "22", "Ss", "Fd", "9e", "Fy", "SG", "Ys", "FR", "Wd", "6e", "s5", "iJ", "Xa", "Ng", "vR", "aZ", "zm", "4j", "Sj", "yi", "vk", "Sv", "iE", "FS", "YW", "7W", "wC", "jy", "rF", "s1", "Xm", "tC", "oJ", "Hi", "zo", "er", "Zr", "a3", "zc", "gJ", "XW", "yV", "De", "7T", "am", "2t", "3T", "49", "sM", "Rf", "A6", "B6", "AJ", "Nb", "5H", "Qv", "Ln", "JD", "ef", "P4", "u3", "G6", "4u", "fk", "vb", "in", "4Y", "2h", "FQ", "AE", "3H", "Br", "ve", "9h", "8W", "i6", "7G", "GD", "FQ", "h7", "DG", "8V", "Cw", "Vz", "ug", "8K", "N4", "S1", "Xs", "L1", "Xn", "63", "hY", "hh", "SU", "C1", "eZ", "Wk", "uB", "d4", "rE", "Yw", "rd", "md", "rw", "8x", "3h", "LB", "QN", "23", "7T", "9x", "An", "MV", "PH", "F6", "tD", "r2", "2D", "tj", "52", "8x", "8T", "zT", "3D", "PT", "T9", "2n", "2t", "rx", "iF", "XT", "Rd", "FZ", "io", "Jp", "UC", "kW", "Fk", "1F", "49", "B5", "6b", "HJ", "p8", "Xu", "pE", "2D", "H5", "Nh", "We", "tq", "2G", "5T", "QN", "VY", "4y", "JE", "6S", "TB", "JX", "4y", "RB", "f3", "95", "xX", "X8", "eT", "8C", "Ug", "A8", "sT", "sG", "mC", "zH", "SV", "FP", "mo", "fw", "fH", "mM", "3U", "cV", "Be", "Fx", "xN", "QA", "5c", "q6", "VE", "AL", "p9", "rT", "Q2", "ju", "dL", "Jq", "7R", "HH", "5G", "Wf", "KF", "fC", "z1", "Nm", "2a", "Uu", "sk", "Cg", "74", "1d", "4S", "Ke", "j9", "Gv", "Vh", "iZ", "vr", "94", "MC", "TR", "eC", "zT", "h5", "pB", "iD", "eW", "h2", "oS", "89", "nJ", "Uf", "HD", "yZ", "nh", "PZ", "hE", "6f", "Z7", "i6", "1F", "kT", "7a", "vH", "wP", "YW", "Fg", "cd", "Ms", "rF", "dA", "UZ", "5w", "UA", "xp", "Vg", "CP", "yn", "ri", "az", "gz", "Tw", "24", "ta", "pD", "1e", "K2", "yt", "HM", "zZ", "UH", "KK", "fd", "hL", "XK", "1T", "Jf", "NH", "nd", "Xg", "Sw", "px", "Dm", "tv", "Xd", "34", "Wx", "BA", "uE", "ww", "1F", "9h", "rc", "oE", "Pt", "7A", "Zh", "kE", "DQ", "91", "Ti", "tw", "ch", "Ww", "Nx", "eQ", "3P", "W5", "r8", "sq", "48", "aL", "zB", "BA", "eQ", "Jq", "qn", "Aq", "3w", "3r", "q3", "HW", "YN", "Vx", "hk", "hm", "ne", "ph", "tP", "EZ", "Lt", "o7", "Ft", "jm", "U3", "hs", "Kd", "5o", "9E", "ti", "oT", "rg", "6m", "sh", "mg", "x2", "hD", "Fc", "25", "33", "Kc", "d5", "NZ", "HR", "TJ", "Lf", "Nk", "Z8", "VA", "md", "Hp", "vf", "So", "hv", "7u"]


protocol ByteConvertible {}
extension ByteConvertible {
    func to32Bytes() -> [UInt8] {
        let capacity = MemoryLayout<Self>.size
        var mutableValue = self
        var bytes = withUnsafePointer(to: &mutableValue) {

            return $0.withMemoryRebound(to: UInt8.self, capacity: capacity) {

                return Array(UnsafeBufferPointer(start: $0, count: capacity))
            }
        }
        bytes = bytes.reversed()
        while bytes.count < 32 {
            bytes = [UInt8(0)] + bytes
        }
        return bytes
    }
}
extension Int: ByteConvertible {}
extension Int {
    func toData() -> Data {
        return Data(to32Bytes())
    }
}

private func privateKeyWifFromInt(_ int: Int, network: Network = .mainnet) -> String {
    let keyData = int.toData()
    let data = Data([network.privatekey]) + keyData
    let checksum = Crypto.sha256sha256(data).prefix(4)
    return Base58.encode(data + checksum)
}
