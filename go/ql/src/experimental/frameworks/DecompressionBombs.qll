import go

module DecompressionBombs {
  class FlowState extends string {
    FlowState() {
      this =
        [
          "ZstdNewReader", "XzNewReader", "GzipNewReader", "PgzipNewReader", "S2NewReader",
          "SnappyNewReader", "ZlibNewReader", "FlateNewReader", "Bzip2NewReader", "ZipOpenReader",
          "ZipKlauspost", ""
        ]
    }
  }

  /**
   * The additional taint steps that need for creating taint tracking or dataflow.
   */
  abstract class AdditionalTaintStep extends string {
    AdditionalTaintStep() { this = "AdditionalTaintStep" }

    /**
     * Holds if there is a additional taint step between pred and succ.
     */
    abstract predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode);

    /**
     * Holds if there is a additional taint step between pred and succ.
     */
    abstract predicate isAdditionalFlowStep(
      DataFlow::Node fromNode, FlowState fromState, DataFlow::Node toNode, FlowState toState
    );
  }

  /**
   * The Sinks of uncontrolled data decompression
   */
  abstract class Sink extends DataFlow::Node { }

  /**
   * Provides decompression bomb sinks and additional flow steps for `github.com/DataDog/zstd` package
   */
  module DataDogZstd {
    class TheSink extends Sink {
      TheSink() {
        exists(Method f | f.hasQualifiedName("github.com/DataDog/zstd", "reader", "Read") |
          this = f.getACall().getReceiver()
        )
      }
    }

    class TheAdditionalTaintStep extends AdditionalTaintStep {
      TheAdditionalTaintStep() { this = "AdditionalTaintStep" }

      override predicate isAdditionalFlowStep(
        DataFlow::Node fromNode, FlowState fromState, DataFlow::Node toNode, FlowState toState
      ) {
        exists(Function f, DataFlow::CallNode call |
          f.hasQualifiedName("github.com/DataDog/zstd", "NewReader") and
          call = f.getACall()
        |
          fromNode = call.getArgument(0) and
          toNode = call.getResult(0) and
          fromState = "" and
          toState = "ZstdNewReader"
        )
      }

      override predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
        none()
      }
    }
  }

  /**
   * Provides decompression bomb sinks and additional flow steps for `github.com/klauspost/compress/zstd` package
   */
  module KlauspostZstd {
    class TheSink extends Sink {
      TheSink() {
        exists(Method f |
          f.hasQualifiedName("github.com/klauspost/compress/zstd", "Decoder",
            ["WriteTo", "DecodeAll"])
        |
          this = f.getACall().getReceiver()
        )
        or
        exists(Method f |
          f.hasQualifiedName("github.com/klauspost/compress/zstd", "Decoder", "Read")
        |
          this = f.getACall().getReceiver()
        )
      }
    }

    class TheAdditionalTaintStep extends AdditionalTaintStep {
      TheAdditionalTaintStep() { this = "AdditionalTaintStep" }

      override predicate isAdditionalFlowStep(
        DataFlow::Node fromNode, FlowState fromState, DataFlow::Node toNode, FlowState toState
      ) {
        exists(Function f, DataFlow::CallNode call |
          f.hasQualifiedName("github.com/klauspost/compress/zstd", "NewReader") and
          call = f.getACall()
        |
          fromNode = call.getArgument(0) and
          toNode = call.getResult(0) and
          fromState = "" and
          toState = "ZstdNewReader"
        )
      }

      override predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
        none()
      }
    }
  }

  /**
   * Provides additional flow steps for `archive/zip` package
   */
  module ArchiveZip {
    class TheAdditionalTaintStep extends AdditionalTaintStep {
      TheAdditionalTaintStep() { this = "AdditionalTaintStep" }

      override predicate isAdditionalFlowStep(
        DataFlow::Node fromNode, FlowState fromState, DataFlow::Node toNode, FlowState toState
      ) {
        exists(Function f, DataFlow::CallNode call |
          f.hasQualifiedName("archive/zip", ["OpenReader", "NewReader"]) and call = f.getACall()
        |
          fromNode = call.getArgument(0) and
          toNode = call.getResult(0) and
          fromState = "" and
          toState = "ZipOpenReader"
        )
      }

      override predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
        none()
      }
    }
  }

  /**
   * Provides Decompression additional taint steps for `github.com/klauspost/compress/zip` package
   */
  module KlauspostZip {
    class TheAdditionalTaintStep extends AdditionalTaintStep {
      TheAdditionalTaintStep() { this = "AdditionalTaintStep" }

      override predicate isAdditionalFlowStep(
        DataFlow::Node fromNode, FlowState fromState, DataFlow::Node toNode, FlowState toState
      ) {
        exists(Function f, DataFlow::CallNode call |
          f.hasQualifiedName("github.com/klauspost/compress/zip", ["NewReader", "OpenReader"]) and
          call = f.getACall()
        |
          fromNode = call.getArgument(0) and
          toNode = call.getResult(0) and
          fromState = "" and
          toState = "ZipKlauspost"
        )
      }

      override predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
        exists(DataFlow::FieldReadNode fi |
          fi.getType().hasQualifiedName("github.com/klauspost/compress/zip", "Reader")
        |
          fromNode = fi.getBase() and
          toNode = fi
        )
        or
        exists(Method f, DataFlow::CallNode call |
          f.hasQualifiedName("github.com/klauspost/compress/zip", "File", ["Open", "OpenRaw"]) and
          call = f.getACall()
        |
          fromNode = call.getReceiver() and
          toNode = call
        )
      }
    }
  }

  /**
   * Provides decompression bomb sinks and additional flow steps for `github.com/ulikunitz/xz` package
   */
  module UlikunitzXz {
    class TheSink extends Sink {
      TheSink() {
        exists(Method f | f.hasQualifiedName("github.com/ulikunitz/xz", "Reader", "Read") |
          this = f.getACall().getReceiver()
        )
      }
    }

    class TheAdditionalTaintStep extends AdditionalTaintStep {
      TheAdditionalTaintStep() { this = "AdditionalTaintStep" }

      override predicate isAdditionalFlowStep(
        DataFlow::Node fromNode, FlowState fromState, DataFlow::Node toNode, FlowState toState
      ) {
        exists(Function f, DataFlow::CallNode call |
          f.hasQualifiedName("github.com/ulikunitz/xz", "NewReader") and call = f.getACall()
        |
          fromNode = call.getArgument(0) and
          toNode = call.getResult(0) and
          fromState = "" and
          toState = "XzNewReader"
        )
      }

      override predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
        none()
      }
    }
  }

  /**
   * Provides decompression bomb sinks and additional flow steps for `compress/gzip` package
   */
  module CompressGzip {
    class TheSink extends Sink {
      TheSink() {
        exists(Method f | f.hasQualifiedName("compress/gzip", "Reader", "Read") |
          this = f.getACall().getReceiver()
        )
      }
    }

    class TheAdditionalTaintStep extends AdditionalTaintStep {
      TheAdditionalTaintStep() { this = "AdditionalTaintStep" }

      override predicate isAdditionalFlowStep(
        DataFlow::Node fromNode, FlowState fromState, DataFlow::Node toNode, FlowState toState
      ) {
        exists(Function f, DataFlow::CallNode call |
          f.hasQualifiedName("compress/gzip", "NewReader") and
          call = f.getACall()
        |
          fromNode = call.getArgument(0) and
          toNode = call.getResult(0) and
          fromState = "" and
          toState = "GzipNewReader"
        )
      }

      override predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
        none()
      }
    }
  }

  /**
   * Provides decompression bomb sinks and additional flow steps for `github.com/klauspost/compress/gzip` package
   */
  module KlauspostGzipAndPgzip {
    class TheSink extends Sink {
      TheSink() {
        exists(Method f |
          f.hasQualifiedName(["github.com/klauspost/compress/gzip", "github.com/klauspost/pgzip"],
            "Reader", "Read")
        |
          this = f.getACall().getReceiver()
        )
        or
        exists(Method f |
          f.hasQualifiedName(["github.com/klauspost/compress/gzip", "github.com/klauspost/pgzip"],
            "Reader", "WriteTo")
        |
          this = f.getACall().getReceiver()
        )
      }
    }

    class TheAdditionalTaintStep extends AdditionalTaintStep {
      TheAdditionalTaintStep() { this = "AdditionalTaintStep" }

      override predicate isAdditionalFlowStep(
        DataFlow::Node fromNode, FlowState fromState, DataFlow::Node toNode, FlowState toState
      ) {
        exists(Function f, DataFlow::CallNode call |
          f.hasQualifiedName("github.com/klauspost/pgzip", "NewReader") and
          call = f.getACall() and
          fromNode = call.getArgument(0) and
          toNode = call.getResult(0) and
          fromState = "" and
          toState = "PgzipNewReader"
          or
          f.hasQualifiedName("github.com/klauspost/compress/gzip", "NewReader") and
          call = f.getACall() and
          fromNode = call.getArgument(0) and
          toNode = call.getResult(0) and
          fromState = "" and
          toState = "GzipNewReader"
        )
      }

      override predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
        none()
      }
    }
  }

  /**
   * Provides decompression bomb sinks and additional flow steps for `compress/bzip2` package
   */
  module CompressBzip2 {
    class TheSink extends Sink {
      TheSink() {
        exists(Method f | f.hasQualifiedName("compress/bzip2", "reader", "Read") |
          this = f.getACall().getReceiver()
        )
      }
    }

    class TheAdditionalTaintStep extends AdditionalTaintStep {
      TheAdditionalTaintStep() { this = "AdditionalTaintStep" }

      override predicate isAdditionalFlowStep(
        DataFlow::Node fromNode, FlowState fromState, DataFlow::Node toNode, FlowState toState
      ) {
        exists(Function f, DataFlow::CallNode call |
          f.hasQualifiedName("compress/bzip2", "NewReader") and
          call = f.getACall()
        |
          fromNode = call.getArgument(0) and
          toNode = call.getResult(0) and
          fromState = "" and
          toState = "Bzip2NewReader"
        )
      }

      override predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
        none()
      }
    }
  }

  /**
   * Provides decompression bomb sinks and additional flow steps for `github.com/dsnet/compress/bzip2` package
   */
  module DsnetBzip2 {
    class TheSink extends Sink {
      TheSink() {
        exists(Method f | f.hasQualifiedName("github.com/dsnet/compress/bzip2", "Reader", "Read") |
          this = f.getACall().getReceiver()
        )
      }
    }

    class TheAdditionalTaintStep extends AdditionalTaintStep {
      TheAdditionalTaintStep() { this = "AdditionalTaintStep" }

      override predicate isAdditionalFlowStep(
        DataFlow::Node fromNode, FlowState fromState, DataFlow::Node toNode, FlowState toState
      ) {
        exists(Function f, DataFlow::CallNode call |
          f.hasQualifiedName("github.com/dsnet/compress/bzip2", "NewReader") and
          call = f.getACall()
        |
          fromNode = call.getArgument(0) and
          toNode = call.getResult(0) and
          fromState = "" and
          toState = "Bzip2NewReader"
        )
      }

      override predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
        none()
      }
    }
  }

  /**
   * Provides decompression bomb sinks and additional flow steps for `github.com/dsnet/compress/flate` package
   */
  module DsnetFlate {
    class TheSink extends Sink {
      TheSink() {
        exists(Method f | f.hasQualifiedName("github.com/dsnet/compress/flate", "Reader", "Read") |
          this = f.getACall().getReceiver()
        )
      }
    }

    class TheAdditionalTaintStep extends AdditionalTaintStep {
      TheAdditionalTaintStep() { this = "AdditionalTaintStep" }

      override predicate isAdditionalFlowStep(
        DataFlow::Node fromNode, FlowState fromState, DataFlow::Node toNode, FlowState toState
      ) {
        exists(Function f, DataFlow::CallNode call |
          f.hasQualifiedName("github.com/dsnet/compress/flate", "NewReader") and
          call = f.getACall()
        |
          fromNode = call.getArgument(0) and
          toNode = call.getResult(0) and
          fromState = "" and
          toState = "FlateNewReader"
        )
      }

      override predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
        none()
      }
    }
  }

  /**
   * Provides decompression bomb sinks and additional flow steps for `compress/flate` package
   */
  module CompressFlate {
    class TheSink extends Sink {
      TheSink() {
        exists(Method f | f.hasQualifiedName("compress/flate", "decompressor", "Read") |
          this = f.getACall().getReceiver()
        )
      }
    }

    class TheAdditionalTaintStep extends AdditionalTaintStep {
      TheAdditionalTaintStep() { this = "AdditionalTaintStep" }

      override predicate isAdditionalFlowStep(
        DataFlow::Node fromNode, FlowState fromState, DataFlow::Node toNode, FlowState toState
      ) {
        exists(Function f, DataFlow::CallNode call |
          f.hasQualifiedName("compress/flate", ["NewReaderDict", "NewReader"]) and
          call = f.getACall()
        |
          fromNode = call.getArgument(0) and
          toNode = call.getResult(0) and
          fromState = "" and
          toState = "FlateNewReader"
        )
      }

      override predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
        none()
      }
    }
  }

  /**
   * Provides decompression bomb sinks and additional flow steps for `github.com/klauspost/compress/flate` package
   */
  module KlauspostFlate {
    class TheSink extends Sink {
      TheSink() {
        exists(Method f |
          f.hasQualifiedName("github.com/klauspost/compress/flate", "decompressor", "Read")
        |
          this = f.getACall().getReceiver()
        )
      }
    }

    class TheAdditionalTaintStep extends AdditionalTaintStep {
      TheAdditionalTaintStep() { this = "AdditionalTaintStep" }

      override predicate isAdditionalFlowStep(
        DataFlow::Node fromNode, FlowState fromState, DataFlow::Node toNode, FlowState toState
      ) {
        exists(Function f, DataFlow::CallNode call |
          f.hasQualifiedName("github.com/klauspost/compress/flate", ["NewReaderDict", "NewReader"]) and
          call = f.getACall()
        |
          fromNode = call.getArgument(0) and
          toNode = call.getResult(0) and
          fromState = "" and
          toState = "FlateNewReader"
        )
      }

      override predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
        none()
      }
    }
  }

  /**
   * Provides decompression bomb sinks and additional flow steps for `github.com/klauspost/compress/zlib` package
   */
  module KlauspostZlib {
    class TheSink extends Sink {
      TheSink() {
        exists(Method f |
          f.hasQualifiedName("github.com/klauspost/compress/zlib", "reader", "Read")
        |
          this = f.getACall().getReceiver()
        )
      }
    }

    class TheAdditionalTaintStep extends AdditionalTaintStep {
      TheAdditionalTaintStep() { this = "AdditionalTaintStep" }

      override predicate isAdditionalFlowStep(
        DataFlow::Node fromNode, FlowState fromState, DataFlow::Node toNode, FlowState toState
      ) {
        exists(Function f, DataFlow::CallNode call |
          f.hasQualifiedName("github.com/klauspost/compress/zlib", "NewReader") and
          call = f.getACall()
        |
          fromNode = call.getArgument(0) and
          toNode = call.getResult(0) and
          fromState = "" and
          toState = "ZlibNewReader"
        )
      }

      override predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
        none()
      }
    }
  }

  /**
   * Provides decompression bomb sinks and additional flow steps for `compress/zlib` package
   */
  module CompressZlib {
    class TheSink extends Sink {
      TheSink() {
        exists(Method f | f.hasQualifiedName("compress/zlib", "reader", "Read") |
          this = f.getACall().getReceiver()
        )
      }
    }

    class TheAdditionalTaintStep extends AdditionalTaintStep {
      TheAdditionalTaintStep() { this = "AdditionalTaintStep" }

      override predicate isAdditionalFlowStep(
        DataFlow::Node fromNode, FlowState fromState, DataFlow::Node toNode, FlowState toState
      ) {
        exists(Function f, DataFlow::CallNode call |
          f.hasQualifiedName("compress/zlib", "NewReader") and
          call = f.getACall()
        |
          fromNode = call.getArgument(0) and
          toNode = call.getResult(0) and
          fromState = "" and
          toState = "ZlibNewReader"
        )
      }

      override predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
        none()
      }
    }
  }

  /**
   * Provides decompression bomb sinks and additional flow steps for `github.com/golang/snappy` package
   */
  module GolangSnappy {
    class TheSink extends Sink {
      TheSink() {
        exists(Method f |
          f.hasQualifiedName("github.com/golang/snappy", "Reader", ["Read", "ReadByte"])
        |
          this = f.getACall().getReceiver()
        )
      }
    }

    class TheAdditionalTaintStep extends AdditionalTaintStep {
      TheAdditionalTaintStep() { this = "AdditionalTaintStep" }

      override predicate isAdditionalFlowStep(
        DataFlow::Node fromNode, FlowState fromState, DataFlow::Node toNode, FlowState toState
      ) {
        exists(Function f, DataFlow::CallNode call |
          f.hasQualifiedName("github.com/golang/snappy", "NewReader") and
          call = f.getACall()
        |
          fromNode = call.getArgument(0) and
          toNode = call.getResult(0) and
          fromState = "" and
          toState = "SnappyNewReader"
        )
      }

      override predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
        none()
      }
    }
  }

  /**
   * Provides decompression bombs sinks and additional flow steps for `github.com/klauspost/compress/snappy` package
   */
  module KlauspostSnappy {
    class TheAdditionalTaintStep extends AdditionalTaintStep {
      TheAdditionalTaintStep() { this = "AdditionalTaintStep" }

      override predicate isAdditionalFlowStep(
        DataFlow::Node fromNode, FlowState fromState, DataFlow::Node toNode, FlowState toState
      ) {
        exists(Function f, DataFlow::CallNode call |
          f.hasQualifiedName("github.com/klauspost/compress/snappy", "NewReader") and
          call = f.getACall()
        |
          fromNode = call.getArgument(0) and
          toNode = call.getResult(0) and
          fromState = "" and
          toState = "SnappyNewReader"
        )
      }

      override predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
        none()
      }
    }
  }

  /**
   * Provides decompression bomb sinks and additional flow steps for `github.com/klauspost/compress/s2` package
   */
  module KlauspostS2 {
    class TheSink extends Sink {
      TheSink() {
        exists(Method m |
          m.hasQualifiedName("github.com/klauspost/compress/s2", "Reader",
            ["DecodeConcurrent", "ReadByte", "Read"])
        |
          this = m.getACall().getReceiver()
        )
      }
    }

    class TheAdditionalTaintStep extends AdditionalTaintStep {
      TheAdditionalTaintStep() { this = "AdditionalTaintStep" }

      override predicate isAdditionalFlowStep(
        DataFlow::Node fromNode, FlowState fromState, DataFlow::Node toNode, FlowState toState
      ) {
        exists(Function f, DataFlow::CallNode call |
          f.hasQualifiedName("github.com/klauspost/compress/s2", "NewReader") and
          call = f.getACall()
        |
          fromNode = call.getArgument(0) and
          toNode = call.getResult(0) and
          fromState = "" and
          toState = "S2NewReader"
        )
      }

      override predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
        none()
      }
    }
  }

  /**
   * Provides decompression bomb sinks for packages that use some standard IO interfaces/methods for reading decompressed data
   */
  module GeneralReadIoSink {
    class TheSink extends Sink {
      TheSink() {
        exists(Function f, DataFlow::CallNode cn |
          f.hasQualifiedName("io", "CopyN") and cn = f.getACall()
        |
          this = cn.getArgument(1) and
          // and the return value doesn't flow into a comparison  (<, >, <=, >=).
          not localStep*(cn.getResult(0), any(DataFlow::RelationalComparisonNode rcn).getAnOperand())
        )
        or
        exists(Function f | f.hasQualifiedName("io", ["Copy", "CopyBuffer"]) |
          this = f.getACall().getArgument(1)
        )
        or
        exists(Function f |
          f.hasQualifiedName("io", ["Pipe", "ReadAll", "ReadAtLeast", "ReadFull"])
        |
          this = f.getACall().getArgument(0)
        )
        or
        exists(Method f |
          f.hasQualifiedName("bufio", "Reader",
            ["Read", "ReadBytes", "ReadByte", "ReadLine", "ReadRune", "ReadSlice", "ReadString"])
        |
          this = f.getACall().getReceiver()
        )
        or
        exists(Method f | f.hasQualifiedName("bufio", "Scanner", ["Text", "Bytes"]) |
          this = f.getACall().getReceiver()
        )
        or
        exists(Function f | f.hasQualifiedName("io/ioutil", "ReadAll") |
          this = f.getACall().getArgument(0)
        )
      }
    }

    /**
     * Holds if the value of `pred` can flow into `succ` in one step through an
     * arithmetic operation (other than remainder).
     *
     * Note: this predicate is copied from AllocationSizeOverflow. When this query
     * is promoted it should be put in a shared location.
     */
    predicate additionalStep(DataFlow::Node pred, DataFlow::Node succ) {
      succ.asExpr().(ArithmeticExpr).getAnOperand() = pred.asExpr() and
      not succ.asExpr() instanceof RemExpr
    }

    /**
     * Holds if the value of `pred` can flow into `succ` in one step, either by a standard taint step
     * or by an additional step.
     *
     * Note: this predicate is copied from AllocationSizeOverflow. When this query
     * is promoted it should be put in a shared location.
     */
    predicate localStep(DataFlow::Node pred, DataFlow::Node succ) {
      TaintTracking::localTaintStep(pred, succ) or
      additionalStep(pred, succ)
    }
  }
}
