;; Verify that basic blocks in functions with active exception handling are not
;; split to separate sections on PowerPC.  Non-entry FDEs produced by BBS lack
;; CFI directives (CFA=r1+0, LR=undefined), and the LSDA call-site table uses
;; offsets relative to the function entry, both of which break stack unwinding.
;;
;; Test both bbs=all (no unique per-block sections) and bbs=list (no cold
;; section) for a function with a landing pad.

; RUN: llc < %s -mtriple=powerpc64le-unknown-linux-gnu \
; RUN:     -function-sections -basic-block-sections=all \
; RUN:     -unique-basic-block-section-names \
; RUN:   | FileCheck %s --check-prefix=ALL
;
; RUN: echo 'v1' > %t
; RUN: echo 'f may_throw' >> %t
; RUN: echo 'c 0' >> %t
; RUN: llc < %s -mtriple=powerpc64le-unknown-linux-gnu \
; RUN:     -function-sections -basic-block-sections=%t \
; RUN:     -unique-basic-block-section-names \
; RUN:     -bbsections-cold-text-prefix=".text.unlikely." \
; RUN:   | FileCheck %s --check-prefix=LIST

;; ALL: .section .text.may_throw,"ax",@progbits
;; ALL-LABEL: may_throw:
;; With bbs=all, no extra per-block sections should be emitted for this
;; function because it has a landing pad.
;; ALL-NOT: may_throw.__part.

;; LIST-LABEL: may_throw:
;; With bbs=list, the cold-candidate block must not be moved to the cold
;; section because the function has a landing pad.
;; LIST-NOT: .text.unlikely.may_throw

declare void @__cxa_throw(ptr, ptr, ptr) noreturn
declare i32 @__gxx_personality_v0(...)
declare ptr @__cxa_allocate_exception(i64)

define void @may_throw(i32 %n) uwtable personality ptr @__gxx_personality_v0 {
entry:
  %cmp = icmp sgt i32 %n, 0
  br i1 %cmp, label %if.then, label %ret

if.then:
  %ex = call ptr @__cxa_allocate_exception(i64 8)
  invoke void @__cxa_throw(ptr %ex, ptr null, ptr null)
          to label %unreach unwind label %lpad

lpad:
  %lp = landingpad { ptr, i32 } cleanup
  resume { ptr, i32 } %lp

unreach:
  unreachable

ret:
  ret void
}
