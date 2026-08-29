/// 本地优先数据库骨架（GRDB）：建库、迁移与队列管理。
///
/// 负责 SQLite 文件路径、迁移与 `DatabaseQueue` 生命周期。**表结构与迁移逻辑由宿主
/// 通过 [DatabaseSchemaProvider] 注入**，本类型不依赖任何业务表，可独立编译。

import Foundation
import GRDB

/// 数据库 schema 提供者 —— 由宿主 App 注入，声明库文件路径、迁移器与可清空表清单。
///
/// 中台包只管理数据库生命周期，业务表结构与迁移逻辑交由宿主定制。
protocol DatabaseSchemaProvider {
    /// 应用支持目录下的子目录名（业务隔离用）。
    var directoryName: String { get }
    /// 数据库文件名。
    var fileName: String { get }
    /// GRDB 迁移器（建表 / 升级）。
    var migrator: DatabaseMigrator { get }
    /// 注销清数据时需清空的业务表名清单（按依赖顺序，仅删行不删表）。
    var eraseTableNames: [String] { get }
}

/// 本地数据库骨架单例。
///
/// 负责 SQLite 文件路径、迁移与 `DatabaseQueue` 生命周期。
final class AppDatabase {
    static let shared = AppDatabase()

    /// schema 提供者；宿主 App 启动时注入。
    static var schemaProvider: DatabaseSchemaProvider?

    private(set) var dbQueue: DatabaseQueue?

    private init() {}

    /// 创建应用支持目录下的数据库并执行迁移。
    ///
    /// - Returns: 无
    /// - Throws: 文件系统或迁移错误
    func prepare() throws {
        guard let schema = Self.schemaProvider else {
            throw AppDatabaseError.schemaNotConfigured
        }
        let dir = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent(schema.directoryName, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let dbURL = dir.appendingPathComponent(schema.fileName)
        let queue = try DatabaseQueue(path: dbURL.path)
        try schema.migrator.migrate(queue)
        dbQueue = queue
    }

    /// 清空全部业务表（注销清数据用）。
    ///
    /// 保留表结构，仅删除全部行；失败时抛错由调用方决定是否阻断注销。
    /// - Throws: 数据库写错误
    func eraseAll() throws {
        guard let queue = dbQueue, let schema = Self.schemaProvider else {
            throw AppDatabaseError.databaseNotReady
        }
        try queue.write { db in
            for table in schema.eraseTableNames {
                try db.execute(sql: "DELETE FROM \(table)")
            }
        }
    }
}

/// 数据库骨架错误。
enum AppDatabaseError: Error {
    /// 数据库尚未初始化（prepare 前调用）。
    case databaseNotReady
    /// schema 提供者未注入（prepare 前须注册 AppDatabase.schemaProvider）。
    case schemaNotConfigured
}
