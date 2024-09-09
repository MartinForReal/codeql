// generated by codegen
/**
 * This module provides the generated definition of `Yeet`.
 * INTERNAL: Do not import directly.
 */

private import codeql.rust.generated.Synth
private import codeql.rust.generated.Raw
import codeql.rust.elements.Expr

/**
 * INTERNAL: This module contains the fully generated definition of `Yeet` and should not
 * be referenced directly.
 */
module Generated {
  /**
   * INTERNAL: Do not reference the `Generated::Yeet` class directly.
   * Use the subclass `Yeet`, where the following predicates are available.
   */
  class Yeet extends Synth::TYeet, Expr {
    override string getAPrimaryQlClass() { result = "Yeet" }

    /**
     * Gets the expression of this yeet, if it exists.
     */
    Expr getExpr() {
      result = Synth::convertExprFromRaw(Synth::convertYeetToRaw(this).(Raw::Yeet).getExpr())
    }

    /**
     * Holds if `getExpr()` exists.
     */
    final predicate hasExpr() { exists(this.getExpr()) }
  }
}
