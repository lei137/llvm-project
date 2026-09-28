; RUN: llc < %s -mtriple=powerpc64le-unknown-linux-gnu \
; RUN:     -function-sections -basic-block-sections=all \
; RUN:     -unique-basic-block-section-names \
; RUN:   | FileCheck %s

; RUN: echo 'v1' > %t
; RUN: echo 'f biari_decode_symbol' >> %t
; RUN: echo 'c 0' >> %t
; RUN: llc < %s -mtriple=powerpc64le-unknown-linux-gnu \
; RUN:     -function-sections -basic-block-sections=%t \
; RUN:     -unique-basic-block-section-names \
; RUN:     -bbsections-cold-text-prefix=".text.unlikely." \
; RUN:   | FileCheck %s --check-prefix=LIST

;; Check that basic blocks in biari_decode_symbol are partitioned into basic block sections
;; and conditional branches across section boundaries are expanded to long branches.
; CHECK: .section .text.hot.biari_decode_symbol,"ax",@progbits
; CHECK-LABEL: biari_decode_symbol:
; CHECK:      cmplw 6, 11
; CHECK-NEXT: blt 0, .+8
; CHECK-NEXT: b biari_decode_symbol.__part.3
; CHECK-NEXT: b biari_decode_symbol.__part.1
; CHECK: biari_decode_symbol.__part.1:

; LIST: .section .text.hot.biari_decode_symbol,"ax",@progbits
; LIST-LABEL: biari_decode_symbol:
; LIST: .section .text.unlikely.biari_decode_symbol,"ax",@progbits
; LIST-LABEL: biari_decode_symbol.cold:

@rLPS_table_64x4 = external hidden constant [64 x [4 x i8]], align 1
@AC_next_state_MPS_64 = external hidden constant [64 x i8], align 1
@renorm_table_32 = external hidden constant [32 x i8], align 1
@AC_next_state_LPS_64 = external hidden constant [64 x i8], align 1

define dso_local zeroext i32 @biari_decode_symbol(ptr %dep, ptr %bi_ct) #0 section ".text.hot.biari_decode_symbol" {
entry:
  %MPS = getelementptr inbounds i8, ptr %bi_ct, i64 2
  %0 = load i8, ptr %MPS, align 2
  %conv = zext i8 %0 to i32
  %Dvalue = getelementptr inbounds i8, ptr %dep, i64 4
  %1 = load i16, ptr %bi_ct, align 2
  %idxprom = zext i16 %1 to i64
  %arrayidx = getelementptr inbounds [4 x i8], ptr @rLPS_table_64x4, i64 %idxprom
  %2 = load i32, ptr %dep, align 4
  %shr = lshr i32 %2, 6
  %and = and i32 %shr, 3
  %idxprom2 = zext i32 %and to i64
  %arrayidx3 = getelementptr inbounds i8, ptr %arrayidx, i64 %idxprom2
  %3 = load i8, ptr %arrayidx3, align 1
  %conv4 = zext i8 %3 to i32
  %DbitsLeft5 = getelementptr inbounds i8, ptr %dep, i64 8
  %sub = sub i32 %2, %conv4
  store i32 %sub, ptr %dep, align 4
  %4 = load i32, ptr %Dvalue, align 4
  %5 = load i32, ptr %DbitsLeft5, align 4
  %shl = shl i32 %sub, %5
  %cmp = icmp ult i32 %4, %shl
  br i1 %cmp, label %if.then, label %if.else14

if.then:                                          ; preds = %entry
  %arrayidx8 = getelementptr inbounds i8, ptr @AC_next_state_MPS_64, i64 %idxprom
  %6 = load i8, ptr %arrayidx8, align 1
  %conv9 = zext i8 %6 to i16
  store i16 %conv9, ptr %bi_ct, align 2
  %cmp10 = icmp ugt i32 %sub, 255
  br i1 %cmp10, label %cleanup, label %if.else

