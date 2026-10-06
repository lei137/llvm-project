# REQUIRES: ppc
## Check that --optimize-bb-jumps removes unconditional 'b' instructions that
## branch to the immediately following basic-block section on PPC64, and
## inverts a preceding conditional branch when it is the 'b' that falls through.

# RUN: llvm-mc -filetype=obj -triple=powerpc64le %s -o %t.o
# RUN: ld.lld --optimize-bb-jumps %t.o -o %t.out
# RUN: llvm-objdump -d --no-show-raw-insn %t.out | FileCheck %s

## foo: unconditional 'b' to immediately following section is deleted.
# CHECK:      <foo>:
# CHECK-NEXT:  nop
# CHECK-NOT:   b {{.*}} <a.BB.foo>

## a.BB.foo ends with: beq r.BB.foo ; b end.BB.foo
## 'beq r.BB.foo' falls through to r.BB.foo (the next section), so it is
## inverted to 'bf 2' (bne) targeting end.BB.foo, and 'b end.BB.foo' is deleted.
# CHECK:      <a.BB.foo>:
# CHECK-NEXT:  nop
# CHECK-NEXT:  bf 2, {{.*}} <end.BB.foo>
# CHECK-NOT:   b {{.*}} <end.BB.foo>

## r.BB.foo: unconditional 'b' to immediately following section is deleted.
# CHECK:      <r.BB.foo>:
# CHECK-NEXT:  nop
# CHECK-NOT:   b {{.*}} <end.BB.foo>

# CHECK:      <end.BB.foo>:
# CHECK-NEXT:  blr

.section .text,"ax",@progbits
.globl foo
.type  foo,@function
foo:
  nop
  b a.BB.foo

## a.BB.foo: beq targets r.BB.foo (the next section = fall-through).
## The 'b end.BB.foo' does NOT fall through.
## So beq is inverted to bne end.BB.foo, and 'b' is deleted.
.section .text,"ax",@progbits,unique,1
a.BB.foo:
  nop
  beq r.BB.foo
  b end.BB.foo

.section .text,"ax",@progbits,unique,2
r.BB.foo:
  nop
  b end.BB.foo

.section .text,"ax",@progbits,unique,3
end.BB.foo:
  blr
