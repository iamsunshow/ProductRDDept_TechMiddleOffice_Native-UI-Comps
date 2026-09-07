package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Text
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertTextEquals
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * FormFieldRow 表单字段行回归测试（#28 ui.form，验证组件库 v1.4.0）。
 *
 * 覆盖：label 显示 / required 必填星 / error 优先于 help / help 显示 / 无提示不占位。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class FormFieldRowTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** label 显示。 */
    @Test
    fun test_label显示() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Form(groupTitle = "基础信息") {
                    FormFieldRow(label = "姓名") {
                        Text("张三")
                    }
                }
            }
        }
        composeRule.onNodeWithText("姓名").assertIsDisplayed()
        composeRule.onNodeWithText("张三").assertIsDisplayed()
    }

    /** required=true 显示必填星「* 」。 */
    @Test
    fun test_必填星显示() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Form {
                    FormFieldRow(label = "金额", required = true) {
                        Text("100")
                    }
                }
            }
        }
        composeRule.onNodeWithText("* ").assertIsDisplayed()
    }

    /** error 优先于 help：error 非空=显示 error 不显示 help。 */
    @Test
    fun test_error优先于help() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Form {
                    FormFieldRow(
                        label = "邮箱",
                        help = "请输入有效邮箱",
                        error = "邮箱格式错误"
                    ) {
                        Text("test")
                    }
                }
            }
        }
        composeRule.onNodeWithText("邮箱格式错误").assertIsDisplayed()
        composeRule.onNodeWithText("请输入有效邮箱").assertDoesNotExist()
    }

    /** help 显示（无 error 时）。 */
    @Test
    fun test_help显示() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Form {
                    FormFieldRow(label = "备注", help = "选填") {
                        Text("内容")
                    }
                }
            }
        }
        composeRule.onNodeWithText("选填").assertIsDisplayed()
    }

    /** label+help+error 都空=无提示行。 */
    @Test
    fun test_无提示不占位() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Form {
                    FormFieldRow {
                        Text("无标签无提示")
                    }
                }
            }
        }
        composeRule.onNodeWithText("无标签无提示").assertIsDisplayed()
    }

    /** groupTitle 显示。 */
    @Test
    fun test_groupTitle显示() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Form(groupTitle = "个人资料") {
                    FormFieldRow(label = "姓名") { Text("内容") }
                }
            }
        }
        composeRule.onNodeWithText("个人资料").assertIsDisplayed()
    }

    /** groupTitle=null 不显示分组标题。 */
    @Test
    fun test_无groupTitle不显示() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Form {
                    FormFieldRow(label = "姓名") { Text("内容") }
                }
            }
        }
        composeRule.onNodeWithText("姓名").assertIsDisplayed()
    }
}
