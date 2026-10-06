# REQUIRES: ppc
## Test --optimize-bb-jumps on PPC64 for three patterns drawn from real
## basic-block-sections binaries.
##
## Case 1: section ends with an unconditional 'b' to the immediately following
##         section.  The branch is redundant and is deleted.
##
## Case 2: section ends with [bc <nextIS>] [b <far>].  The 'bc' falls through
##         to nextIS, so it is inverted to target <far> and the 'b <far>' is
##         deleted.
##
## Case 3 (dominant pattern in practice): section ends with
##         [bc <trailing_b>] [b <far>] [b <nextIS>]
##         where 'bc' targets the address of the trailing 'b' (= nextIS - 4).
##         After the trailing 'b <nextIS>' is dropped nextIS shifts to that
##         address, making 'bc' a fall-through.  Both trailing branches are
##         removed and 'bc' is inverted to target <far>.

# RUN: llvm-mc -filetype=obj -triple=powerpc64le %s -o %t.o
# RUN: ld.lld --optimize-bb-jumps %t.o -o %t.out
# RUN: llvm-objdump -d --no-show-raw-insn %t.out | FileCheck %s
# RUN: llvm-objdump -d %t.out | FileCheck --check-prefix=RAWCHECK %s

## Case 1: foo ends with 'b a.BB.foo' which targets the next section.
## The branch is deleted and a nop filler takes its place.
# CHECK-LABEL: <foo>:
# CHECK-NEXT:   nop
# CHECK-NOT:    b {{.*}} <a.BB.foo>

# CHECK-LABEL: <a.BB.foo>:
# CHECK-NEXT:   blr

## Case 2: b.BB.foo ends with [beq c.BB.foo] [b far.BB.foo].
## 'beq c.BB.foo' falls through to c.BB.foo (the next section).
## It is inverted to 'bne far.BB.foo' and 'b far.BB.foo' is deleted.
## Note: objdump prints 'beq' as 'bt 2' and 'bne' as 'bf 2' (raw BO/BI encoding).
# CHECK-LABEL: <b.BB.foo>:
# CHECK-NEXT:   nop
# CHECK-NEXT:   bf 2, {{.*}} <far.BB.foo>
# CHECK-NOT:    b {{.*}} <far.BB.foo>

# CHECK-LABEL: <c.BB.foo>:
# CHECK-NEXT:   blr

## Case 3: d.BB.foo ends with [bne <d.BB.foo+0x8>] [b far2.BB.foo] [b e.BB.foo].
## 'bne' targets <d.BB.foo+0x8> = e.BB.foo - 4 = nextIS - 4.
## After the trailing 'b e.BB.foo' is dropped, nextIS shifts to d.BB.foo+0x8.
## Both trailing branches are removed; 'bne' is inverted to 'beq far2.BB.foo'.
## Note: objdump prints 'bne' as 'bf 2' and 'beq' as 'bt 2' (raw BO/BI encoding).
## The raw encoding verifies the displacement is correct (not the stale intra-section value).
## 08 00 82 41 (LE) = bt 2, +8 — the displacement to far2.BB.foo.
# CHECK-LABEL: <d.BB.foo>:
# CHECK-NEXT:   nop
# CHECK-NEXT:   bt 2, {{.*}} <far2.BB.foo>
# CHECK-NOT:    b {{.*}}
# RAWCHECK-LABEL: <d.BB.foo>:
# RAWCHECK-NEXT:  {{.*}} 00 00 60{{.*}}nop
# RAWCHECK-NEXT:  08 00 82 41{{.*}}bt 2, {{.*}} <far2.BB.foo>

# CHECK-LABEL: <e.BB.foo>:
# CHECK-NEXT:   blr

## Case 3 (CTR variant): f.BB.foo ends with [bdnz <f.BB.foo+0x8>] [b far3.BB.foo] [b g.BB.foo].
## 'bdnz' is a CTR branch (BO=16); inverted to 'bdz' by XOR 0x00400000.
## Note: objdump prints 'bdnz' as 'bdnz' and 'bdz' as 'bdz'.
# CHECK-LABEL: <f.BB.foo>:
# CHECK-NEXT:   nop
# CHECK-NEXT:   bdz {{.*}} <far3.BB.foo>
# CHECK-NOT:    b {{.*}}

# CHECK-LABEL: <g.BB.foo>:
# CHECK-NEXT:   blr

## ── Assembly ──────────────────────────────────────────────────────────────

## Case 1: foo → a.BB.foo (simple fall-through branch).
.section .text,"ax",@progbits,unique,1
.globl foo
.type  foo,@function
foo:
  nop
  b a.BB.foo

.section .text,"ax",@progbits,unique,2
a.BB.foo:
  blr

## Case 2: b.BB.foo → c.BB.foo (beq falls through, b <far> does not).
## Modelled on the a.BB.foo pattern from the original test.
.section .text,"ax",@progbits,unique,3
b.BB.foo:
  nop
  beq c.BB.foo
  b far.BB.foo

.section .text,"ax",@progbits,unique,4
c.BB.foo:
  blr

.section .text,"ax",@progbits,unique,5
far.BB.foo:
  nop
  blr

## Case 3: d.BB.foo → e.BB.foo.
## Mirrors peak_mbb global_opt.__part.1:
##   bne <d.BB.foo+0x8>   ← intra-section, no relocation; target read from BD field
##   b   far2.BB.foo      ← cross-section relocation
##   b   e.BB.foo         ← cross-section relocation, falls through to nextIS
.section .text,"ax",@progbits,unique,6
d.BB.foo:
  nop
  bne .Lbc_target          ## targets .Lbc_target = e.BB.foo - 4 = nextIS - 4
  b   far2.BB.foo
.Lbc_target:
  b   e.BB.foo

.section .text,"ax",@progbits,unique,7
e.BB.foo:
  blr

.section .text,"ax",@progbits,unique,8
far2.BB.foo:
  nop
  blr

## Case 3 CTR variant: f.BB.foo mirrors peak_mbb price_out_impl.__part.72:
##   bdnz <f.BB.foo+0x8>  ← intra-section; targets the trailing 'b g.BB.foo'
##   b    far3.BB.foo
##   b    g.BB.foo
.section .text,"ax",@progbits,unique,9
f.BB.foo:
  nop
  bdnz .Lbdnz_target
  b    far3.BB.foo
.Lbdnz_target:
  b    g.BB.foo

.section .text,"ax",@progbits,unique,10
g.BB.foo:
  blr

.section .text,"ax",@progbits,unique,11
far3.BB.foo:
  nop
  blr
