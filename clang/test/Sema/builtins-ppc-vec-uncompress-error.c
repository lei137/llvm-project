// REQUIRES: powerpc-registered-target
// RUN: %clang_cc1 -triple powerpc64-unknown-linux-gnu -target-feature +altivec \
// RUN:   -target-feature +future-vector -flax-vector-conversions=none -fsyntax-only -verify %s
// RUN: %clang_cc1 -triple powerpc64le-unknown-linux-gnu -target-feature +altivec \
// RUN:   -target-feature +future-vector -flax-vector-conversions=none -fsyntax-only -verify %s

#include <altivec.h>

void test_vec_uncompressh_invalid_args() {
  vector unsigned char a;
  vector unsigned int b;
  vector signed int c;
  vector signed char d;
  vector unsigned short e;
  
  // Valid call
  vector signed short res1 = vec_uncompressh(a, b);
  
  // Invalid first argument type - should be vector unsigned char
  vector signed short res2 = vec_uncompressh(c, b); // expected-error {{passing '__vector int' (vector of 4 'int' values) to parameter of incompatible type '__vector unsigned char'}}
  // expected-note@altivec.h:* {{passing argument to parameter '__a' here}}
  vector signed short res3 = vec_uncompressh(d, b); // expected-error {{passing '__vector signed char' (vector of 16 'signed char' values) to parameter of incompatible type '__vector unsigned char'}}
  // expected-note@altivec.h:* {{passing argument to parameter '__a' here}}
  vector signed short res4 = vec_uncompressh(e, b); // expected-error {{passing '__vector unsigned short' (vector of 8 'unsigned short' values) to parameter of incompatible type '__vector unsigned char'}}
  // expected-note@altivec.h:* {{passing argument to parameter '__a' here}}
  
  // Invalid second argument type - should be vector unsigned int
  vector signed short res5 = vec_uncompressh(a, c); // expected-error {{passing '__vector int' (vector of 4 'int' values) to parameter of incompatible type '__vector unsigned int'}}
  // expected-note@altivec.h:* {{passing argument to parameter '__b' here}}
  vector signed short res6 = vec_uncompressh(a, d); // expected-error {{passing '__vector signed char' (vector of 16 'signed char' values) to parameter of incompatible type '__vector unsigned int'}}
  // expected-note@altivec.h:* {{passing argument to parameter '__b' here}}
  vector signed short res7 = vec_uncompressh(a, e); // expected-error {{passing '__vector unsigned short' (vector of 8 'unsigned short' values) to parameter of incompatible type '__vector unsigned int'}}
  // expected-note@altivec.h:* {{passing argument to parameter '__b' here}}
  
  // Both arguments invalid
  vector signed short res8 = vec_uncompressh(c, c); // expected-error {{passing '__vector int' (vector of 4 'int' values) to parameter of incompatible type '__vector unsigned char'}}
  // expected-note@altivec.h:* {{passing argument to parameter '__a' here}}
}

void test_builtin_altivec_vucmprhn_invalid_args() {
  vector unsigned char a;
  vector unsigned int b;
  vector signed int c;
  
  // Valid call
  vector signed short res1 = __builtin_altivec_vucmprhn(a, b);
  
  // Invalid argument types
  vector signed short res2 = __builtin_altivec_vucmprhn(c, b); // expected-error {{incompatible type}}
  vector signed short res3 = __builtin_altivec_vucmprhn(a, c); // expected-error {{incompatible type}}
}

// Made with Bob
