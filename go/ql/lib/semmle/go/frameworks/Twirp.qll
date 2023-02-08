/** Provides models of commonly used functions and types in the twirp packages. */

import go
private import semmle.go.security.RequestForgeryCustomizations

/** Provides models of commonly used functions and types in the twirp packages. */
module Twirp {
  /**
   * A *.pb.go file generated by Twirp.
   *
   * This file contains all the types representing protobuf messages and should have a companion *.twirp.go file.
   */
  class ProtobufGeneratedFile extends File {
    ProtobufGeneratedFile() {
      exists(string prefix, File f |
        prefix = this.getBaseName().regexpCapture("^(.*)\\.pb\\.go$", 1) and
        this.getParentContainer() = f.getParentContainer() and
        f.getBaseName() = prefix + ".twirp.go"
      )
    }
  }

  /**
   * A *.twirp.go file generated by Twirp.
   *
   * This file contains all the types representing protobuf services and should have a companion *.pb.go file.
   */
  class ServicesGeneratedFile extends File {
    ServicesGeneratedFile() {
      exists(string prefix, File f |
        prefix = this.getBaseName().regexpCapture("^(.*)\\.twirp\\.go$", 1) and
        this.getParentContainer() = f.getParentContainer() and
        f.getBaseName() = prefix + ".pb.go"
      )
    }
  }

  /**
   * A type representing a protobuf message.
   */
  class ProtobufMessageType extends Type {
    ProtobufMessageType() {
      exists(TypeEntity te |
        te.getType() = this and
        te.getDeclaration().getLocation().getFile() instanceof ProtobufGeneratedFile
      )
    }
  }

  /**
   * An interface type representing a Twirp service.
   */
  class ServiceInterfaceType extends InterfaceType {
    NamedType namedType;

    ServiceInterfaceType() {
      exists(TypeEntity te |
        te.getType() = namedType and
        namedType.getUnderlyingType() = this and
        te.getDeclaration().getLocation().getFile() instanceof ServicesGeneratedFile
      )
    }

    /**
     * Gets the name of the interface.
     */
    override string getName() { result = namedType.getName() }

    /**
     * Gets the named type on top of this interface type.
     */
    NamedType getNamedType() { result = namedType }
  }

  /**
   * A Twirp client.
   */
  class ServiceClientType extends NamedType {
    ServiceClientType() {
      exists(ServiceInterfaceType i, PointerType p, TypeEntity te |
        p.implements(i) and
        this = p.getBaseType() and
        this.getName().toLowerCase() = i.getName().toLowerCase() + ["protobuf", "json"] + "client" and
        te.getType() = this and
        te.getDeclaration().getLocation().getFile() instanceof ServicesGeneratedFile
      )
    }
  }

  /**
   * A Twirp server.
   */
  class ServiceServerType extends NamedType {
    ServiceServerType() {
      exists(ServiceInterfaceType i, TypeEntity te |
        this.implements(i) and
        this.getName().toLowerCase() = i.getName().toLowerCase() + "server" and
        te.getType() = this and
        te.getDeclaration().getLocation().getFile() instanceof ServicesGeneratedFile
      )
    }
  }

  /**
   * A Twirp function to construct a Client.
   */
  class ClientConstructor extends Function {
    ClientConstructor() {
      exists(ServiceClientType c |
        this.getName().toLowerCase() = "new" + c.getName().toLowerCase() and
        this.getParameterType(0) instanceof StringType and
        this.getParameterType(1).getName() = "HTTPClient" and
        this.getDeclaration().getLocation().getFile() instanceof ServicesGeneratedFile
      )
    }
  }

  /**
   * A Twirp function to construct a Server.
   *
   * Its first argument should be an implementation of the service interface.
   */
  class ServerConstructor extends Function {
    ServerConstructor() {
      exists(ServiceServerType c, ServiceInterfaceType i |
        this.getName().toLowerCase() = "new" + c.getName().toLowerCase() and
        this.getParameterType(0) = i.getNamedType() and
        this.getDeclaration().getLocation().getFile() instanceof ServicesGeneratedFile
      )
    }
  }

  /**
   * An SSRF sink for the Client constructor.
   */
  class ClientRequestUrlAsSink extends RequestForgery::Sink {
    ClientRequestUrlAsSink() {
      exists(DataFlow::CallNode call |
        call.getArgument(0) = this and
        call.getTarget() instanceof ClientConstructor
      )
    }

    override DataFlow::Node getARequest() { result = this }

    override string getKind() { result = "URL" }
  }

  /**
   * A service handler.
   */
  class ServiceHandler extends Method {
    ServiceHandler() {
      exists(DataFlow::CallNode call, Type handlerType, ServiceInterfaceType i |
        call.getTarget() instanceof ServerConstructor and
        call.getArgument(0).getType() = handlerType and
        this = handlerType.getMethod(_) and
        this.implements(i.getNamedType().getMethod(_))
      )
    }
  }

  /**
   * A request coming to the service handler.
   */
  class Request extends UntrustedFlowSource::Range instanceof DataFlow::ParameterNode {
    Request() {
      exists(Callable c, ServiceHandler handler | c.asFunction() = handler |
        this.isParameterOf(c, 1) and
        handler.getParameterType(0).hasQualifiedName("context", "Context") and
        this.getType().(PointerType).getBaseType() instanceof ProtobufMessageType
      )
    }
  }
}
