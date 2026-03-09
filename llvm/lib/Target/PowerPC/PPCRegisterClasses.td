//===-- PPCRegisterClasses.td - PPC Register Class Definitions -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines base classes for PowerPC register classes to reduce
// repetition and make it easier to define new register classes.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Base Register Class Definitions
//===----------------------------------------------------------------------===//

// Base class for all PPC register classes - sets namespace to "PPC"
class PPCRegisterClass<list<ValueType> regTypes, int alignment, dag regList>
  : RegisterClass<"PPC", regTypes, alignment, regList>;

//===----------------------------------------------------------------------===//
// Classes for Generating RegisterOperand for Existing RegisterClass
//===----------------------------------------------------------------------===//

// Base class that creates a RegisterOperand for an already-defined
// RegisterClass, assuming the AsmOperandClass already exists with the
// standard naming convention
// (PPCReg<regClassName>AsmOperand).
//
// Usage: def spe4rc : PPCRegOperandOnly<"GPRC">;
//   Creates: spe4rc RegisterOperand wrapping GPRC, using PPCRegGPRCAsmOperand
class PPCRegOperandOnly<string regClassName>
  : RegisterOperand<!cast<RegisterClass>(regClassName)> {
  let ParserMatchClass = !cast<AsmOperandClass>(
    !strconcat("PPCReg", regClassName, "AsmOperand"));
}

// Multiclass that generates both the AsmOperandClass and RegisterOperand for an
// already-defined RegisterClass. This eliminates the repetitive pattern of
// manually defining these for each register class.
//
// Usage examples:
//   defm GPRC : PPCRegOperand<"isRegNumber">;
//     Creates: PPCRegGPRCAsmOperand and gprc (lowercase of GPRC)
//   defm FpRC : PPCRegOperand<"isEvenRegNumber", "fpairrc">;
//     Creates: PPCRegFpRCAsmOperand and fpairrc (custom name)
//
// The NAME in the defm statement should match the RegisterClass name.

multiclass PPCRegOperand<string predicate, string operandName = ""> {
  // Define the AsmOperandClass
  def "PPCReg"#NAME#"AsmOperand" : AsmOperandClass {
    let Name = "Reg"#NAME;
    let PredicateMethod = predicate;
  }
  
  // Define the RegisterOperand
  // Use custom name if provided, otherwise use lowercase of NAME
  def !if(!eq(operandName, ""), !tolower(NAME), operandName)
    : RegisterOperand<!cast<RegisterClass>(NAME)> {
    let ParserMatchClass = !cast<AsmOperandClass>("PPCReg"#NAME#"AsmOperand");
  }
}

//===----------------------------------------------------------------------===//
// Multiclasses that Define RegisterClass + AsmOperandClass + RegisterOperand
//===----------------------------------------------------------------------===//

// Base multiclass that generates RegisterClass, AsmOperandClass, and
// RegisterOperand in a single definition. This is the new recommended way
// to define register classes.
//
// Usage:
//   defm GPRC : PPCRegister<[i32,f32], 32, (add R0, R1, ...), "isRegNumber">;
//
// This creates:
//   - GPRC (RegisterClass)
//   - PPCRegGPRCAsmOperand (AsmOperandClass with Name="RegGPRC")
//   - gprc (RegisterOperand, lowercase of GPRC)
//
// Optional operandName parameter for custom RegisterOperand name:
//   defm FpRC : PPCRegister<[ppcf128], 128, (add ...),
//                           "isEvenRegNumber", "fpairrc">;
multiclass PPCRegister<list<ValueType> regTypes, int alignment, dag regList,
                       string predicate, string operandName = ""> {
  // Define the RegisterClass
  def NAME : PPCRegisterClass<regTypes, alignment, regList>;
  
  // Use PPCRegOperand to generate AsmOperandClass and RegisterOperand
  defm NAME : PPCRegOperand<predicate, operandName>;
}

// Multiclass version of PPCRegister with explicit size parameter
multiclass PPCRegisterWithSize<list<ValueType> regTypes, int alignment,
                               dag regList, string predicate, int size,
                               string operandName = ""> {
  // Define the RegisterClass with explicit size
  def NAME : PPCRegisterClass<regTypes, alignment, regList> {
    let Size = size;
  }
  
  // Use PPCRegOperand to generate AsmOperandClass and RegisterOperand
  defm NAME : PPCRegOperand<predicate, operandName>;
}

// Multiclass version of PPCRegister with allocation priority
multiclass PPCRegisterWithPriority<list<ValueType> regTypes, int alignment,
                                   dag regList, string predicate,
                                   int allocPriority, bit globalPriority,
                                   int size, string operandName = ""> {
  def NAME : PPCRegisterClass<regTypes, alignment, regList> {
    let AllocationPriority = allocPriority;
    let GlobalPriority = globalPriority;
    let Size = size;
  }
  
  defm NAME : PPCRegOperand<predicate, operandName>;
}

// Multiclass for non-allocatable register classes
multiclass PPCNonAllocatableRegister<list<ValueType> regTypes, int alignment,
                                     dag regList, string predicate,
                                     string operandName = ""> {
  def NAME : PPCRegisterClass<regTypes, alignment, regList> {
    let isAllocatable = 0;
  }
  
  defm NAME : PPCRegOperand<predicate, operandName>;
}


// Multiclass for condition register classes with alternative orders
multiclass PPCCRRegister<list<ValueType> regTypes, int alignment, dag regList,
                         dag altOrder, string predicate, int size = 0, string operandName = ""> {
  def NAME : PPCRegisterClass<regTypes, alignment, regList> {
    let AltOrders = [altOrder];
    let AltOrderSelect = [{
      return MF.getSubtarget<PPCSubtarget>().isELFv2ABI() &&
             MF.getInfo<PPCFunctionInfo>()->isNonVolatileCRDisabled();
    }];
    let Size = !if(!ne(size, 0), size, 0);
  }
  
  defm NAME : PPCRegOperand<predicate, operandName>;
}

// Multiclass for paired register classes with alternative orders
multiclass PPCPairedRegister<list<ValueType> regTypes, int alignment, dag regList,
                             dag altOrder, int size, string predicate, string operandName = ""> {
  def NAME : PPCRegisterClass<regTypes, alignment, regList> {
    let AltOrders = [altOrder];
    let AltOrderSelect = [{
      return MF.getSubtarget<PPCSubtarget>().is64BitELFABI();
    }];
    let Size = size;
  }
  
  defm NAME : PPCRegOperand<predicate, operandName>;
}

//===----------------------------------------------------------------------===//
// Variant Register Class Definitions
//===----------------------------------------------------------------------===//

// Register class that is not allocatable
class PPCNonAllocatableRegisterClass<list<ValueType> regTypes, int alignment,
                                     dag regList>
  : PPCRegisterClass<regTypes, alignment, regList> {
  let isAllocatable = 0;
}

// Register class with explicit size
class PPCRegisterClassWithSize<list<ValueType> regTypes, int alignment,
                               dag regList, int size>
  : PPCRegisterClass<regTypes, alignment, regList> {
  let Size = size;
}

// Register class with allocation priority and size
class PPCRegisterClassWithPriority<list<ValueType> regTypes, int alignment,
                                   dag regList, int allocPriority,
                                   bit globalPriority, int size>
  : PPCRegisterClass<regTypes, alignment, regList> {
  let AllocationPriority = allocPriority;
  let GlobalPriority = globalPriority;
  let Size = size;
}