if.else:                                          ; preds = %if.then
  %shl13 = shl i32 %sub, 1
  store i32 %shl13, ptr %dep, align 4
  %dec = add nsw i32 %5, -1
  store i32 %dec, ptr %DbitsLeft5, align 4
  br label %if.end34

if.else14:                                        ; preds = %entry
  %shr15 = lshr i32 %conv4, 3
  %idxprom17 = zext i32 %shr15 to i64
  %arrayidx18 = getelementptr inbounds i8, ptr @renorm_table_32, i64 %idxprom17
  %7 = load i8, ptr %arrayidx18, align 1
  %conv19 = zext i8 %7 to i32
  %sub22 = sub i32 %4, %shl
  store i32 %sub22, ptr %Dvalue, align 4
  %shl23 = shl i32 %conv4, %conv19
  store i32 %shl23, ptr %dep, align 4
  %sub24 = sub nsw i32 %5, %conv19
  store i32 %sub24, ptr %DbitsLeft5, align 4
  %xor = xor i32 %conv, 1
  %tobool.not = icmp eq i16 %1, 0
  br i1 %tobool.not, label %if.then25, label %if.end30

if.then25:                                        ; preds = %if.else14
  %8 = xor i8 %0, 1
  store i8 %8, ptr %MPS, align 2
  br label %if.end30

if.end30:                                         ; preds = %if.then25, %if.else14
  %arrayidx32 = getelementptr inbounds i8, ptr @AC_next_state_LPS_64, i64 %idxprom
  %9 = load i8, ptr %arrayidx32, align 1
  %conv33 = zext i8 %9 to i16
  store i16 %conv33, ptr %bi_ct, align 2
  br label %if.end34

if.end34:                                         ; preds = %if.end30, %if.else
  %10 = phi i32 [ %sub22, %if.end30 ], [ %4, %if.else ]
  %11 = phi i32 [ %sub24, %if.end30 ], [ %dec, %if.else ]
  %bit.0 = phi i32 [ %xor, %if.end30 ], [ %conv, %if.else ]
  %cmp35 = icmp sgt i32 %11, 0
  br i1 %cmp35, label %cleanup, label %if.else38

if.else38:                                        ; preds = %if.end34
  %shl39 = shl i32 %10, 16
  store i32 %shl39, ptr %Dvalue, align 4
  %Dcodestrm_len.i = getelementptr inbounds i8, ptr %dep, i64 24
  %12 = load ptr, ptr %Dcodestrm_len.i, align 8
  %13 = load i32, ptr %12, align 4
  %add.i = add nsw i32 %13, 2
  store i32 %add.i, ptr %12, align 4
  %Dcodestrm.i = getelementptr inbounds i8, ptr %dep, i64 16
  %14 = load ptr, ptr %Dcodestrm.i, align 8
  %idxprom.i = sext i32 %13 to i64
  %arrayidx.i = getelementptr inbounds i8, ptr %14, i64 %idxprom.i
  %15 = load i8, ptr %arrayidx.i, align 1
  %conv.i = zext i8 %15 to i32
  %shl.i = shl nuw nsw i32 %conv.i, 8
  %arrayidx5.i = getelementptr inbounds i8, ptr %arrayidx.i, i64 1
  %16 = load i8, ptr %arrayidx5.i, align 1
  %conv6.i = zext i8 %16 to i32
  %or.i = or disjoint i32 %shl.i, %conv6.i
  %17 = load i32, ptr %Dvalue, align 4
  %or = or i32 %or.i, %17
  store i32 %or, ptr %Dvalue, align 4
  %18 = load i32, ptr %DbitsLeft5, align 4
  %add = add nsw i32 %18, 16
  store i32 %add, ptr %DbitsLeft5, align 4
  br label %cleanup

cleanup:                                          ; preds = %if.end34, %if.then, %if.else38
  %retval.0 = phi i32 [ %bit.0, %if.else38 ], [ %conv, %if.then ], [ %bit.0, %if.end34 ]
  ret i32 %retval.0
}

attributes #0 = { nounwind }
