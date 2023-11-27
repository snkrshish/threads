import Foundation

public struct Chip {
    public enum ChipType: UInt32 {
        case small = 1
        case medium
        case big
    }

    public let chipType: ChipType

    public static func make() -> Chip {
        guard let chipType = Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
        }

        return Chip(chipType: chipType)
    }

    public func sodering() {
        let soderingTime = chipType.rawValue
        sleep(UInt32(soderingTime))
    }
}



final class Storage {

    private var chipArray: [Chip] = []
    private var runCount = 0
    private var isLocked = false
    private var mutex = NSCondition()

    private func pushChip(item: Chip) {
        mutex.lock()
        isLocked = true
        chipArray.append(item)
        runCount += 1
        mutex.signal()
        mutex.unlock()
    }

    private func removeLast() -> Chip {
        mutex.lock()
        while !isLocked {
            mutex.wait()
        }
        isLocked = false
        mutex.unlock()
        return chipArray.removeLast()
    }
}



