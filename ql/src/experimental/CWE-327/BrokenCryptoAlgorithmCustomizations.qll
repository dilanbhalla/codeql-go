/**
 * Provides default sources, sinks and sanitizers for reasoning about
 * sensitive information in broken or weak cryptographic algorithms,
 * as well as extension points for adding your own.
 */

import go
private import semmle.go.security.SensitiveActions
private import CryptoLibraries

module BrokenCryptoAlgorithm {
  /**
   * A data flow source for sensitive information in broken or weak cryptographic algorithms.
   */
  abstract class Source extends DataFlow::Node { }

  /**
   * A data flow sink for sensitive information in broken or weak cryptographic algorithms.
   */
  abstract class Sink extends DataFlow::Node { }

  /**
   * A sanitizer for sensitive information in broken or weak cryptographic algorithms.
   */
  abstract class Sanitizer extends DataFlow::Node { }

  /**
   * A sensitive source.
   */
  class SensitiveSource extends Source {
    SensitiveSource() { this.asExpr() instanceof SensitiveExpr }
  }

  /**
   * An expression used by a broken or weak cryptographic algorithm.
   */
  class WeakCryptographicOperationSink extends Sink {
    WeakCryptographicOperationSink() {
      exists(CryptographicOperation application |
        application.getAlgorithm().isWeak() and
        this.asExpr() = application.getInput()
      )
    }
  }

  class Configuration extends TaintTracking::Configuration {
    Configuration() { this = "BrokenCryptoAlgorithm" }

    override predicate isSource(DataFlow::Node source) { source instanceof SensitiveSource }

    override predicate isSink(DataFlow::Node sink) {
      sink instanceof WeakCryptographicOperationSink
    }

    override predicate isSanitizer(DataFlow::Node node) {
      super.isSanitizer(node) or
      node instanceof Sanitizer
    }
  }
}