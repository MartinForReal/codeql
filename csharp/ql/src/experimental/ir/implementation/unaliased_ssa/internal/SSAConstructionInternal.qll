import experimental.ir.implementation.raw.IR as OldIR
import experimental.ir.implementation.raw.internal.reachability.ReachableBlock as Reachability
import experimental.ir.implementation.raw.internal.reachability.Dominance as Dominance
import experimental.ir.implementation.unaliased_ssa.IR as NewIR
import experimental.ir.implementation.raw.internal.IRConstruction as RawStage
import experimental.ir.implementation.internal.TInstruction::UnaliasedSsaInstructions as SSAInstructions
import experimental.ir.internal.IRCSharpLanguage as Language
import SimpleSSA as Alias
import experimental.ir.implementation.internal.TOperand::UnaliasedSsaOperands as SSAOperands

predicate removedInstruction(Reachability::ReachableInstruction instr) { none() }

class OldBlock = Reachability::ReachableBlock;

class OldInstruction = Reachability::ReachableInstruction;