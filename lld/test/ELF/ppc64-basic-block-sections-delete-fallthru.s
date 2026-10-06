# REQUIRES: ppc
## Check that --optimize-bb-jumps removes unconditional 'b' instructions that
## branch to the immediately following basic-block section on PPC64.

# RUN: llvm-mc -filetype=obj -triple=powerpc64le %s -o %t.o
# RUN: ld.lld --optimize-bb-jumps %t.o -o %t.out
# RUN: llvm-objdump -d --no-show-raw-insn %t.out | FileCheck %s

## foo has three consecutive BB sections.  The 'b' at the end of each
## BB section targets the immediately following section and should be deleted.

# CHECK:      <foo>:
# CHECK-NEXT:  nop
# CHECK-NOT:   b

# CHECK:      <a.BB.foo>:
# CHECK-NEXT:  nop
# CHECK-NOT:   b

# CHECK:      <r.BB.foo>:
# CHECK-NEXT:  blr

.section .text,"ax",@progbits
.globl foo
.type  foo,@function
foo:
  nop
  b a.BB.foo

.section .text,"ax",@progbits,unique,1
a.BB.foo:
  nop
  b r.BB.foo

.section .text,"ax",@progbits,unique,2
r.BB.foo:
  blr
