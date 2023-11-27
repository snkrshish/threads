import Foundation
import PlaygroundSupport

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

    var chipArray: [Chip] = []
    var runCount = 0
    var isLocked = false
    let mutex = NSCondition()

    func pushChip(item: Chip) {
        mutex.lock()

        isLocked = true
        chipArray.append(item)
        runCount += 1

        mutex.signal()
        mutex.unlock()
    }

    func removeLast() -> Chip {
        mutex.lock()

        while(!isLocked) {
            mutex.wait()
        }

        isLocked = false
        mutex.unlock()
        return chipArray.removeLast()
    }
}


class GeneratingThread: Thread {

    private let storage: Storage

    init(storage: Storage) {
        self.storage = storage
    }

    override func main() {
        let timer = Timer.scheduledTimer(timeInterval: 2.0, target: self,
                                         selector: #selector(timerMethod),
                                         userInfo: nil,
                                         repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 20.0))
    }

    @objc func timerMethod() {
        storage.pushChip(item: Chip.make())
    }
}



class WorkingThread: Thread {
    
    private let storage: Storage

    init(storage: Storage) {
        self.storage = storage
    }
    override func main() {
        repeat {
            storage.removeLast().sodering()
        } while storage.chipArray.isEmpty || storage.isLocked
    }
}

let storage = Storage()
let generate = GeneratingThread(storage: storage)
let working = WorkingThread(storage: storage)

generate.start()
working.start()
