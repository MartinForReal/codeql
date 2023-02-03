/**
 * For internal use only.
 *
 * A taint-tracking configuration for reasoning about SSRF (server side request forgery) vulnerabilities.
 * Largely copied from java/ql/lib/semmle/code/java/security/RequestForgeryConfig.qll.
 *
 * Only import this directly from .ql files, to avoid the possibility of polluting the Configuration hierarchy
 * accidentally.
 */

import ATMConfig
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.security.RequestForgery

class RequestForgeryAtmConfig extends AtmConfig {
  RequestForgeryAtmConfig() { this = "RequestForgeryAtmConfig" }

  override predicate isKnownSource(DataFlow::Node source) {
    source instanceof RemoteFlowSource and
    // Exclude results of remote HTTP requests: fetching something else based on that result
    // is no worse than following a redirect returned by the remote server, and typically
    // we're requesting a resource via https which we trust to only send us to safe URLs.
    not source.asExpr().(MethodAccess).getCallee() instanceof UrlConnectionGetInputStreamMethod
  }

  override EndpointType getASinkEndpointType() {
    result instanceof RequestForgeryOtherSinkType or
    result instanceof UrlOpenSinkType or
    result instanceof JdbcUrlSinkType
  }

  /*
   * This is largely a copy of the taint tracking configuration for the standard SSRF
   * query, except additional sinks have been added using the sink endpoint filter.
   */

  override predicate isAdditionalTaintStep(DataFlow::Node pred, DataFlow::Node succ) {
    any(RequestForgeryAdditionalTaintStep r).propagatesTaint(pred, succ)
  }

  override predicate isSanitizer(DataFlow::Node node) { node instanceof RequestForgerySanitizer }
}
