export class QRCodeUtil {
  private static PAD0: number = 0xEC
  private static PAD1: number = 0x11

  private static ALIGNMENT_PATTERN_TABLE: number[][] = [
    [],
    [],
    [6, 18],
    [6, 22],
    [6, 26],
    [6, 30],
    [6, 34],
    [6, 22, 38],
    [6, 24, 42],
    [6, 26, 46],
    [6, 28, 50]
  ]

  private static RS_BLOCK_TABLE: number[][][] = [
    [[1, 26, 19]],
    [[1, 26, 16]],
    [[1, 26, 13]],
    [[1, 26, 9]],
    [[1, 44, 34]],
    [[1, 44, 28]],
    [[1, 44, 22]],
    [[1, 44, 16]],
    [[1, 70, 55]],
    [[1, 70, 44]],
    [[2, 35, 17]],
    [[2, 35, 13]],
    [[1, 100, 80]],
    [[2, 50, 32]],
    [[2, 50, 24]],
    [[4, 25, 9]],
    [[1, 134, 108]],
    [[2, 67, 43]],
    [[2, 33, 15, 2, 34, 16]],
    [[2, 33, 11, 2, 34, 12]],
    [[2, 86, 68]],
    [[4, 43, 27]],
    [[4, 43, 19]],
    [[4, 43, 15]],
    [[2, 98, 78]],
    [[4, 49, 31]],
    [[2, 32, 14, 4, 33, 15]],
    [[4, 39, 13, 1, 40, 14]],
    [[2, 121, 97]],
    [[2, 60, 38, 2, 61, 39]],
    [[4, 40, 18, 2, 41, 19]],
    [[4, 40, 14, 2, 41, 15]],
    [[2, 146, 116]],
    [[3, 58, 36, 2, 59, 37]],
    [[4, 36, 16, 4, 37, 17]],
    [[4, 36, 12, 4, 37, 13]],
    [[2, 86, 68, 2, 87, 69]],
    [[4, 69, 43, 1, 70, 44]],
    [[4, 54, 24, 4, 55, 25]],
    [[4, 36, 15, 6, 37, 16]],
  ]

  static generate(content: string): boolean[][] {
    const typeNumber: number = QRCodeUtil.getMinimumType(content, 0)
    return QRCodeUtil.generateByType(content, typeNumber, 0)
  }

  private static getMinimumType(content: string, errorCorrectLevel: number): number {
    const length: number = QRCodeUtil.getUTF8Length(content)
    for (let type = 1; type <= 10; type++) {
      const rsBlocks: number[][] = QRCodeUtil.getRSBlocks(type, errorCorrectLevel)
      const totalDataCount: number = QRCodeUtil.getTotalDataCount(rsBlocks)
      if (length <= totalDataCount - 2) {
        return type
      }
    }
    return 10
  }

  private static getUTF8Length(str: string): number {
    let length: number = 0
    for (let i = 0; i < str.length; i++) {
      const code: number = str.charCodeAt(i)
      if (code < 0x80) {
        length += 1
      } else if (code < 0x800) {
        length += 2
      } else {
        length += 3
      }
    }
    return length + 2
  }

  private static getTotalDataCount(rsBlocks: number[][]): number {
    let total: number = 0
    for (let i = 0; i < rsBlocks.length; i++) {
      total += rsBlocks[i][0] * rsBlocks[i][1]
    }
    return total
  }

  private static generateByType(content: string, typeNumber: number, errorCorrectLevel: number): boolean[][] {
    const moduleCount: number = typeNumber * 4 + 17
    const modules: boolean[][] = []
    for (let row = 0; row < moduleCount; row++) {
      modules[row] = []
      for (let col = 0; col < moduleCount; col++) {
        modules[row][col] = false
      }
    }

    QRCodeUtil.setupPositionProbePattern(0, 0, modules)
    QRCodeUtil.setupPositionProbePattern(moduleCount - 7, 0, modules)
    QRCodeUtil.setupPositionProbePattern(0, moduleCount - 7, modules)
    QRCodeUtil.setupPositionAdjustPattern(typeNumber, modules)
    QRCodeUtil.setupTimingPattern(moduleCount, modules)
    QRCodeUtil.setupTypeInfo(true, errorCorrectLevel, moduleCount, modules)

    if (typeNumber >= 7) {
      QRCodeUtil.setupTypeNumber(true, typeNumber, moduleCount, modules)
    }

    const data: number[] = QRCodeUtil.createData(typeNumber, errorCorrectLevel, content)
    QRCodeUtil.mapData(data, typeNumber, errorCorrectLevel, modules)

    const minPattern: number = QRCodeUtil.getMinimumMask(modules, moduleCount)
    QRCodeUtil.setupTypeInfo(false, errorCorrectLevel, moduleCount, modules)

    if (typeNumber >= 7) {
      QRCodeUtil.setupTypeNumber(false, typeNumber, moduleCount, modules)
    }

    QRCodeUtil.applyMask(minPattern, modules, moduleCount)

    return modules
  }

