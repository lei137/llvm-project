// REQUIRES: powerpc-registered-target
// RUN: %clang_cc1 -triple powerpc64-unknown-linux-gnu -target-cpu future \
// RUN:   -flax-vector-conversions=none -fsyntax-only -verify %s
// RUN: %clang_cc1 -triple powerpc64le-unknown-linux-gnu -target-cpu future \
// RUN:   -flax-vector-conversions=none -fsyntax-only -verify %s

#include <altivec.h>

// Test that valid overloads work correctly
void test_vec_uncompressh_valid() {
  vector unsigned char a;
  vector unsigned int b;
  vector unsigned short e;

  // Valid calls for each overload
  vector signed short res1 = vec_uncompressh(a, b);
  vector signed int res2 = vec_uncompressh(e, e);
  vector signed long long res3 = vec_uncompressh(b, a);
}

// Test that invalid types produce errors
void test_vec_uncompressh_invalid() {
  vector unsigned char a;
  vector unsigned int b;
  vector float f;
  vector double d;

  // Invalid - no matching overload (float/double types not supported)
  vector signed short res1 = vec_uncompressh(f, b); // expected-error {{no matching function for call to 'vec_uncompressh'}}
  // expected-note@altivec.h:* 3 {{candidate function not viable}}
  vector signed short res2 = vec_uncompressh(a, f); // expected-error {{no matching function for call to 'vec_uncompressh'}}
  // expected-note@altivec.h:* 3 {{candidate function not viable}}
  vector signed short res3 = vec_uncompressh(d, b); // expected-error {{no matching function for call to 'vec_uncompressh'}}
  // expected-note@altivec.h:* 3 {{candidate function not viable}}
}

// Test builtin functions with strict type checking
void test_builtin_vucmprhn() {
  vector unsigned char a;
  vector unsigned int b;
  vector signed int c;
  vector unsigned short e;

  // Valid call
  vector signed short res1 = __builtin_altivec_vucmprhn(a, b);

  // Invalid argument types - builtins require exact types
  vector signed short res2 = __builtin_altivec_vucmprhn(c, b); // expected-error {{incompatible type}}
  vector signed short res3 = __builtin_altivec_vucmprhn(a, c); // expected-error {{incompatible type}}
  vector signed short res4 = __builtin_altivec_vucmprhn(e, b); // expected-error {{incompatible type}}
}

void test_builtin_vucmprhb() {
  vector unsigned short a;
  vector signed short c;
  vector unsigned char d;

  // Valid call
  vector signed int res1 = __builtin_altivec_vucmprhb(a, a);

  // Invalid argument types
  vector signed int res2 = __builtin_altivec_vucmprhb(c, a); // expected-error {{incompatible type}}
  vector signed int res3 = __builtin_altivec_vucmprhb(a, c); // expected-error {{incompatible type}}
  vector signed int res4 = __builtin_altivec_vucmprhb(d, a); // expected-error {{incompatible type}}
}

void test_builtin_vucmprhh() {
  vector unsigned int a;
  vector unsigned char b;
  vector signed int c;
  vector unsigned short d;

  // Valid call
  vector signed long long res1 = __builtin_altivec_vucmprhh(a, b);

  // Invalid argument types
  vector signed long long res2 = __builtin_altivec_vucmprhh(c, b); // expected-error {{incompatible type}}
  vector signed long long res3 = __builtin_altivec_vucmprhh(a, c); // expected-error {{incompatible type}}
  vector signed long long res4 = __builtin_altivec_vucmprhh(d, b); // expected-error {{incompatible type}}
}

// Test vec_uncompressl valid overloads
void test_vec_uncompressl_valid() {
  vector unsigned char a;
  vector unsigned int b;
  vector unsigned short e;

  // Valid calls for each overload
  vector signed short res1 = vec_uncompressl(a, b);
  vector signed int res2 = vec_uncompressl(e, e);
  vector signed long long res3 = vec_uncompressl(b, a);
}

// Test vec_uncompressl invalid types
void test_vec_uncompressl_invalid() {
  vector unsigned char a;
  vector unsigned int b;
  vector float f;

  // Invalid - no matching overload
  vector signed short res1 = vec_uncompressl(f, b); // expected-error {{no matching function for call to 'vec_uncompressl'}}
  // expected-note@altivec.h:* 3 {{candidate function not viable}}
  vector signed short res2 = vec_uncompressl(a, f); // expected-error {{no matching function for call to 'vec_uncompressl'}}
  // expected-note@altivec.h:* 3 {{candidate function not viable}}
}

void test_builtin_vucmprln() {
  vector unsigned char a;
  vector unsigned int b;
  vector signed int c;

  // Valid call
  vector signed short res1 = __builtin_altivec_vucmprln(a, b);

  // Invalid argument types
  vector signed short res2 = __builtin_altivec_vucmprln(c, b); // expected-error {{incompatible type}}
  vector signed short res3 = __builtin_altivec_vucmprln(a, c); // expected-error {{incompatible type}}
}

void test_builtin_vucmprlb() {
  vector unsigned short a;
  vector signed short c;

  // Valid call
  vector signed int res1 = __builtin_altivec_vucmprlb(a, a);

  // Invalid argument types
  vector signed int res2 = __builtin_altivec_vucmprlb(c, a); // expected-error {{incompatible type}}
  vector signed int res3 = __builtin_altivec_vucmprlb(a, c); // expected-error {{incompatible type}}
}

void test_builtin_vucmprlh() {
  vector unsigned int a;
  vector unsigned char b;
  vector signed int c;

  // Valid call
  vector signed long long res1 = __builtin_altivec_vucmprlh(a, b);

  // Invalid argument types
  vector signed long long res2 = __builtin_altivec_vucmprlh(c, b); // expected-error {{incompatible type}}
  vector signed long long res3 = __builtin_altivec_vucmprlh(a, c); // expected-error {{incompatible type}}
}

// Made with Bob
