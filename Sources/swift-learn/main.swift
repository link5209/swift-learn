import Dispatch
import Foundation


// 假装是网络请求
    func networkRequest(sleepTime: Int, closure: @escaping ()->Void) -> Void {
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
        networkRequest(sleepTime:2, closure: {
            print("2")
            semaphore.signal()
        })
    }
    
    queue.async(group: group) {
        networkRequest(sleepTime:3, closure: {
            print("3")
            semaphore.signal()
        })
    }
    
    group.notify(queue: queue) {
        print("xx")
        semaphore.wait()
        print("yy")
        semaphore.wait()
        print("zz")
        semaphore.wait()
        print("all done")
    }
}


func gcd_line_request() {
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
        semaphore.wait()
        networkRequest(sleepTime:2, closure: {
            print("2")
        })
    }
}


gcd_semaphore_wait_signal()


func gcd_group_enter_leave() {
        let group = DispatchGroup.init()
        let queue = DispatchQueue.global()
        
        // group.enter()

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
            networkRequest(sleepTime:2, closure: {
                print("2 end")
                group.leave()
            })
        }
        
        queue.async(group: group) {
            group.enter()
            print("3 start")
            networkRequest(sleepTime:3, closure: {
                print("3 end")
                group.leave()
            })
        }

        group.notify(queue: queue) { // 所有组完成后回调
            print("all done")
        }

        // group.leave()
    }


gcd_group_enter_leave()

let lock = NSLock()   // a lock to synchronize our access to `value`

var value = 10
func notifyExperiment() {
    // rather than using `DispatchWorkItem`, a reference type, and invoking it multiple times,
    // let's just define some closure or function to run some task

    func performTask(message: String, time: UInt32 = 1) {
        sleep(time)    // we wouldn't do this in production app, but lets do it here for pedagogic purposes, slowing it down enough so we can see what's going on
        value += 5
        print("performTask:", value, message)
    }

    // create a dispatch group to keep track of when these tasks are done

    let group = DispatchGroup()

    // let's enter the group so that we don't have race condition between dispatching tasks
    // to the queues and our notify process

    group.enter()

    // define what notification will be done when the task is done

    group.notify(queue: .init(label: "abc")) {
        // self.lock.unlock()

        print("notify")
    }

    // Let's run our task once on the global queue

    DispatchQueue.global(qos: .utility).async(group: group) {
        performTask(message: "from global queue")
        // networkRequest(sleepTime:2, closure: {
        //     print("2 end")
        //     // group.leave()
        // })
    }

    // Let's run our task also on a custom queue

    let customQueue = DispatchQueue(label: "com.appcoda.delayqueue1", qos: .utility)
    customQueue.async(group: group) {
        performTask(message: "from custom queue", time: 3)
        // networkRequest(sleepTime:1, closure: {
        //     print("1 end")
        //     // group.leave()
        // })
    }

    // Now let's leave the group, resolving our `enter` at the top, allowing the `notify` block
    // to run iff (a) all `enter` calls are balanced with `leave` calls; and (b) once the `async(group:)`
    // calls are done.

    print("waiting leave...")

    // sleep(7)
    group.leave()
    print("leave")
}

// Thread.detachNewThread {
//     print("A new thread,name:\(Thread.current)")
// }
// Thread.detachNewThread {
//     print("A new thread1,name:\(Thread.current)")
// }



