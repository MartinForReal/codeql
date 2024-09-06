// generated by codegen
/**
 * This module provides the generated definition of `OffsetOf`.
 * INTERNAL: Do not import directly.
 */

private import codeql.rust.generated.Synth
private import codeql.rust.generated.Raw
import codeql.rust.elements.Expr
import codeql.rust.elements.TypeRef

/**
 * INTERNAL: This module contains the fully generated definition of `OffsetOf` and should not
 * be referenced directly.
 */
module Generated {
  /**
   * INTERNAL: Do not reference the `Generated::OffsetOf` class directly.
   * Use the subclass `OffsetOf`, where the following predicates are available.
   */
  class OffsetOf extends Synth::TOffsetOf, Expr {
    override string getAPrimaryQlClass() { result = "OffsetOf" }

    /**
     * Gets the container of this offset of.
     */
    TypeRef getContainer() {
      result =
        Synth::convertTypeRefFromRaw(Synth::convertOffsetOfToRaw(this)
              .(Raw::OffsetOf)
              .getContainer())
    }

    /**
     * Gets the `index`th field of this offset of (0-based).
     */
    string getField(int index) {
      result = Synth::convertOffsetOfToRaw(this).(Raw::OffsetOf).getField(index)
    }

    /**
     * Gets any of the fields of this offset of.
     */
    final string getAField() { result = this.getField(_) }

    /**
     * Gets the number of fields of this offset of.
     */
    final int getNumberOfFields() { result = count(int i | exists(this.getField(i))) }
  }
}
