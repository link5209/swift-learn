import Dispatch
import Foundation


var value = 0
let lock = NSLock()

func notifyExperiment() {

    func performTask(message: String) {
        print("starting:", message)
        Thread.sleep(forTimeInterval: 2)
        lock.lock()
        value += 5
        lock.unlock()
        print("done:", message)
    }

    let group = DispatchGroup()
    let queue = DispatchQueue.global()

    group.enter()

    queue.async(group: group) {
        performTask(message: "from global queue")
    }

    let customQueue = DispatchQueue(label: "com.appcoda.delayqueue1")
    queue.async(group: group) {
        performTask(message: "from custom queue")
    }

    group.notify(queue: .global()) {
        print("value =", value)
    }

    group.leave()
    group.wait()
}

notifyExperiment()



// 假装是网络请求
func networkRequest(sleepTime: Int, closure: @escaping ()->Void) {
    DispatchQueue.global().async { 
        Thread.sleep(forTimeInterval: TimeInterval(sleepTime))
        // 假装是成功回调
        closure()
    }
}


// 利用 semaphore 来控制
func gcd_semaphore_wait_signal() {
    let semaphore = DispatchSemaphore.init(value: 0)
    let group = DispatchGroup.init()
    let queue = DispatchQueue.global()
    
    queue.async(group: group) {
        networkRequest(sleepTime:1, closure: {
            print("1")
            semaphore.signal()
        })
    }
    
    queue.async(group: group) {
        networkRequest(sleepTime:1, closure: {
            print("2")
            semaphore.signal()
        })
    }
    
    queue.async(group: group) {
        networkRequest(sleepTime:1, closure: {
            print("3")
            semaphore.signal()
        })
    }
    
    group.notify(queue: queue) {
        print("wait 1")
        semaphore.wait()
        print("wait 2")
        semaphore.wait()
        print("wait 3")
        semaphore.wait()
        print("all done")
    }

    sleep(2)
}

// gcd_semaphore_wait_signal()



// 模拟同步
func gcd_line_request() {
    let semaphore = DispatchSemaphore.init(value: 0)
    let group = DispatchGroup.init()
    let queue = DispatchQueue.global()
    
    queue.async(group: group) {
        networkRequest(sleepTime:2, closure: {
            print("1")
            semaphore.signal()
        })
    }
    
    queue.async(group: group) {
        semaphore.wait()
        networkRequest(sleepTime:1, closure: {
            print("2")
        })
    }

    sleep(4)
}

// gcd_line_request()



func gcd_group_enter_leave() {
        let group = DispatchGroup.init()
        let queue = DispatchQueue.global()

        queue.async(group: group) {
            group.enter()
            print("1 start")
            networkRequest(sleepTime:1, closure: {
                print("1 end")
                group.leave()
            })
        }
        
        queue.async(group: group) {
            group.enter()
            print("2 start")
            networkRequest(sleepTime:1, closure: {
                print("2 end")
                group.leave()
            })
        }
        
        queue.async(group: group) {
            group.enter()
            print("3 start")
            networkRequest(sleepTime:2, closure: {
                print("3 end")
                group.leave()
            })
        }

        group.notify(queue: queue) { // 所有组完成后回调
            print("all done")
        }

        group.wait()
    }

// gcd_group_enter_leave()

// Thread.detachNewThread {
//     print("A new thread,name:\(Thread.current)")
// }
// Thread.detachNewThread {
//     print("A new thread1,name:\(Thread.current)")
// }



