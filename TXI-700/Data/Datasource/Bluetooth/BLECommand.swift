//
//  BLECommand.swift
//  TXI-700
//
//  Created by 서용준 on 1/5/26.
//

enum BLECommand {
    case btz
    case bts
    case bte
    case btd
    case btm
    case btf
    case bth(String)
    case btb
    case bti(num: Int, name: String)
    case bta(num: Int, name: String)
    case btc(String)
    case btq(Int)
    case btg(Int)
    case btu(Int)
    case btp
    case bsn
    case bst
    case bcf
    case bdc
    case wps(String)
    case wpe(String)
    case wpt(String)
    case btx(String)
    case xxx(String)
}

extension BLECommand {
    var bytes: [UInt8] {
        switch self {
        case .btz: return ascii("BTZ")
        case .bts : return ascii("BTS")
        case .bte : return ascii("BTE")
        case .btd : return ascii("BTD")
        case .btm : return ascii("BTM")
        case .btf : return ascii("BTF")
        case .bth(let title) : return ascii("BTH") + ascii(title) + end()
        case .btb : return ascii("BTB")
        case .bti(let num, let name) : return ascii("BTI") + numTo2ByteAscii(num) + name.toAsciiBytes(maxLength: 20) + end()
        case .bta(let num, let name) : return ascii("BTA") + numTo2ByteAscii(num) + name.toAsciiBytes(maxLength: 20) + end()
        case .btc(let name) : return ascii("BTC") + name.toAsciiBytes(maxLength: 10) + end()
        case .btq(let num) : return ascii("BTQ") + numTo2ByteAscii(num)
        case .btg(let num) : return ascii("BTG") + numTo2ByteAscii(num)
        case .btu(let lang) : return ascii("BTU") + [languageByte(lang)]
        case .btp : return ascii("BTP")
        case .bsn : return ascii("BSN")
        case .bst : return ascii("BST")
        case .bcf : return ascii("BCF")
        case .bdc : return ascii("BDC")
        case .wps(let text) : return ascii("WPS") + ascii(text) + [0x0D, 0x0A]
        case .wpe(let text) : return ascii("WPE") + ascii(text) + [0x0D, 0x0A]
        case .wpt(let text) : return ascii("WPT") + ascii(text) + [0x0D, 0x0A]
        case .btx(let time) : return ascii("BTX") + ascii(time)
        case .xxx(let text) : return ascii("XXX") + ascii(text) + end()
        }
    }
    
    private func ascii(_ s: String) -> [UInt8] {
        Array(s.utf8)
    }
    
    private func languageByte(_ lang: Int) -> UInt8 {
        switch lang {
        case 0: return 0x00
        case 1: return 0x02
        case 2: return 0x01
        default: return 0x00
        }
    }
    
    private func end() -> [UInt8] {
        [0x0A]
    }
}
