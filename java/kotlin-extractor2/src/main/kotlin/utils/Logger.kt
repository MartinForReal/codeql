package com.github.codeql

import com.intellij.psi.PsiElement
import java.io.File
import java.io.FileWriter
import java.io.OutputStreamWriter
import java.io.Writer
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Stack

/**
 * Counts the number of times each diagnostic message (based on the
 * location of the diagnostic from the stack trace, and its severity)
 * has been emitted.
 */
class DiagnosticCounter() {
    public val diagnosticInfo = mutableMapOf<Pair<String, Severity>, Int>()
    public val diagnosticLimit: Int

    init {
        diagnosticLimit =
            System.getenv("CODEQL_EXTRACTOR_KOTLIN_DIAGNOSTIC_LIMIT")?.toIntOrNull() ?: 100
    }
}

/**
 * The severity of a diagnostic message.
 */
enum class Severity(val sev: Int) {
    WarnLow(1),
    Warn(2),
    WarnHigh(3),
    /** Minor extractor errors, with minimal impact on analysis. */
    ErrorLow(4),
    /** Most extractor errors, with local impact on analysis. */
    Error(5),
    /** Javac errors. */
    ErrorHigh(6),
    /** Severe extractor errors affecting a single source file. */
    ErrorSevere(7),
    /** Severe extractor errors likely to affect multiple source files. */
    ErrorGlobal(8)
}

/**
 * Given a log message, this wrapper class adds info like a timestamp,
 * and formats it for the different output targets.
 */
class LogMessage(private val kind: String, private val message: String) {
    val timestamp: String

    init {
        timestamp = "${SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(Date())}"
    }

    fun toText(): String {
        return "[$timestamp K] [$kind] $message"
    }

    private fun escapeForJson(str: String): String {
        return str.replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\u0000", "\\u0000")
            .replace("\u0001", "\\u0001")
            .replace("\u0002", "\\u0002")
            .replace("\u0003", "\\u0003")
            .replace("\u0004", "\\u0004")
            .replace("\u0005", "\\u0005")
            .replace("\u0006", "\\u0006")
            .replace("\u0007", "\\u0007")
            .replace("\u0008", "\\b")
            .replace("\u0009", "\\t")
            .replace("\u000A", "\\n")
            .replace("\u000B", "\\u000B")
            .replace("\u000C", "\\f")
            .replace("\u000D", "\\r")
            .replace("\u000E", "\\u000E")
            .replace("\u000F", "\\u000F")
    }

    fun toJsonLine(): String {
        val kvs =
            listOf(
                Pair("origin", "CodeQL Kotlin extractor"),
                Pair("timestamp", timestamp),
                Pair("kind", kind),
                Pair("message", message)
            )
        return "{ " +
            kvs.map { p -> "\"${p.first}\": \"${escapeForJson(p.second)}\"" }.joinToString(", ") +
            " }\n"
    }
}

data class ExtractorContext(
    val kind: String,
    val element: PsiElement,
    val name: String,
    val loc: String
)

interface BasicLogger {
    abstract fun trace(dtw: DiagnosticTrapWriter, msg: String)
    abstract fun debug(dtw: DiagnosticTrapWriter, msg: String)
    abstract fun info(dtw: DiagnosticTrapWriter, msg: String)
    abstract fun warn(dtw: DiagnosticTrapWriter, msg: String, extraInfo: String?)
    abstract fun error(dtw: DiagnosticTrapWriter, msg: String, extraInfo: String?)
    abstract fun flush()
}

/**
 * LoggerBase actually writes log messages to a log file, and to
 * the DiagnosticTrapWriter that it is passed.
 * It is only usde directly from the DiagnosticTrapWriter. Everything
 * else will use a Logger that wraps it (and the DiagnosticTrapWriter).
 */
class LoggerBase(val diagnosticCounter: DiagnosticCounter): BasicLogger {
    private val verbosity: Int

    init {
        verbosity = System.getenv("CODEQL_EXTRACTOR_KOTLIN_VERBOSITY")?.toIntOrNull() ?: 3
    }

    private val logStream: Writer

    init {
        val extractorLogDir = System.getenv("CODEQL_EXTRACTOR_JAVA_LOG_DIR")
        if (extractorLogDir == null || extractorLogDir == "") {
            logStream = OutputStreamWriter(System.out)
        } else {
            val logFile = File.createTempFile("kotlin-extractor.", ".log", File(extractorLogDir))
            logStream = FileWriter(logFile)
        }
    }

    private fun getDiagnosticLocation(): String? {
        val st = Exception().stackTrace
        for (x in st) {
            when (x.className) {
                "com.github.codeql.LoggerBase",
                "com.github.codeql.Logger",
                "com.github.codeql.FileLogger" -> {}
                else -> {
                    return x.toString()
                }
            }
        }
        return null
    }