  private static setupPositionProbePattern(row: number, col: number, modules: boolean[][]): void {
    for (let r = -1; r <= 7; r++) {
      if (row + r <= -1 || modules.length <= row + r) continue
      for (let c = -1; c <= 7; c++) {
        if (col + c <= -1 || modules[0].length <= col + c) continue
        if (
          (0 <= r && r <= 6 && (c === 0 || c === 6)) ||
          (0 <= c && c <= 6 && (r === 0 || r === 6)) ||
          (2 <= r && r <= 4 && 2 <= c && c <= 4)
        ) {
          modules[row + r][col + c] = true
        } else {
          modules[row + r][col + c] = false
        }
      }
    }
  }

  private static setupPositionAdjustPattern(typeNumber: number, modules: boolean[][]): void {
    const pos: number[] = QRCodeUtil.ALIGNMENT_PATTERN_TABLE[typeNumber]
    if (!pos) return
    for (let row = 0; row < pos.length; row++) {
      for (let col = 0; col < pos.length; col++) {
        const rowPos: number = pos[row]
        const colPos: number = pos[col]
        if (modules[rowPos][colPos]) continue
        for (let r = -2; r <= 2; r++) {
          for (let c = -2; c <= 2; c++) {
            if (r === -2 || r === 2 || c === -2 || c === 2 || (r === 0 && c === 0)) {
              modules[rowPos + r][colPos + c] = true
            } else {
              modules[rowPos + r][colPos + c] = false
            }
          }
        }
      }
    }
  }

  private static setupTimingPattern(moduleCount: number, modules: boolean[][]): void {
    for (let r = 8; r < moduleCount - 8; r++) {
      if (modules[r][6] !== undefined) continue
      modules[r][6] = r % 2 === 0
    }
    for (let c = 8; c < moduleCount - 8; c++) {
      if (modules[6][c] !== undefined) continue
      modules[6][c] = c % 2 === 0
    }
  }

  private static setupTypeInfo(test: boolean, errorCorrectLevel: number, moduleCount: number, modules: boolean[][]): void {
    const data: number = (errorCorrectLevel << 3) | 0
    let bits: number = QRCodeUtil.getBCHTypeInfo(data)

    for (let i = 0; i < 15; i++) {
      const mod: boolean = !test && ((bits >> i) & 1) === 1
      if (i < 6) {
        modules[i][8] = mod
      } else if (i < 8) {
        modules[i + 1][8] = mod
      } else {
        modules[moduleCount - 15 + i][8] = mod
      }
    }

    for (let i = 0; i < 15; i++) {
      const mod: boolean = !test && ((bits >> i) & 1) === 1
      if (i < 8) {
        modules[8][moduleCount - i - 1] = mod
      } else if (i < 9) {
        modules[8][15 - i - 1 + 1] = mod
      } else {
        modules[8][15 - i - 1] = mod
      }
    }

    modules[moduleCount - 8][8] = !test
  }

  private static setupTypeNumber(test: boolean, typeNumber: number, moduleCount: number, modules: boolean[][]): void {
    const bits: number = QRCodeUtil.getBCHTypeNumber(typeNumber)

    for (let i = 0; i < 18; i++) {
      const mod: boolean = !test && ((bits >> i) & 1) === 1
      modules[Math.floor(i / 3)][i % 3 + moduleCount - 8 - 3] = mod
    }

    for (let i = 0; i < 18; i++) {
      const mod: boolean = !test && ((bits >> i) & 1) === 1
      modules[i % 3 + moduleCount - 8 - 3][Math.floor(i / 3)] = mod
    }
  }

