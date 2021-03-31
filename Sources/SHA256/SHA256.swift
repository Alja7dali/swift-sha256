/// Hashing bytes using the SHA256 alghorithm
///
/// https:///en.wikipedia.org/wiki/SHA256

import Base16

// /// The length of the output digest (in bits).
// private let digestLength = 256

// /// The size of each blocks (in bits).
// private let blockBitSize = 512

/// The initial hash value.
private let initalHashValue: Array<UInt32> = [
  0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
]

/// The constants in the algorithm (K).
private let konstants: Array<UInt32> = [
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
  0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
  0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
  0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
  0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
  0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
]

/// Returns the digest.
public func hash(_ bytes: Bytes, encoding using: (Bytes) -> Bytes = Base16.encode) -> Bytes {

  var input = bytes

  /// The initial hash value.
  var currentHashValue = initalHashValue

  // pad the input.
  pad(&input)

  // break the input into N 512-bit blocks.
  let messageBlocks = input.blocks(size: 64) // (blockBitSize/8) == (512/8) == 64

  // process each block.
  for block in messageBlocks {
    process(block, &currentHashValue)
  }

  // finally, compute the result.
  var result = Bytes(repeating: 0, count: 32) // (digestLength/8) == (256/8) == 32
  for (index, element) in currentHashValue.enumerated() {
    let pos = index * 4
    result[pos + 0] = Byte((element >> 24) & 0xff)
    result[pos + 1] = Byte((element >> 16) & 0xff)
    result[pos + 2] = Byte((element >> 8) & 0xff)
    result[pos + 3] = Byte(element & 0xff)
  }

  return using(result)
}

/// process and compute hash from a block.
private func process(_ block: BytesSlice, _ currentHashValue: inout Array<UInt32>) {

  // compute message schedule.
  var W = Array<UInt32>(repeating: 0, count: konstants.count)
  for t in 0..<W.count {
    switch t {
    case 0...15:
      let index = block.startIndex.advanced(by: t * 4)
      // put 4 bytes in each message.
      W[t]  = UInt32(block[index + 0]) << 24
      W[t] |= UInt32(block[index + 1]) << 16
      W[t] |= UInt32(block[index + 2]) << 8
      W[t] |= UInt32(block[index + 3])
    default:
      let σ1 = rotateRight(W[t-2], by: 17) ^ rotateRight(W[t-2], by: 19) ^ (W[t-2] >> 10)
      let σ0 = rotateRight(W[t-15], by: 7) ^ rotateRight(W[t-15], by: 18) ^ (W[t-15] >> 3)
      W[t] = σ1 &+ W[t-7] &+ σ0 &+ W[t-16]
    }
  }

  var a = currentHashValue[0]
  var b = currentHashValue[1]
  var c = currentHashValue[2]
  var d = currentHashValue[3]
  var e = currentHashValue[4]
  var f = currentHashValue[5]
  var g = currentHashValue[6]
  var h = currentHashValue[7]

  // run the main algorithm.
  for t in 0..<konstants.count {
    let Σ1 = rotateRight(e, by: 6) ^ rotateRight(e, by: 11) ^ rotateRight(e, by: 25)
    let ch = (e & f) ^ (~e & g)
    let t1 = h &+ Σ1 &+ ch &+ konstants[t] &+ W[t]

    let Σ0 = rotateRight(a, by: 2) ^ rotateRight(a, by: 13) ^ rotateRight(a, by: 22)
    let maj = (a & b) ^ (a & c) ^ (b & c)
    let t2 = Σ0 &+ maj

    h = g
    g = f
    f = e
    e = d &+ t1
    d = c
    c = b
    b = a
    a = t1 &+ t2
  }

  currentHashValue[0] = a &+ currentHashValue[0]
  currentHashValue[1] = b &+ currentHashValue[1]
  currentHashValue[2] = c &+ currentHashValue[2]
  currentHashValue[3] = d &+ currentHashValue[3]
  currentHashValue[4] = e &+ currentHashValue[4]
  currentHashValue[5] = f &+ currentHashValue[5]
  currentHashValue[6] = g &+ currentHashValue[6]
  currentHashValue[7] = h &+ currentHashValue[7]
}

/// Pad the given byte array to be a multiple of 512 bits.
private func pad(_ input: inout Bytes) {
  // Find the bit count of input.
  let inputBitLength = input.count * 8

  // Append the bit 1 at end of input.
  input.append(0x80)

  // Find the number of bits we need to append.
  //
  // inputBitLength + 1 + bitsToAppend ≡ 448 mod 512
  let mod = inputBitLength % 512
  let bitsToAppend = mod < 448 ? 448 - 1 - mod : 512 + 448 - mod - 1

  // We already appended first 7 bits with 0x80 above.
  input += Bytes(repeating: 0, count: (bitsToAppend - 7) / 8)

  // We need to append 64 bits of input length.
  for byte in UInt64(inputBitLength).makeBytes().lazy.reversed() {
    input.append(byte)
  }
  assert((input.count * 8) % 512 == 0, "Expected padded length to be 512.")
}

private extension Array {
  /// Breaks the array into the given size.
  func blocks(size: Int) -> AnyIterator<ArraySlice<Element>> {
    var currentIndex = startIndex
    return AnyIterator {
      if let nextIndex = self.index(currentIndex, offsetBy: size, limitedBy: self.endIndex) {
        defer { currentIndex = nextIndex }
        return self[currentIndex..<nextIndex]
      }
      return nil
    }
  }
}