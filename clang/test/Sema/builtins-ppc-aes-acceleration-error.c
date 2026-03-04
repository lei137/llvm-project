// REQUIRES: powerpc-registered-target
// RUN: %clang_cc1 -triple powerpc64le-unknown-unknown -target-cpu future \
// RUN:   -fsyntax-only -verify %s
// RUN: %clang_cc1 -triple powerpc64-unknown-unknown -target-cpu future \
// RUN:   -fsyntax-only -verify %s

// Made with AI

void test_aes_encrypt_paired_invalid_imm(void) {
  __vector_pair vp1, vp2;

  // Test invalid immediate values (valid range is 0-2)
  __vector_pair res1 = __builtin_aes_encrypt_paired(vp1, vp2, 3);  // expected-error-re {{argument value {{.*}} is outside the valid range}}
  __vector_pair res2 = __builtin_aes_encrypt_paired(vp1, vp2, -1); // expected-error-re {{argument value {{.*}} is outside the valid range}}
  __vector_pair res3 = __builtin_aes_encrypt_paired(vp1, vp2, 10); // expected-error-re {{argument value {{.*}} is outside the valid range}}
}

void test_aes_encrypt_paired_type_mismatch(void) {
  __vector_pair vp;
  vector unsigned char vc;
  int i = 0;

  // Test type mismatches
  __vector_pair res1 = __builtin_aes_encrypt_paired(vc, vp, 0);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
  __vector_pair res2 = __builtin_aes_encrypt_paired(vp, vc, 0);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
  __vector_pair res3 = __builtin_aes_encrypt_paired(vp, vp, vc);   // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type 'int'}}
}

void test_aes128_encrypt_paired_type_mismatch(void) {
  __vector_pair vp;
  vector unsigned char vc;

  // Test type mismatches for aes128 variant
  __vector_pair res1 = __builtin_aes128_encrypt_paired(vc, vp);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
  __vector_pair res2 = __builtin_aes128_encrypt_paired(vp, vc);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
}

void test_aes192_encrypt_paired_type_mismatch(void) {
  __vector_pair vp;
  vector unsigned char vc;

  // Test type mismatches for aes192 variant
  __vector_pair res1 = __builtin_aes192_encrypt_paired(vc, vp);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
  __vector_pair res2 = __builtin_aes192_encrypt_paired(vp, vc);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
}

void test_aes256_encrypt_paired_type_mismatch(void) {
  __vector_pair vp;
  vector unsigned char vc;

  // Test type mismatches for aes256 variant
  __vector_pair res1 = __builtin_aes256_encrypt_paired(vc, vp);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
  __vector_pair res2 = __builtin_aes256_encrypt_paired(vp, vc);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
}

void test_aes_decrypt_paired_invalid_imm(void) {
  __vector_pair vp1, vp2;

  // Test invalid immediate values (valid range is 0-2)
  __vector_pair res1 = __builtin_aes_decrypt_paired(vp1, vp2, 3);  // expected-error-re {{argument value {{.*}} is outside the valid range}}
  __vector_pair res2 = __builtin_aes_decrypt_paired(vp1, vp2, -1); // expected-error-re {{argument value {{.*}} is outside the valid range}}
  __vector_pair res3 = __builtin_aes_decrypt_paired(vp1, vp2, 10); // expected-error-re {{argument value {{.*}} is outside the valid range}}
}

void test_aes_decrypt_paired_type_mismatch(void) {
  __vector_pair vp;
  vector unsigned char vc;
  int i = 0;

  // Test type mismatches
  __vector_pair res1 = __builtin_aes_decrypt_paired(vc, vp, 0);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
  __vector_pair res2 = __builtin_aes_decrypt_paired(vp, vc, 0);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
  __vector_pair res3 = __builtin_aes_decrypt_paired(vp, vp, vc);   // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type 'int'}}
}

void test_aes128_decrypt_paired_type_mismatch(void) {
  __vector_pair vp;
  vector unsigned char vc;

  // Test type mismatches for aes128 variant
  __vector_pair res1 = __builtin_aes128_decrypt_paired(vc, vp);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
  __vector_pair res2 = __builtin_aes128_decrypt_paired(vp, vc);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
}

void test_aes192_decrypt_paired_type_mismatch(void) {
  __vector_pair vp;
  vector unsigned char vc;

  // Test type mismatches for aes192 variant
  __vector_pair res1 = __builtin_aes192_decrypt_paired(vc, vp);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
  __vector_pair res2 = __builtin_aes192_decrypt_paired(vp, vc);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
}

