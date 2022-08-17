extension ProcessControllerProvider {

    public func detach(
        subprocess: Subprocess
    ) throws -> ProcessController {
        let processController = try createProcessController(subprocess: subprocess)
        processController.restreamOutput()
        try processController.start()
        return processController
    }
    
}
