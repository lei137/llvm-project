//===-- Unittests for memmove ---------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "hdr/signal_macros.h"
#include "src/__support/macros/config.h"
#include "src/string/memmove.h"

#include "memory_utils/memory_check_utils.h"
#include "src/__support/CPP/span.h"
#include "test/UnitTest/MemoryMatcher.h"
#include "test/UnitTest/Test.h"

using LIBC_NAMESPACE::cpp::array;
using LIBC_NAMESPACE::cpp::span;

namespace LIBC_NAMESPACE_DECL {

TEST(LlvmLibcMemmoveTest, MoveZeroByte) {
  char Buffer[] = {'a', 'b', 'y', 'z'};
  const char Expected[] = {'a', 'b', 'y', 'z'};
  void *const Dst = Buffer;
  void *const Ret = LIBC_NAMESPACE::memmove(Dst, Buffer + 2, 0);
  EXPECT_EQ(Ret, Dst);
  ASSERT_MEM_EQ(Buffer, testing::MemoryView(Expected));
}

TEST(LlvmLibcMemmoveTest, DstAndSrcPointToSameAddress) {
  char Buffer[] = {'a', 'b'};
  const char Expected[] = {'a', 'b'};
  void *const Dst = Buffer;
  void *const Ret = LIBC_NAMESPACE::memmove(Dst, Buffer, 1);
  EXPECT_EQ(Ret, Dst);
  ASSERT_MEM_EQ(Buffer, testing::MemoryView(Expected));
}

TEST(LlvmLibcMemmoveTest, DstStartsBeforeSrc) {
  // Set boundary at beginning and end for not overstepping when
  // copy forward or backward.
  char Buffer[] = {'z', 'a', 'b', 'c', 'z'};
  const char Expected[] = {'z', 'b', 'c', 'c', 'z'};
  void *const Dst = Buffer + 1;
  void *const Ret = LIBC_NAMESPACE::memmove(Dst, Buffer + 2, 2);
  EXPECT_EQ(Ret, Dst);
  ASSERT_MEM_EQ(Buffer, testing::MemoryView(Expected));
}

TEST(LlvmLibcMemmoveTest, DstStartsAfterSrc) {
  char Buffer[] = {'z', 'a', 'b', 'c', 'z'};
  const char Expected[] = {'z', 'a', 'a', 'b', 'z'};
  void *const Dst = Buffer + 2;
  void *const Ret = LIBC_NAMESPACE::memmove(Dst, Buffer + 1, 2);
  EXPECT_EQ(Ret, Dst);
  ASSERT_MEM_EQ(Buffer, testing::MemoryView(Expected));
}

// e.g. `Dst` follow `src`.
// str: [abcdefghij]
//      [__src_____]
//      [_____Dst__]
TEST(LlvmLibcMemmoveTest, SrcFollowDst) {
  char Buffer[] = {'z', 'a', 'b', 'z'};
  const char Expected[] = {'z', 'b', 'b', 'z'};
  void *const Dst = Buffer + 1;
  void *const Ret = LIBC_NAMESPACE::memmove(Dst, Buffer + 2, 1);
  EXPECT_EQ(Ret, Dst);
  ASSERT_MEM_EQ(Buffer, testing::MemoryView(Expected));
}

TEST(LlvmLibcMemmoveTest, DstFollowSrc) {
  char Buffer[] = {'z', 'a', 'b', 'z'};
  const char Expected[] = {'z', 'a', 'a', 'z'};
  void *const Dst = Buffer + 2;
  void *const Ret = LIBC_NAMESPACE::memmove(Dst, Buffer + 1, 1);
  EXPECT_EQ(Ret, Dst);
  ASSERT_MEM_EQ(Buffer, testing::MemoryView(Expected));
}

// Adapt CheckMemmove signature to op implementation signatures.
static inline void Adaptor(cpp::span<char> dst, cpp::span<char> src,
                           size_t size) {
  LIBC_NAMESPACE::memmove(dst.begin(), src.begin(), size);
}

TEST(LlvmLibcMemmoveTest, SizeSweep) {
  static constexpr int kMaxSize = 400;
  static constexpr int kDenseOverlap = 15;
  using LargeBuffer = array<char, 2 * kMaxSize + 1>;
  LargeBuffer Buffer;
  Randomize(Buffer);
  for (int Size = 0; Size < kMaxSize; ++Size)
    for (int Overlap = -1; Overlap < Size;) {
      ASSERT_TRUE(
          CheckMemmove<Adaptor>(Buffer, static_cast<size_t>(Size), Overlap));
      // Prevent quadratic behavior by skipping offset above kDenseOverlap.
      if (Overlap > kDenseOverlap)
        Overlap *= 2;
      else
        ++Overlap;
    }
}

#if defined(LIBC_ADD_NULL_CHECKS)

TEST(LlvmLibcMemmoveTest, CrashOnNullPtr) {
  ASSERT_DEATH([]() { LIBC_NAMESPACE::memmove(nullptr, nullptr, 2); },
               WITH_SIGNAL(-1));
}

#endif // LIBC_ADD_NULL_CHECKS

} // namespace LIBC_NAMESPACE_DECL