void test_aes256_decrypt_paired_type_mismatch(void) {
  __vector_pair vp;
  vector unsigned char vc;

  // Test type mismatches for aes256 variant
  __vector_pair res1 = __builtin_aes256_decrypt_paired(vc, vp);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
  __vector_pair res2 = __builtin_aes256_decrypt_paired(vp, vc);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
}
void test_aes_genlastkey_paired_invalid_imm(void) {
  __vector_pair vp1;

  // Test invalid immediate values (valid range is 0-2)
  __vector_pair res1 = __builtin_aes_genlastkey_paired(vp1, 3);  // expected-error-re {{argument value {{.*}} is outside the valid range}}
  __vector_pair res2 = __builtin_aes_genlastkey_paired(vp1, -1); // expected-error-re {{argument value {{.*}} is outside the valid range}}
  __vector_pair res3 = __builtin_aes_genlastkey_paired(vp1, 10); // expected-error-re {{argument value {{.*}} is outside the valid range}}
}

void test_aes_genlastkey_paired_type_mismatch(void) {
  __vector_pair vp;
  vector unsigned char vc;
  int i = 0;

  // Test type mismatches
  __vector_pair res1 = __builtin_aes_genlastkey_paired(vc, 0);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
  __vector_pair res2 = __builtin_aes_genlastkey_paired(vp, vc);   // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type 'int'}}
}

void test_aes128_genlastkey_paired_type_mismatch(void) {
  __vector_pair vp;
  vector unsigned char vc;

  // Test type mismatches for aes128 variant
  __vector_pair res1 = __builtin_aes128_genlastkey_paired(vc);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
}

void test_aes192_genlastkey_paired_type_mismatch(void) {
  __vector_pair vp;
  vector unsigned char vc;

  // Test type mismatches for aes192 variant
  __vector_pair res1 = __builtin_aes192_genlastkey_paired(vc);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
}

void test_aes256_genlastkey_paired_type_mismatch(void) {
  __vector_pair vp;
  vector unsigned char vc;

  // Test type mismatches for aes256 variant
  __vector_pair res1 = __builtin_aes256_genlastkey_paired(vc);    // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type '__vector_pair'}}
}

void test_galois_field_mult_invalid_imm(void) {
  vector unsigned char a, b;

  // Test invalid immediate values (valid range is 0-1)
  vector unsigned char res1 = __builtin_galois_field_mult(a, b, 2);  // expected-error-re {{argument value {{.*}} is outside the valid range}}
  vector unsigned char res2 = __builtin_galois_field_mult(a, b, -1); // expected-error-re {{argument value {{.*}} is outside the valid range}}
  vector unsigned char res3 = __builtin_galois_field_mult(a, b, 10); // expected-error-re {{argument value {{.*}} is outside the valid range}}
}

void test_galois_field_mult_type_mismatch(void) {
  vector unsigned char vc;
  __vector_pair vp;
  int i = 0;

  // Test type mismatches
  vector unsigned char res1 = __builtin_galois_field_mult(vp, vc, 0);    // expected-error {{passing '__vector_pair' to parameter of incompatible type '__vector unsigned char' (vector of 16 'unsigned char' values)}}
  vector unsigned char res2 = __builtin_galois_field_mult(vc, vp, 0);    // expected-error {{passing '__vector_pair' to parameter of incompatible type '__vector unsigned char' (vector of 16 'unsigned char' values)}}
  vector unsigned char res3 = __builtin_galois_field_mult(vc, vc, vc);   // expected-error {{passing '__vector unsigned char' (vector of 16 'unsigned char' values) to parameter of incompatible type 'int'}}
}

void test_galois_field_mult_gcm_type_mismatch(void) {
  vector unsigned char vc;
  __vector_pair vp;

  // Test type mismatches for gcm variant
  vector unsigned char res1 = __builtin_galois_field_mult_gcm(vp, vc);    // expected-error {{passing '__vector_pair' to parameter of incompatible type '__vector unsigned char' (vector of 16 'unsigned char' values)}}
  vector unsigned char res2 = __builtin_galois_field_mult_gcm(vc, vp);    // expected-error {{passing '__vector_pair' to parameter of incompatible type '__vector unsigned char' (vector of 16 'unsigned char' values)}}
}

void test_galois_field_mult_xts_type_mismatch(void) {
  vector unsigned char vc;
  __vector_pair vp;

  // Test type mismatches for xts variant
  vector unsigned char res1 = __builtin_galois_field_mult_xts(vp, vc);    // expected-error {{passing '__vector_pair' to parameter of incompatible type '__vector unsigned char' (vector of 16 'unsigned char' values)}}
  vector unsigned char res2 = __builtin_galois_field_mult_xts(vc, vp);    // expected-error {{passing '__vector_pair' to parameter of incompatible type '__vector unsigned char' (vector of 16 'unsigned char' values)}}
}
