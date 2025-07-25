; RUN: llc -mtriple=amdgcn -mcpu=gfx600 < %s | FileCheck --check-prefix=GCN %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx700 < %s | FileCheck --check-prefix=GCN %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx801 < %s | FileCheck --check-prefix=GCN %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx900 < %s | FileCheck --check-prefix=GCN %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx906 < %s | FileCheck --check-prefix=GCN-DL %s

; GCN-LABEL: {{^}}scalar_xnor_i32_one_use
; GCN: s_xnor_b32
define amdgpu_kernel void @scalar_xnor_i32_one_use(
    ptr addrspace(1) %r0, i32 %a, i32 %b) {
entry:
  %xor = xor i32 %a, %b
  %r0.val = xor i32 %xor, -1
  store i32 %r0.val, ptr addrspace(1) %r0
  ret void
}

; GCN-LABEL: {{^}}scalar_xnor_i32_mul_use
; GCN-NOT: s_xnor_b32
; GCN: s_xor_b32
; GCN: s_not_b32
; GCN: s_add_i32
define amdgpu_kernel void @scalar_xnor_i32_mul_use(
    ptr addrspace(1) %r0, ptr addrspace(1) %r1, i32 %a, i32 %b) {
entry:
  %xor = xor i32 %a, %b
  %r0.val = xor i32 %xor, -1
  %r1.val = add i32 %xor, %a
  store i32 %r0.val, ptr addrspace(1) %r0
  store i32 %r1.val, ptr addrspace(1) %r1
  ret void
}

; GCN-LABEL: {{^}}scalar_xnor_i64_one_use
; GCN: s_xnor_b64
define amdgpu_kernel void @scalar_xnor_i64_one_use(
    ptr addrspace(1) %r0, i64 %a, i64 %b) {
entry:
  %xor = xor i64 %a, %b
  %r0.val = xor i64 %xor, -1
  store i64 %r0.val, ptr addrspace(1) %r0
  ret void
}

; GCN-LABEL: {{^}}scalar_xnor_i64_mul_use
; GCN-NOT: s_xnor_b64
; GCN: s_xor_b64
; GCN: s_not_b64
; GCN: s_add_u32
; GCN: s_addc_u32
define amdgpu_kernel void @scalar_xnor_i64_mul_use(
    ptr addrspace(1) %r0, ptr addrspace(1) %r1, i64 %a, i64 %b) {
entry:
  %xor = xor i64 %a, %b
  %r0.val = xor i64 %xor, -1
  %r1.val = add i64 %xor, %a
  store i64 %r0.val, ptr addrspace(1) %r0
  store i64 %r1.val, ptr addrspace(1) %r1
  ret void
}

; GCN-LABEL: {{^}}vector_xnor_i32_one_use
; GCN-NOT: s_xnor_b32
; GCN: v_xor_b32
; GCN: v_not_b32
; GCN-DL: v_xnor_b32
define i32 @vector_xnor_i32_one_use(i32 %a, i32 %b) {
entry:
  %xor = xor i32 %a, %b
  %r = xor i32 %xor, -1
  ret i32 %r
}

; GCN-LABEL: {{^}}vector_xnor_i64_one_use
; GCN-NOT: s_xnor_b64
; GCN: v_xor_b32
; GCN: v_xor_b32
; GCN: v_not_b32
; GCN: v_not_b32
; GCN-DL: v_xnor_b32
; GCN-DL: v_xnor_b32
define i64 @vector_xnor_i64_one_use(i64 %a, i64 %b) {
entry:
  %xor = xor i64 %a, %b
  %r = xor i64 %xor, -1
  ret i64 %r
}

; GCN-LABEL: {{^}}xnor_s_v_i32_one_use
; GCN-NOT: s_xnor_b32
; GCN: s_not_b32
; GCN: v_xor_b32
define amdgpu_kernel void @xnor_s_v_i32_one_use(ptr addrspace(1) %out, i32 %s) {
  %v = call i32 @llvm.amdgcn.workitem.id.x() #1
  %xor = xor i32 %s, %v
  %d = xor i32 %xor, -1
  store i32 %d, ptr addrspace(1) %out
  ret void
}

