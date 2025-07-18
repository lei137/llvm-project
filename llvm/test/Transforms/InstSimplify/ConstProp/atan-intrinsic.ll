; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 5
; RUN: opt -S -passes=instsimplify < %s | FileCheck %s

define double @test_atan_0() {
; CHECK-LABEL: define double @test_atan_0() {
; CHECK-NEXT:    ret double 0.000000e+00
;
  %result = call double @llvm.atan.f64(double 0.0)
  ret double %result
}

define double @test_atan_one() {
; CHECK-LABEL: define double @test_atan_one() {
; CHECK-NEXT:    ret double 0x3FE921FB54442D18
;
  %res = call double @llvm.atan.f64(double 1.0)
  ret double %res
}

define <2 x double> @test_atan_v2() {
; CHECK-LABEL: define <2 x double> @test_atan_v2() {
; CHECK-NEXT:    ret <2 x double> zeroinitializer
;
  %result = call <2 x double> @llvm.atan.v2f64(<2 x double> zeroinitializer)
  ret <2 x double> %result
}

define double @test_atan_neg0() {
; CHECK-LABEL: define double @test_atan_neg0() {
; CHECK-NEXT:    ret double -0.000000e+00
;
  %res = call double @llvm.atan.f64(double -0.0)
  ret double %res
}

define double @test_atan_poison() {
; CHECK-LABEL: define double @test_atan_poison() {
; CHECK-NEXT:    ret double poison
;
  %res = call double @llvm.atan.f64(double poison)
  ret double %res
}

define double @test_atan_undef() {
; CHECK-LABEL: define double @test_atan_undef() {
; CHECK-NEXT:    [[RES:%.*]] = call double @llvm.atan.f64(double undef)
; CHECK-NEXT:    ret double [[RES]]
;
  %res = call double @llvm.atan.f64(double undef)
  ret double %res
}

define double @test_atan_snan() {
; CHECK-LABEL: define double @test_atan_snan() {
; CHECK-NEXT:    [[RES:%.*]] = call double @llvm.atan.f64(double 0x7FF0000000000001)
; CHECK-NEXT:    ret double [[RES]]
;
  %res = call double @llvm.atan.f64(double 0x7ff0000000000001)
  ret double %res
}

define double @test_atan_qnan() {
; CHECK-LABEL: define double @test_atan_qnan() {
; CHECK-NEXT:    [[RES:%.*]] = call double @llvm.atan.f64(double 0x7FF8000000000000)
; CHECK-NEXT:    ret double [[RES]]
;
  %res = call double @llvm.atan.f64(double 0x7ff8000000000000)
  ret double %res
}

define double @test_atan_pos_inf() {
; CHECK-LABEL: define double @test_atan_pos_inf() {
; CHECK-NEXT:    [[RES:%.*]] = call double @llvm.atan.f64(double 0x7FF0000000000000)
; CHECK-NEXT:    ret double [[RES]]
;
  %res = call double @llvm.atan.f64(double 0x7ff0000000000000)
  ret double %res
}

define double @test_atan_neg_inf() {
; CHECK-LABEL: define double @test_atan_neg_inf() {
; CHECK-NEXT:    [[RES:%.*]] = call double @llvm.atan.f64(double 0xFFF0000000000000)
; CHECK-NEXT:    ret double [[RES]]
;
  %res = call double @llvm.atan.f64(double 0xfff0000000000000)
  ret double %res
}
