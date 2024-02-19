import ProcessController
import Foundation
import PathLib
import Environment

public protocol MutualTLSCredentialProvider {
    var credential: URLCredential { get async throws }
    var privateKeyPath: AbsolutePath { get async throws }
    var certificatePath: AbsolutePath { get async throws }
}

final actor MutualTLSCredentialProviderImpl: MutualTLSCredentialProvider {
    private let processControllerProvider: ProcessControllerProvider
    private let environmentProvider: EnvironmentProvider
    private var cachedCredential: URLCredential?

    init(
        processControllerProvider: ProcessControllerProvider,
        environmentProvider: EnvironmentProvider
    ) {
        self.processControllerProvider = processControllerProvider
        self.environmentProvider = environmentProvider
    }
    
    var privateKeyPath: AbsolutePath {
        get throws {
            return try environmentProvider.get(.personalPrivateKeyPath) ?? .personalPrivateKeyPath
        }
    }
    
    var certificatePath: AbsolutePath {
        get throws {
            return try environmentProvider.get(.personalCertificatePath) ?? .personalCertificatePath
        }
    }

    var credential: URLCredential {
        get throws {
            if let cachedCredential {
                return cachedCredential
            }

            let personalCertificatePath = try certificatePath

            try importToKeychain(file: privateKeyPath)
            try importToKeychain(file: personalCertificatePath)

            let certificate = try loadPersonalCertificate(at: personalCertificatePath)
            let identity = try loadPersonalIdentity(for: certificate)
            let credential = URLCredential(
                identity: identity,
                certificates: [certificate],
                persistence: .forSession
            )

            cachedCredential = credential
            return credential
        }
    }

    private func loadPersonalCertificate(at path: AbsolutePath) throws -> SecCertificate {
        let certData = try PEM(path: path).asDER()
        guard let cert = SecCertificateCreateWithData(nil, certData.data as CFData) else {
            throw "failed to load cert"
        }

        return cert
    }

    private func loadPersonalIdentity(for certificate: SecCertificate) throws -> SecIdentity {
        var identity: SecIdentity?
        let status = SecIdentityCreateWithCertificate(nil, certificate, &identity)

        guard status == errSecSuccess, let identity else {
            let error = SecCopyErrorMessageString(status, nil) as? String ?? "No error message"
            throw "Failed to load identity with error: \(error)"
        }

        return identity
    }

    private func importToKeychain(file: AbsolutePath) throws {
        let streams = CapturedOutputStreams()
        try? processControllerProvider.zsh(
            "security import \(file)",
            isLoginShell: true,
            outputStreaming: streams.outputStreaming
        )

        if streams.stderrString.contains("No such file or directory") {
            throw "\(file) not found, authorize with `avito login` first"
        }
    }
}

private extension AbsolutePath {
    static var certsPath: AbsolutePath {
        return .home.appending(relativePath: ".avito/certs/")
    }

    static var personalPrivateKeyPath: AbsolutePath {
        return .certsPath.appending(relativePath: "personal.key")
    }

    static var personalCertificatePath: AbsolutePath {
        return .certsPath.appending(relativePath: "personal.crt")
    }
}

private extension EnvironmentKey {
    static var personalPrivateKeyPath: EnvironmentKey<AbsolutePath> {
        return EnvironmentKey<String>.string("IOS_BUILD_MACHINE_TLS_CLIENT_KEY")
            .map(.init(applyTransform: AbsolutePath.init, unapplyTransform: \.pathString))
    }

    static var personalCertificatePath: EnvironmentKey<AbsolutePath> {
        return EnvironmentKey<String>.string("IOS_BUILD_MACHINE_TLS_CLIENT_CERT")
            .map(.init(applyTransform: AbsolutePath.init, unapplyTransform: \.pathString))
    }
}