    fun diagnostic(
        dtw: DiagnosticTrapWriter,
        severity: Severity,
        msg: String,
        extraInfo: String?,
        loggerState: LoggerState?,
        locationString: String? = null,
        mkLocationId: () -> Label<DbLocation> = { dtw.unknownLocation }
    ) {
        val diagnosticLoc = getDiagnosticLocation()
        val diagnosticLocStr = if (diagnosticLoc == null) "<unknown location>" else diagnosticLoc
        val suffix =
            if (diagnosticLoc == null) {
                "    Missing caller information.\n"
            } else {
                val key = Pair(diagnosticLoc, severity)
                val count = 1 + diagnosticCounter.diagnosticInfo.getOrDefault(key, 0)
                diagnosticCounter.diagnosticInfo[key] = count
                when {
                    diagnosticCounter.diagnosticLimit <= 0 -> ""
                    count == diagnosticCounter.diagnosticLimit ->
                        "    Limit reached for diagnostics from $diagnosticLoc.\n"
                    count > diagnosticCounter.diagnosticLimit -> return
                    else -> ""
                }
            }
        val fullMsgBuilder = StringBuilder()
        fullMsgBuilder.append(msg)
        if (extraInfo != null) {
            fullMsgBuilder.append('\n')
            fullMsgBuilder.append(extraInfo)
        }

        if (loggerState != null) {
            val extractorContextStack = loggerState.extractorContextStack
            val iter = extractorContextStack.listIterator(extractorContextStack.size)
            while (iter.hasPrevious()) {
                val x = iter.previous()
                fullMsgBuilder.append("  ...while extracting a ${x.kind} (${x.name}) at ${x.loc}\n")
            }
        }

        fullMsgBuilder.append(suffix)

        val fullMsg = fullMsgBuilder.toString()
        // Now that we have passed the early returns above, we know that
        // we're actually going to need the location, so let's create it
        val locationId = mkLocationId()
        emitDiagnostic(dtw, loggerState, severity, diagnosticLocStr, msg, fullMsg, locationString, locationId)
    }

    private fun emitDiagnostic(
        dtw: DiagnosticTrapWriter,
        loggerState: LoggerState?,
        severity: Severity,
        diagnosticLocStr: String,
        msg: String,
        fullMsg: String,
        locationString: String? = null,
        locationId: Label<DbLocation>
    ) {
        val locStr = if (locationString == null) "" else "At " + locationString + ": "
        val kind = if (severity <= Severity.WarnHigh) "WARN" else "ERROR"
        val logMessage = LogMessage(kind, "Diagnostic($diagnosticLocStr): $locStr$fullMsg")
        val diagLabel = dtw.getFreshIdLabel<DbDiagnostic>()
        dtw.writeDiagnostics(
            diagLabel,
            "CodeQL Kotlin extractor",
            severity.sev,
            "",
            msg,
            "${logMessage.timestamp} $fullMsg",
            locationId
        )
        if (loggerState != null) {
            dtw.writeDiagnostic_for(
                diagLabel,
                StringLabel("compilation"),
                loggerState.fileNumber,
                loggerState.fileDiagnosticCount++
            )
        }
        logStream.write(logMessage.toJsonLine())
    }

    override fun trace(dtw: DiagnosticTrapWriter, msg: String) {
        if (verbosity >= 4) {
            val logMessage = LogMessage("TRACE", msg)
            dtw.writeComment(logMessage.toText())
            logStream.write(logMessage.toJsonLine())
        }
    }

    override fun debug(dtw: DiagnosticTrapWriter, msg: String) {
        if (verbosity >= 4) {
            val logMessage = LogMessage("DEBUG", msg)
            dtw.writeComment(logMessage.toText())
            logStream.write(logMessage.toJsonLine())
        }
    }

    override fun info(dtw: DiagnosticTrapWriter, msg: String) {
        if (verbosity >= 3) {
            val logMessage = LogMessage("INFO", msg)
            dtw.writeComment(logMessage.toText())
            logStream.write(logMessage.toJsonLine())
        }
    }

    override fun warn(dtw: DiagnosticTrapWriter, msg: String, extraInfo: String?) {
        warn(dtw, msg, extraInfo, null)
    }

    fun warn(dtw: DiagnosticTrapWriter, msg: String, extraInfo: String?, loggerState: LoggerState?) {
        if (verbosity >= 2) {
            diagnostic(dtw, Severity.Warn, msg, extraInfo, loggerState)
        }
    }