; GCN-LABEL: {{^}}xnor_v_s_i32_one_use
; GCN-NOT: s_xnor_b32
; GCN: s_not_b32
; GCN: v_xor_b32
define amdgpu_kernel void @xnor_v_s_i32_one_use(ptr addrspace(1) %out, i32 %s) {
  %v = call i32 @llvm.amdgcn.workitem.id.x() #1
  %xor = xor i32 %v, %s
  %d = xor i32 %xor, -1
  store i32 %d, ptr addrspace(1) %out
  ret void
}

; GCN-LABEL: {{^}}xnor_i64_s_v_one_use
; GCN-NOT: s_xnor_b64
; GCN: s_not_b64
; GCN: v_xor_b32_e32
; GCN-DL: v_xnor_b32
; GCN-DL: v_xnor_b32
define amdgpu_kernel void @xnor_i64_s_v_one_use(
  ptr addrspace(1) %r0, i64 %a) {
entry:
  %b32 = call i32 @llvm.amdgcn.workitem.id.x() #1
  %b64 = zext i32 %b32 to i64
  %b = shl i64 %b64, 29
  %xor = xor i64 %a, %b
  %r0.val = xor i64 %xor, -1
  store i64 %r0.val, ptr addrspace(1) %r0
  ret void
}

; GCN-LABEL: {{^}}xnor_i64_v_s_one_use
; GCN-NOT: s_xnor_b64
; GCN: s_not_b64
; GCN: v_xor_b32_e32
; GCN-DL: v_xnor_b32
; GCN-DL: v_xnor_b32
define amdgpu_kernel void @xnor_i64_v_s_one_use(
  ptr addrspace(1) %r0, i64 %a) {
entry:
  %b32 = call i32 @llvm.amdgcn.workitem.id.x() #1
  %b64 = zext i32 %b32 to i64
  %b = shl i64 %b64, 29
  %xor = xor i64 %b, %a
  %r0.val = xor i64 %xor, -1
  store i64 %r0.val, ptr addrspace(1) %r0
  ret void
}

; GCN-LABEL: {{^}}vector_xor_na_b_i32_one_use
; GCN-NOT: s_xnor_b32
; GCN: v_xor_b32
; GCN: v_not_b32
; GCN-DL: v_xnor_b32
define i32 @vector_xor_na_b_i32_one_use(i32 %a, i32 %b) {
entry:
  %na = xor i32 %a, -1
  %r = xor i32 %na, %b
  ret i32 %r
}

; GCN-LABEL: {{^}}vector_xor_a_nb_i32_one_use
; GCN-NOT: s_xnor_b32
; GCN: v_xor_b32
; GCN: v_not_b32
; GCN-DL: v_xnor_b32
define i32 @vector_xor_a_nb_i32_one_use(i32 %a, i32 %b) {
entry:
  %nb = xor i32 %b, -1
  %r = xor i32 %a, %nb
  ret i32 %r
}

; GCN-LABEL: {{^}}scalar_xor_a_nb_i64_one_use
; GCN: s_xnor_b64
define amdgpu_kernel void @scalar_xor_a_nb_i64_one_use(
    ptr addrspace(1) %r0, i64 %a, i64 %b) {
entry:
  %nb = xor i64 %b, -1
  %r0.val = xor i64 %a, %nb
  store i64 %r0.val, ptr addrspace(1) %r0
  ret void
}

; GCN-LABEL: {{^}}scalar_xor_na_b_i64_one_use
; GCN: s_xnor_b64
define amdgpu_kernel void @scalar_xor_na_b_i64_one_use(
    ptr addrspace(1) %r0, i64 %a, i64 %b) {
entry:
  %na = xor i64 %a, -1
  %r0.val = xor i64 %na, %b
  store i64 %r0.val, ptr addrspace(1) %r0
  ret void
}

; Function Attrs: nounwind readnone
declare i32 @llvm.amdgcn.workitem.id.x() #0