  private static getBCHTypeInfo(data: number): number {
    let d: number = data << 10
    while (QRCodeUtil.getBCHDigit(d) - QRCodeUtil.getBCHDigit(0x537) >= 0) {
      d ^= 0x537 << (QRCodeUtil.getBCHDigit(d) - QRCodeUtil.getBCHDigit(0x537))
    }
    return (data << 10) | d
  }

  private static getBCHTypeNumber(data: number): number {
    let d: number = data << 12
    while (QRCodeUtil.getBCHDigit(d) - QRCodeUtil.getBCHDigit(0x1F25) >= 0) {
      d ^= 0x1F25 << (QRCodeUtil.getBCHDigit(d) - QRCodeUtil.getBCHDigit(0x1F25))
    }
    return (data << 12) | d
  }

  private static getBCHDigit(data: number): number {
    let digit: number = 0
    while (data !== 0) {
      digit++
      data >>>= 1
    }
    return digit
  }

  private static createData(typeNumber: number, errorCorrectLevel: number, text: string): number[] {
    const buffer: number[] = []
    const utf8Bytes: number[] = QRCodeUtil.stringToUTF8Bytes(text)

    QRCodeUtil.putNumInBuffer(buffer, 4, 4)
    QRCodeUtil.putNumInBuffer(buffer, utf8Bytes.length, QRCodeUtil.getLengthInBits(typeNumber, 4))

    for (let i = 0; i < utf8Bytes.length; i++) {
      QRCodeUtil.putNumInBuffer(buffer, utf8Bytes[i], 8)
    }

    const rsBlocks: number[][] = QRCodeUtil.getRSBlocks(typeNumber, errorCorrectLevel)
    let totalDataCount: number = 0
    for (let i = 0; i < rsBlocks.length; i++) {
      totalDataCount += rsBlocks[i][0] * rsBlocks[i][1]
    }

    if (buffer.length > totalDataCount * 8) {
      return buffer
    }

    if (buffer.length + 4 <= totalDataCount * 8) {
      QRCodeUtil.putNumInBuffer(buffer, 0, 4)
    }

    while (buffer.length % 8 !== 0) {
      buffer.push(0)
    }

    while (true) {
      if (buffer.length >= totalDataCount * 8) break
      buffer.push((QRCodeUtil.PAD0 >> 7) & 1)
      if (buffer.length >= totalDataCount * 8) break
      buffer.push((QRCodeUtil.PAD1 >> 7) & 1)
    }

    return QRCodeUtil.createBytes(buffer, rsBlocks)
  }

  private static getLengthInBits(type: number, mode: number): number {
    if (1 <= type && type < 10) {
      switch (mode) {
        case 1: return 10
        case 2: return 9
        case 4: return 8
        case 8: return 8
      }
    } else if (type < 27) {
      switch (mode) {
        case 1: return 12
        case 2: return 11
        case 4: return 16
        case 8: return 10
      }
    } else if (type < 41) {
      switch (mode) {
        case 1: return 14
        case 2: return 13
        case 4: return 16
        case 8: return 12
      }
    }
    return 0
  }

  private static stringToUTF8Bytes(str: string): number[] {
    const bytes: number[] = []
    for (let i = 0; i < str.length; i++) {
      const code: number = str.charCodeAt(i)
      if (code < 0x80) {
        bytes.push(code)
      } else if (code < 0x800) {
        bytes.push(0xC0 | (code >> 6))
        bytes.push(0x80 | (code & 0x3F))
      } else if (code < 0xD800 || code >= 0xE000) {
        bytes.push(0xE0 | (code >> 12))
        bytes.push(0x80 | ((code >> 6) & 0x3F))
        bytes.push(0x80 | (code & 0x3F))
      } else {
        i++
        const code2: number = str.charCodeAt(i)
        const cp: number = 0x10000 + (((code & 0x3FF) << 10) | (code2 & 0x3FF))
        bytes.push(0xF0 | (cp >> 18))
        bytes.push(0x80 | ((cp >> 12) & 0x3F))
        bytes.push(0x80 | ((cp >> 6) & 0x3F))
        bytes.push(0x80 | (cp & 0x3F))
      }
    }
    return bytes
  }

  private static putNumInBuffer(buffer: number[], num: number, length: number): void {
    for (let i = 0; i < length; i++) {
      buffer.push((num >>> (length - i - 1)) & 1)
    }
  }

