package com.zhiqihuayun.foundation.routing

/**
 * 一级 Tab 目的地（产品主路径）。
 */
enum class MainDestination(val route: String) {
    Ledger("ledger"),
    Charts("charts"),
    Bookkeeping("bookkeeping"),
    Discover("discover"),
    Profile("profile")
}

/**
 * 二级及以下路由（push 后隐藏 BottomBar）。
 */
object SecondaryRoutes {
    const val PLACEHOLDER = "placeholder/{title}"
    const val BILL = "bill"
    const val BUDGET = "budget"
    const val LEDGER_SEARCH = "ledger_search"
    const val ASSETS = "assets"
    const val MORTGAGE = "mortgage"
    const val FX = "fx"
    const val SETTINGS = "settings"
    const val ACCOUNT_SETTINGS = "account_settings"
    const val PERSONAL_INFO = "personal_info"
    const val ACCOUNT_DELETION = "account_deletion"
    const val ACCOUNT_DELETION_CONFIRM = "account_deletion_confirm"
    const val ACCOUNT_SECURITY = "account_security"
    const val FEEDBACK = "feedback"
    const val HELP = "help"
    const val ABOUT = "about"
    const val BOOKKEEPING_EDIT = "bookkeeping_edit/{recordId}"
    const val BOOKKEEPING_COPY = "bookkeeping_copy/{recordId}"
    const val ASSETS_CHART = "assets_chart"
    const val TRANSACTION_DETAIL = "transaction_detail/{recordId}"
    const val DATA_BACKUP = "data_backup"
    const val LOGIN = "login"
    const val PHONE_LOGIN = "phone_login"
    const val EMAIL_LOGIN = "email_login"

    fun bookkeepingEdit(recordId: Long): String = "bookkeeping_edit/$recordId"
    fun bookkeepingCopy(recordId: Long): String = "bookkeeping_copy/$recordId"
    fun transactionDetail(recordId: Long): String = "transaction_detail/$recordId"
    fun placeholder(title: String): String = "placeholder/$title"
}
