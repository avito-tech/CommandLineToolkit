import PathLib

extension AbsolutePath {
    public static var certsPath: AbsolutePath {
        return .home.appending(relativePath: ".ai/certs/")
    }

    public static var personalPrivateKeyPath: AbsolutePath {
        return .certsPath.appending(relativePath: "personal.key")
    }

    public static var personalCertificatePath: AbsolutePath {
        return .certsPath.appending(relativePath: "personal.crt")
    }
}
