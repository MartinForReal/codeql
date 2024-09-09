// generated by codegen
/**
 * This module provides the generated definition of `Box`.
 * INTERNAL: Do not import directly.
 */

private import codeql.rust.generated.Synth
private import codeql.rust.generated.Raw
import codeql.rust.elements.Expr

/**
 * INTERNAL: This module contains the fully generated definition of `Box` and should not
 * be referenced directly.
 */
module Generated {
  /**
   * INTERNAL: Do not reference the `Generated::Box` class directly.
   * Use the subclass `Box`, where the following predicates are available.
   */
  class Box extends Synth::TBox, Expr {
    override string getAPrimaryQlClass() { result = "Box" }

    /**
     * Gets the expression of this box.
     */
    Expr getExpr() {
      result = Synth::convertExprFromRaw(Synth::convertBoxToRaw(this).(Raw::Box).getExpr())
    }
  }
}
