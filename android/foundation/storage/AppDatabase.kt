package com.zhiqihuayun.foundation.storage

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

/**
 * 数据库 schema 提供者 —— 由宿主 App 注入，声明库文件名、版本、建库/迁移与可清空表清单。
 *
 * 中台只管理数据库生命周期，业务表结构与迁移逻辑交由宿主定制
 * （对齐 iOS `DatabaseSchemaProvider` 语义）。
 */
interface DatabaseSchemaProvider {
    /** 数据库文件名（存于应用 filesDir，业务隔离由文件名区分）。 */
    val databaseName: String

    /** schema 版本（升级触发 [onUpgrade]）。 */
    val version: Int

    /** 建库建表（首次创建时执行一次）。 */
    fun onCreate(db: SQLiteDatabase)

    /** 版本迁移（oldVersion → newVersion）。 */
    fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int)

    /** 注销清数据时需清空的业务表名清单（按依赖顺序，仅删行不删表）。 */
    val eraseTableNames: List<String>
}

/**
 * 本地数据库骨架（原生 SQLiteOpenHelper，零三方依赖）。
 *
 * 负责建库与版本迁移；表结构由宿主通过 [DatabaseSchemaProvider] 注入，
 * 本类型不依赖任何业务表，可独立编译（对齐 iOS `AppDatabase` 语义；
 * 接入差异=Android 需显式传 [Context]，iOS 全局静态单例，见差异表）。
 *
 * 线程模型：调用方自行切 IO 线程（SQLiteOpenHelper 自身串行加锁写库）。
 */
class AppDatabase(
    context: Context,
    private val schema: DatabaseSchemaProvider
) : SQLiteOpenHelper(context, schema.databaseName, null, schema.version) {

    override fun onCreate(db: SQLiteDatabase) = schema.onCreate(db)

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) =
        schema.onUpgrade(db, oldVersion, newVersion)

    /** 清空全部业务表（注销清数据用）：保留表结构，仅删除全部行。 */
    fun eraseAll() {
        val db = writableDatabase
        for (table in schema.eraseTableNames) {
            db.execSQL("DELETE FROM $table")
        }
    }
}
