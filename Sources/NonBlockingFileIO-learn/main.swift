import NIO
import NIOHTTP1


let threadPool = BlockingIOThreadPool(numberOfThreads: 6)
threadPool.start()

let fileIO = NonBlockingFileIO(threadPool: threadPool)
let filePath = "/Users/jack/swift-learn/Tests/LinuxMain.swift"

class FileNIO: ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    public typealias OutboundOut = HTTPServerResponsePart

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
                ctx.write(self.wrapOutboundOut(.head(head)), promise: nil)

                // 使用promise异步，避免阻塞eventLoop
                ctx.write(self.wrapOutboundOut(.body(.fileRegion(region)))).then {
                    ctx.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)

                    let p: EventLoopPromise<Void> = ctx.eventLoop.newPromise()
                    p.futureResult.whenComplete {ctx.close(promise: nil)}
                    return p.futureResult
                }
                .thenIfError {err in
                    ctx.close()
                }
                .whenComplete {
                    try? file.close()
                }

            }
        case .body, .end:
            break
        }
    }
}