  private static getRSBlocks(typeNumber: number, errorCorrectLevel: number): number[][] {
    const rsBlock: number[][] = QRCodeUtil.RS_BLOCK_TABLE[(typeNumber - 1) * 4 + errorCorrectLevel]
    if (!rsBlock) return [[1, 26, 9]]
    const result: number[][] = []
    for (let i = 0; i < rsBlock.length; i++) {
      const count: number = rsBlock[i][0]
      const totalCount: number = rsBlock[i][1]
      const dataCount: number = rsBlock[i][2]
      for (let j = 0; j < count; j++) {
        result.push([totalCount, dataCount])
      }
    }
    return result
  }

  private static createBytes(buffer: number[], rsBlocks: number[][]): number[] {
    let offset: number = 0
    let maxDcCount: number = 0
    let maxEcCount: number = 0

    const dcdata: number[][] = []
    const ecdata: number[][] = []

    for (let r = 0; r < rsBlocks.length; r++) {
      const dcCount: number = rsBlocks[r][1]
      const ecCount: number = rsBlocks[r][0] - dcCount
      maxDcCount = Math.max(maxDcCount, dcCount)
      maxEcCount = Math.max(maxEcCount, ecCount)

      dcdata[r] = []
      for (let i = 0; i < dcCount; i++) {
        dcdata[r][i] = 0xff & QRCodeUtil.bitToByte(buffer.slice(offset, offset + 8))
        offset += 8
      }

      const rsPoly: number[] = QRCodeUtil.getErrorCorrectPolynomial(ecCount)
      const rawPoly: number[] = dcdata[r].slice()
      while (rawPoly.length < rsPoly.length - 1) {
        rawPoly.push(0)
      }

      const modPoly: number[] = QRCodeUtil.modPoly(rawPoly, rsPoly)
      ecdata[r] = []
      for (let i = 0; i < rsPoly.length - 1; i++) {
        const index: number = i + modPoly.length - (rsPoly.length - 1)
        ecdata[r][i] = index >= 0 ? modPoly[index] : 0
      }
    }

    let totalCodeCount: number = 0
    for (let i = 0; i < rsBlocks.length; i++) {
      totalCodeCount += rsBlocks[i][0]
    }

    const data: number[] = []
    let index: number = 0
    for (let i = 0; i < maxDcCount; i++) {
      for (let r = 0; r < rsBlocks.length; r++) {
        if (i < dcdata[r].length) {
          data[index] = dcdata[r][i]
          index++
        }
      }
    }

    for (let i = 0; i < maxEcCount; i++) {
      for (let r = 0; r < rsBlocks.length; r++) {
        if (i < ecdata[r].length) {
          data[index] = ecdata[r][i]
          index++
        }
      }
    }

    return data
  }

  private static bitToByte(bits: number[]): number {
    let data: number = 0
    for (let i = 0; i < bits.length; i++) {
      data = (data << 1) | bits[i]
    }
    return data
  }

  private static getErrorCorrectPolynomial(errorCorrectLength: number): number[] {
    let a: number[] = [1]
    for (let i = 0; i < errorCorrectLength; i++) {
      a = QRCodeUtil.multiplyPoly(a, [1, QRCodeUtil.gexp(i)])
    }
    return a
  }

