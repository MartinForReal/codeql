/**
 * @name InsecureRmiJmxAuthenticationEnvironment
 * @description This query detects if a JMX/RMI server is created with a potentially dangerous environment, which could lead to code execution through insecure deserialization.
 * @kind path-problem
 * @problem.severity error
 * @tags security
 *       external/cwe/cwe-665
 * @precision high
 * @id java/insecure-rmi-jmx-server-initalisation
 */

import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.DataFlow2
import semmle.code.java.Maps
import DataFlow::PathGraph
import semmle.code.java.dataflow.NullGuards
import semmle.code.java.dataflow.Nullness

/** predicate which detects vulnerable Constructors */
predicate isRmiOrJmxServerCreateConstructor(Constructor constructor) {
  constructor.getName() = "RMIConnectorServer" and
  constructor
      .getDeclaringType()
      .hasQualifiedName("javax.management.remote.rmi", "RMIConnectorServer")
}

/** Predicate which detects vulnerable server creations via methods */
predicate isRmiOrJmxServerCreateMethod(Method method) {
  method.getName() = "newJMXConnectorServer" and
  method.getDeclaringType().hasQualifiedName("javax.management.remote", "JMXConnectorServerFactory")
}

/**
 * Models flow from `new HashMap<>()` to a
 * `map.put("jmx.remote.rmi.server.credential.types", value)` call.
 */
class MapToPutCredentialstypeConfiguration extends DataFlow2::Configuration {
  MapToPutCredentialstypeConfiguration() { this = "MapToPutCredentialstypeConfiguration" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr().(ClassInstanceExpr).getConstructedType() instanceof MapType
  }

  override predicate isSink(DataFlow2::Node sink) { putsCredentialtypesKey(sink.asExpr()) }

  /**
   * Holds if a `put` call on `qualifier` puts a key match
   * into the map.
   */
  private predicate putsCredentialtypesKey(Expr qualifier) {
    exists(MapPutCall put |
      put.getKey().(CompileTimeConstantExpr).getStringValue() =
        "jmx.remote.rmi.server.credential.types" or
      put.getKey().(CompileTimeConstantExpr).getStringValue() =
        "jmx.remote.rmi.server.credentials.filter.pattern" or
      put.getKey().toString() = "RMIConnectorServer.CREDENTIAL_TYPES" or // This can probably be solved more nicely
      put.getKey().toString() = "RMIConnectorServer.CREDENTIALS_FILTER_PATTERN" // This can probably be solved more nicely
    |
      put.getQualifier() = qualifier and
      put.getMethod().(MapMethod).getReceiverKeyType().getName() = "String" and
      put.getMethod().(MapMethod).getReceiverValueType().getName() = "Object"
    )
  }
}

/** Models flow from `new HashMap<>()` to the argument of a `TestConstructor` call. */
class MapToRmiServerInitConfiguration extends DataFlow::Configuration {
  MapToRmiServerInitConfiguration() { this = "MapToRmiServerInitConfiguration" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr().(ClassInstanceExpr).getConstructedType() instanceof MapType
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(ConstructorCall ccall |
      sink.asExpr() = ccall.getArgument(1) and
      isRmiOrJmxServerCreateConstructor(ccall.getConstructor())
    )
    or
    exists(MethodAccess ma |
      sink.asExpr() = ma.getArgument(1) and
      isRmiOrJmxServerCreateMethod(ma.getMethod())
    )
  }
}

/** Models if any JMX/RMI server are initialized with a null environment */
class FlowServerInitializedWithNullEnv extends DataFlow::Configuration {
  FlowServerInitializedWithNullEnv() { this = "FlowServerInitializedWithNullEnv" }

  override predicate isSource(DataFlow::Node source) { any() }

  override predicate isSink(DataFlow::Node sink) {
    exists(ConstructorCall ccall |
      sink.asExpr() = ccall and
      isRmiOrJmxServerCreateConstructor(ccall.getConstructor()) and
      ccall.getArgument(1) = alwaysNullExpr()
    )
    or
    exists(MethodAccess ma |
      sink.asExpr() = ma and
      isRmiOrJmxServerCreateMethod(ma.getMethod()) and
      ma.getArgument(1) = alwaysNullExpr()
    )
  }
}

/** Returns true if within the passed PathNode a "jmx.remote.rmi.server.credential.types" is set. */
predicate mapFlowContainsCredentialtype(DataFlow::PathNode source) {
  exists(MapToPutCredentialstypeConfiguration conf | conf.hasFlow(source.getNode(), _))
}

/** Returns result depending if the vulnerability is present due to a) a null environment b) an insecurely set environment map */
bindingset[source]
string getRmiResult(DataFlow::PathNode source) {
  // We got a Map so we have a source and a sink node
  if source.getNode().getType() instanceof MapType
  then
    result =
      "RMI/JMX server initialized with insecure environment $@. The $@ never restricts accepted client objects to 'java.lang.String'. This exposes to deserialization attacks against the RMI authentication method."
  else
    // The environment is not a map so we most likely have a "null" environment and therefore only a sink
    result =
      "RMI/JMX server initialized with 'null' environment $@. Missing type restriction in RMI authentication method exposes the application to deserialization attacks."
}

/** Predicate returns true for any map flow paths with NO jmx.remote.rmi.server.credential.types set */
predicate hasVulnerableMapFlow(DataFlow::PathNode source, DataFlow::PathNode sink) {
  exists(MapToRmiServerInitConfiguration dataflow |
    dataflow.hasFlowPath(source, sink) and
    not mapFlowContainsCredentialtype(source)
  )
}

from
  DataFlow::PathNode source, DataFlow::PathNode sink,
  FlowServerInitializedWithNullEnv initNullDataflow
where
  // Check if server is created with null env
  initNullDataflow.hasFlowPath(source, sink)
  or
  // The map created by `new HashMap<String, Object>()` has to a) flow to the sink and b) there must not exist a (different) sink that would put `"jmx.remote.rmi.server.credential.types"` into `source`. */
  hasVulnerableMapFlow(source, sink)
select sink.getNode(), source, sink, getRmiResult(source), sink.getNode(), "here", source.getNode(),
  "source environment 'Map'"