    override fun error(dtw: DiagnosticTrapWriter, msg: String, extraInfo: String?) {
        error(dtw, msg, extraInfo, null)
    }

    fun error(dtw: DiagnosticTrapWriter, msg: String, extraInfo: String?, loggerState: LoggerState?) {
        if (verbosity >= 1) {
            diagnostic(dtw, Severity.Error, msg, extraInfo, loggerState)
        }
    }

/*
OLD: KE1
    fun printLimitedDiagnosticCounts(dtw: DiagnosticTrapWriter) {
        for ((caller, info) in diagnosticCounter.diagnosticInfo) {
            val severity = info.first
            val count = info.second
            if (count >= diagnosticCounter.diagnosticLimit) {
                val message =
                    "Total of $count diagnostics (reached limit of ${diagnosticCounter.diagnosticLimit}) from $caller."
                if (verbosity >= 1) {
                    emitDiagnostic(dtw, severity, "Limit", message, message, null, dtw.unknownLocation)
                }
            }
        }
    }
*/

    override fun flush() {
        logStream.flush()
    }

    fun close() {
        logStream.close()
    }
}

/**
 * Logger is the high-level interface for writint log messages.
 */
open class Logger(val loggerBase: LoggerBase, val dtw: DiagnosticTrapWriter): BasicLogger {
    override fun flush() {
        dtw.flush()
        loggerBase.flush()
    }

    override fun trace(dtw: DiagnosticTrapWriter, msg: String) {
        loggerBase.trace(dtw, msg)
    }

    fun trace(msg: String) {
        trace(dtw, msg)
    }

    fun trace(msg: String, exn: Throwable) {
        trace(msg + "\n" + exn.stackTraceToString())
    }

    override fun debug(dtw: DiagnosticTrapWriter, msg: String) {
        loggerBase.debug(dtw, msg)
    }

    fun debug(msg: String) {
        debug(dtw, msg)
    }

    override fun info(dtw: DiagnosticTrapWriter, msg: String) {
        loggerBase.info(dtw, msg)
    }

    fun info(msg: String) {
        info(dtw, msg)
    }

    override fun warn(dtw: DiagnosticTrapWriter, msg: String, extraInfo: String?) {
        loggerBase.warn(dtw, msg, extraInfo, null)
    }

    private fun warn(msg: String, extraInfo: String?) {
        warn(dtw, msg, extraInfo)
    }

    fun warn(msg: String, exn: Throwable) {
        warn(msg, exn.stackTraceToString())
    }

    fun warn(msg: String) {
        warn(msg, null)
    }

    override fun error(dtw: DiagnosticTrapWriter, msg: String, extraInfo: String?) {
        loggerBase.error(dtw, msg, extraInfo, null)
    }

    private fun error(msg: String, extraInfo: String?) {
        error(dtw, msg, extraInfo)
    }

    fun error(msg: String) {
        error(msg, null)
    }

    fun error(msg: String, exn: Throwable) {
        error(msg, exn.stackTraceToString())
    }
}

data class LoggerState (
    val extractorContextStack: Stack<ExtractorContext>,
    val fileNumber: Int,
    var fileDiagnosticCount: Int
)

class FileLogger(loggerBase: LoggerBase, val ftw: FileTrapWriter, fileNumber: Int) :
    Logger(loggerBase, ftw.getDiagnosticTrapWriter()) {

    val loggerState = LoggerState(Stack<ExtractorContext>(), fileNumber, 0)

    override fun warn(dtw: DiagnosticTrapWriter, msg: String, extraInfo: String?) {
        loggerBase.warn(dtw, msg, extraInfo, loggerState)
    }

/*
OLD: KE1
    fun warnElement(msg: String, element: IrElement, exn: Throwable? = null) {
        val locationString = ftw.getLocationString(element)
        val mkLocationId = { ftw.getLocation(element) }
        loggerBase.diagnostic(
            ftw.getDiagnosticTrapWriter(),
            Severity.Warn,
            msg,
            exn?.stackTraceToString(),
            locationString,
            mkLocationId
        )
    }
*/

    override fun error(dtw: DiagnosticTrapWriter, msg: String, extraInfo: String?) {
        loggerBase.error(dtw, msg, extraInfo, loggerState)
    }

    fun errorElement(msg: String, element: PsiElement /* TODO , exn: Throwable? = null */) {
        val locationString = ftw.getLocationString(element)
        val mkLocationId = { ftw.getLocation(element) }
        loggerBase.diagnostic(
            ftw.getDiagnosticTrapWriter(),
            Severity.Error,
            msg,
            null, // OLD: KE1: exn?.stackTraceToString(),
            loggerState,
            locationString,
            mkLocationId
        )
    }
}
