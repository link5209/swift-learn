import NIO
import NIOHTTP1


let threadPool = BlockingIOThreadPool(numberOfThreads: 6)
threadPool.start()

let fileIO = NonBlockingFileIO(threadPool: threadPool)
let filePath = "/Users/jack/swift-learn/Tests/LinuxMain.swift"

func sendfile(_ ctx: ChannelHandlerContext, _ reqPart: HTTPServerRequestPart) {
    switch reqPart {
    case .head(let request):
        let fileHandleAndRegion = fileIO.openFile(path: filePath, eventLoop: ctx.eventLoop)
        fileHandleAndRegion.whenFailure {err in

        }
        fileHandleAndRegion.whenSuccess {file, region in
            var head = HTTPResponseHead(version: request.version, status: .ok)
            head.headers.add(name: "Content-Length", value: "\(region.endIndex)")
            head.headers.add(name: "Content-Type", value: "text/plain; charset=utf-8")
            ctx.write(wrapOutboundOut(.head(head)), promise: nil)

            // 使用promise异步，避免阻塞eventLoop
            ctx.write(wrapOutboundOut(.body(.fileRegion(region)))).then {

            }
            .whenComplete {
                ctx.writeAndFlush(wrapOutboundOut(.end(nil)), promise: nil)
                
            }
            .thenIfError {
                ctx.close()
            }

        }
    case .body, .end:
        break
    }

}