  private static glog(n: number): number {
    const LOG_TABLE: number[] = [
      -1, 0, 1, 25, 2, 50, 26, 198, 3, 223, 51, 238, 27, 104, 199, 75, 4, 100, 224, 14, 52, 141,
      239, 129, 28, 193, 105, 248, 200, 8, 76, 113, 5, 138, 101, 47, 225, 36, 15, 33, 53, 147,
      142, 218, 240, 18, 130, 69, 29, 181, 194, 125, 106, 39, 249, 185, 201, 154, 9, 120, 77,
      228, 114, 166, 6, 191, 139, 98, 102, 221, 48, 253, 226, 152, 37, 179, 16, 145, 34, 136,
      54, 208, 148, 206, 143, 150, 219, 189, 241, 210, 19, 92, 131, 56, 70, 64, 30, 66, 182,
      163, 195, 72, 126, 110, 107, 58, 40, 84, 250, 133, 186, 61, 202, 94, 155, 159, 10, 21,
      121, 43, 78, 212, 229, 172, 115, 243, 167, 87, 7, 112, 192, 247, 140, 128, 99, 13, 103,
      74, 222, 237, 49, 197, 254, 24, 227, 165, 153, 119, 38, 184, 180, 124, 17, 68, 146,
      217, 35, 32, 137, 46, 55, 63, 209, 91, 149, 188, 207, 205, 144, 135, 151, 178, 220,
      252, 190, 97, 242, 86, 211, 171, 20, 42, 93, 158, 132, 60, 57, 83, 71, 109, 65, 162,
      31, 45, 67, 216, 183, 123, 164, 118, 196, 23, 73, 236, 127, 12, 111, 246, 108, 161,
      59, 82, 41, 157, 85, 170, 251, 96, 134, 177, 187, 204, 62, 90, 203, 89, 95, 176, 156,
      169, 160, 81, 11, 245, 22, 235, 122, 117, 44, 215, 79, 174, 213, 233, 230, 231, 173,
      232, 116, 214, 244, 234, 168, 80, 88, 175
    ]
    if (n < 1) {
      return 0
    }
    return LOG_TABLE[n]
  }

  private static gexp(n: number): number {
    const EXP_TABLE: number[] = [
      1, 2, 4, 8, 16, 32, 64, 128, 29, 58, 116, 232, 205, 135, 19, 38, 76, 152, 45, 90, 180,
      117, 234, 201, 143, 3, 6, 12, 24, 48, 96, 192, 157, 39, 78, 156, 37, 74, 148, 53, 106,
      212, 181, 119, 238, 193, 159, 35, 70, 140, 5, 10, 20, 40, 80, 160, 93, 186, 105, 210,
      185, 111, 222, 161, 95, 190, 97, 194, 153, 47, 94, 188, 101, 202, 137, 15, 30, 60, 120,
      240, 253, 231, 211, 187, 107, 214, 177, 127, 254, 225, 223, 163, 91, 182, 113, 226,
      217, 175, 67, 134, 17, 34, 68, 136, 13, 26, 52, 104, 208, 189, 103, 206, 129, 31, 62,
      124, 248, 237, 199, 147, 59, 118, 236, 197, 151, 51, 102, 204, 133, 23, 46, 92, 184,
      109, 218, 169, 79, 158, 33, 66, 132, 21, 42, 84, 168, 77, 154, 41, 82, 164, 85, 170,
      73, 146, 57, 114, 228, 213, 183, 115, 230, 209, 191, 99, 198, 145, 63, 126, 252, 229,
      215, 179, 123, 246, 241, 255, 227, 219, 171, 75, 150, 49, 98, 196, 149, 55, 110, 220,
      165, 87, 174, 65, 130, 25, 50, 100, 200, 141, 7, 14, 28, 56, 112, 224, 221, 167, 83,
      166, 81, 162, 89, 178, 121, 242, 249, 239, 195, 155, 43, 86, 172, 69, 138, 9, 18, 36,
      72, 144, 61, 122, 244, 245, 247, 243, 251, 235, 203, 139, 11, 22, 44, 88, 176, 125,
      250, 233, 207, 131, 27, 54, 108, 216, 173, 71, 142, 1
    ]
    while (n < 0) {
      n += 255
    }
    while (n >= 256) {
      n -= 255
    }
    return EXP_TABLE[n]
  }

  private static multiplyPoly(a: number[], b: number[]): number[] {
    const result: number[] = []
    for (let i = 0; i < a.length + b.length - 1; i++) {
      result[i] = 0
    }
    for (let i = 0; i < a.length; i++) {
      for (let j = 0; j < b.length; j++) {
        result[i + j] ^= QRCodeUtil.gexp(QRCodeUtil.glog(a[i]) + QRCodeUtil.glog(b[j]))
      }
    }
    return result
  }

  private static modPoly(data: number[], generator: number[]): number[] {
    let result: number[] = data.slice()
    while (result.length >= generator.length) {
      const coeff: number = result[0]
      if (coeff === 0) {
        result.shift()
        continue
      }
      for (let i = 0; i < generator.length; i++) {
        result[i] ^= QRCodeUtil.gexp(QRCodeUtil.glog(generator[i]) + QRCodeUtil.glog(coeff))
      }
      result.shift()
    }
    return result
  }

