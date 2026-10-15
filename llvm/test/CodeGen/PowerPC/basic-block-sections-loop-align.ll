; RUN: llc < %s -mtriple=powerpc64le-linux-gnu -mcpu=pwr9 \
; RUN:   | FileCheck %s --check-prefix=NOBBSECTIONS
; RUN: llc < %s -mtriple=powerpc64le-linux-gnu -mcpu=pwr9 \
; RUN:   -basic-block-sections=all \
; RUN:   | FileCheck %s --check-prefix=BBSECTIONS

;; Verify that PPCTargetLowering::getPrefLoopAlignment suppresses its
;; performance-based 32-byte alignment heuristics when
;; -basic-block-sections is active.  The heuristics (small-loop cache-line
;; fit and innermost-loop depth) assume code is laid out contiguously; with
;; BBS, blocks end up in separate ELF sections where the padding is wasteful.
;;
;; Two cases are tested:
;;  1. small_loop  - small loop body (5 instrs, 20 bytes) that triggers the
;;                   "fits in one 32-byte cache line" heuristic.
;;  2. nested_loop - depth-2 innermost loop that triggers the depth heuristic.
;;
;; Without BBS both loops get .p2align 5 (32 bytes).
;; With BBS both fall back to the base PrefLoopAlignment of 16 bytes
;; (.p2align 4), set unconditionally in PPCTargetLowering via
;; setPrefLoopAlignment(Align(16)).

; NOBBSECTIONS-LABEL: small_loop:
; NOBBSECTIONS:         .p2align 5

; BBSECTIONS-LABEL: small_loop:
; BBSECTIONS-NOT:      .p2align 5
; BBSECTIONS:          .p2align 4

; NOBBSECTIONS-LABEL: nested_loop:
; NOBBSECTIONS:         .p2align 5

; BBSECTIONS-LABEL: nested_loop:
; BBSECTIONS-NOT:      .p2align 5
; BBSECTIONS:          .p2align 4

;; ---- IR ----

define i64 @small_loop(ptr %a, ptr %b, i64 %n) {
entry:
  br label %loop
loop:
  %i      = phi i64 [ 0, %entry ], [ %i.next, %loop ]
  %ai     = getelementptr i64, ptr %a, i64 %i
  %bi     = getelementptr i64, ptr %b, i64 %i
  %av     = load i64, ptr %ai, align 8
  %bv     = load i64, ptr %bi, align 8
  %s      = add i64 %av, %bv
  store i64 %s, ptr %ai, align 8
  %i.next = add i64 %i, 1
  %cmp    = icmp slt i64 %i.next, %n
  br i1 %cmp, label %loop, label %exit
exit:
  ret i64 0
}

define i64 @nested_loop(ptr %a, i64 %n, i64 %m) {
entry:
  br label %outer
outer:
  %j = phi i64 [ 0, %entry ], [ %j.next, %outer.latch ]
  br label %inner
inner:
  %i      = phi i64 [ 0, %outer ], [ %i.next, %inner ]
  %ai     = getelementptr i64, ptr %a, i64 %i
  %av     = load i64, ptr %ai, align 8
  %s      = add i64 %av, %j
  store i64 %s, ptr %ai, align 8
  %i.next = add i64 %i, 1
  %cmp1   = icmp slt i64 %i.next, %n
  br i1 %cmp1, label %inner, label %outer.latch
outer.latch:
  %j.next = add i64 %j, 1
  %cmp2   = icmp slt i64 %j.next, %m
  br i1 %cmp2, label %outer, label %exit
exit:
  ret i64 0
}
