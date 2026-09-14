package com.zhiqihuayun.demo

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.foundation.storage.AppDatabase
import com.zhiqihuayun.foundation.storage.DatabaseSchemaProvider
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/** Demo 专用业务表结构（宿主注入示范：中台只管库生命周期，表结构宿主定）。 */
private object DemoNoteSchema : DatabaseSchemaProvider {
    override val databaseName = "demo_notes.db"
    override val version = 1
    override val eraseTableNames = listOf("demo_note")

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(
            "CREATE TABLE IF NOT EXISTS demo_note (" +
                "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                "content TEXT NOT NULL, " +
                "created_at INTEGER NOT NULL)"
        )
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        // Demo v1 无迁移。
    }
}

/**
 * Storage 本地存储 Demo（foundation.storage #93）。
 * 4 组排查：①建库 + 写入 ②读取列表 ③删除单条 ④eraseAll 清空。
 * 表结构由 Demo 注入（demo_note），写读删清全走 SQLiteOpenHelper；
 * 线程模型=调用方切 IO（对齐 iOS GRDB dbQueue 语义）。
 */
@Composable
fun StorageDemo() {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var status by remember { mutableStateOf("（未建库）") }
    var notes by remember { mutableStateOf(listOf<String>()) }

    fun refresh(db: AppDatabase) {
        scope.launch(Dispatchers.IO) {
            val cursor = db.readableDatabase.rawQuery(
                "SELECT id, content FROM demo_note ORDER BY id", null
            )
            val rows = mutableListOf<String>()
            while (cursor.moveToNext()) {
                rows += "#${cursor.getLong(0)} ${cursor.getString(1)}"
            }
            cursor.close()
            withContext(Dispatchers.Main) { notes = rows }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        DemoSection("D1 · 建库 + 写入") {
            Text(status, fontSize = AppFont.sizeSm, color = AppColor.textPrimary)
            TextButton(onClick = {
                scope.launch(Dispatchers.IO) {
                    val db = AppDatabase(context, DemoNoteSchema)
                    db.writableDatabase.execSQL(
                        "INSERT INTO demo_note (content, created_at) VALUES (?, ?)",
                        arrayOf("演示笔记 ${System.currentTimeMillis() % 10000}", System.currentTimeMillis())
                    )
                    val cursor = db.readableDatabase.rawQuery("SELECT COUNT(*) FROM demo_note", null)
                    cursor.moveToFirst()
                    val count = cursor.getInt(0)
                    cursor.close()
                    withContext(Dispatchers.Main) {
                        status = "建库成功（demo_notes.db v1），当前共 $count 条"
                        refresh(db)
                    }
                }
            }) { Text("prepare 建库 + 插入一条演示笔记", fontSize = AppFont.sizeSm) }
        }

        DemoSection("D2 · 读取列表") {
            TextButton(onClick = {
                scope.launch(Dispatchers.IO) {
                    val db = AppDatabase(context, DemoNoteSchema)
                    withContext(Dispatchers.Main) { refresh(db) }
                }
            }) { Text("读取 demo_note 全部行", fontSize = AppFont.sizeSm) }
            Text(
                if (notes.isEmpty()) "（暂无数据）" else notes.joinToString("\n"),
                fontSize = AppFont.sizeSm, color = AppColor.textPrimary
            )
        }

        DemoSection("D3 · 删除单条") {
            TextButton(onClick = {
                scope.launch(Dispatchers.IO) {
                    val db = AppDatabase(context, DemoNoteSchema)
                    val cursor = db.readableDatabase.rawQuery(
                        "SELECT COUNT(*) FROM demo_note", null
                    )
                    cursor.moveToFirst()
                    val count = cursor.getInt(0)
                    cursor.close()
                    if (count > 0) {
                        db.writableDatabase.execSQL("DELETE FROM demo_note WHERE id = (SELECT MAX(id) FROM demo_note)")
                    }
                    withContext(Dispatchers.Main) {
                        status = if (count > 0) "已删除最新一条（剩 ${count - 1} 条）" else "（暂无可删数据）"
                        refresh(db)
                    }
                }
            }) { Text("删除最新一条（MAX id）", fontSize = AppFont.sizeSm) }
            Text(status, fontSize = AppFont.sizeSm, color = AppColor.textPrimary)
        }

        DemoSection("D4 · eraseAll 清空") {
            TextButton(onClick = {
                scope.launch(Dispatchers.IO) {
                    val db = AppDatabase(context, DemoNoteSchema)
                    db.eraseAll()
                    withContext(Dispatchers.Main) {
                        status = "已 eraseAll 清空全部业务表（表结构保留，仅删行）"
                        refresh(db)
                    }
                }
            }) { Text("eraseAll 清空 demo_note", fontSize = AppFont.sizeSm) }
            Text(status, fontSize = AppFont.sizeSm, color = AppColor.textPrimary)
        }

        Text(
            "foundation.storage = 数据库生命周期唯一出口（建库/迁移/注销清数据 eraseAll），" +
                "表结构由宿主 DatabaseSchemaProvider 注入，不做数据建模；" +
                "接入差异=Android 需显式传 Context，iOS 全局静态单例（差异表已放行）。",
            fontSize = AppFont.sizeXs, color = AppColor.textSecondary
        )
    }
}