  private static mapData(data: number[], typeNumber: number, errorCorrectLevel: number, modules: boolean[][]): void {
    const moduleCount: number = modules.length
    let inc: number = -1
    let row: number = moduleCount - 1
    let bitIndex: number = 7
    let byteIndex: number = 0

    for (let col = moduleCount - 1; col > 0; col -= 2) {
      if (col === 6) col--

      while (true) {
        for (let c = 0; c < 2; c++) {
          if (modules[row][col - c] === undefined || modules[row][col - c] === false) {
            let dark: boolean = false
            if (byteIndex < data.length) {
              dark = ((data[byteIndex] >>> bitIndex) & 1) === 1
            }
            modules[row][col - c] = dark
            bitIndex--
            if (bitIndex === -1) {
              byteIndex++
              bitIndex = 7
            }
          }
        }
        row += inc
        if (row < 0 || moduleCount <= row) {
          row -= inc
          inc = -inc
          break
        }
      }
    }
  }

  private static getMinimumMask(modules: boolean[][], moduleCount: number): number {
    let min: number = 0
    let minScore: number = -1
    for (let i = 0; i < 8; i++) {
      QRCodeUtil.applyMask(i, modules, moduleCount)
      const score: number = QRCodeUtil.getLostPoint(modules, moduleCount)
      if (minScore < 0 || minScore > score) {
        minScore = score
        min = i
      }
      QRCodeUtil.applyMask(i, modules, moduleCount)
    }
    return min
  }

  private static applyMask(maskPattern: number, modules: boolean[][], moduleCount: number): void {
    for (let row = 0; row < moduleCount; row++) {
      for (let col = 0; col < moduleCount; col++) {
        if (modules[row][col] !== undefined && modules[row][col] !== false) continue
        let mask: boolean = false
        switch (maskPattern) {
          case 0:
            mask = (row + col) % 2 === 0
            break
          case 1:
            mask = row % 2 === 0
            break
          case 2:
            mask = col % 3 === 0
            break
          case 3:
            mask = (row + col) % 3 === 0
            break
          case 4:
            mask = (Math.floor(row / 2) + Math.floor(col / 3)) % 2 === 0
            break
          case 5:
            mask = (row * col) % 2 + (row * col) % 3 === 0
            break
          case 6:
            mask = ((row * col) % 2 + (row * col) % 3) % 2 === 0
            break
          case 7:
            mask = ((row * col) % 3 + (row + col) % 2) % 2 === 0
            break
        }
        if (mask) {
          modules[row][col] = true
        }
      }
    }
  }

  private static getLostPoint(modules: boolean[][], moduleCount: number): number {
    let point: number = 0

    for (let row = 0; row < moduleCount; row++) {
      let sameCount: number = 0
      let last: boolean = false
      for (let col = 0; col < moduleCount; col++) {
        const current: boolean = modules[row][col]
        if (current === last) {
          sameCount++
        } else {
          if (sameCount >= 5) {
            point += 3 + sameCount - 5
          }
          sameCount = 1
          last = current
        }
      }
      if (sameCount >= 5) {
        point += 3 + sameCount - 5
      }
    }

    for (let col = 0; col < moduleCount; col++) {
      let sameCount: number = 0
      let last: boolean = false
      for (let row = 0; row < moduleCount; row++) {
        const current: boolean = modules[row][col]
        if (current === last) {
          sameCount++
        } else {
          if (sameCount >= 5) {
            point += 3 + sameCount - 5
          }
          sameCount = 1
          last = current
        }
      }
      if (sameCount >= 5) {
        point += 3 + sameCount - 5
      }
    }

    for (let row = 0; row < moduleCount - 1; row++) {
      for (let col = 0; col < moduleCount - 1; col++) {
        let count: number = 0
        if (modules[row][col]) count++
        if (modules[row + 1][col]) count++
        if (modules[row][col + 1]) count++
        if (modules[row + 1][col + 1]) count++
        if (count === 0 || count === 4) {
          point += 3
        }
      }
    }

    let darkCount: number = 0
    for (let col = 0; col < moduleCount; col++) {
      for (let row = 0; row < moduleCount; row++) {
        if (modules[row][col]) darkCount++
      }
    }

    const ratio: number = Math.abs(100 * darkCount / moduleCount / moduleCount - 50) / 5
    point += ratio * 10

    return point
  }
}
