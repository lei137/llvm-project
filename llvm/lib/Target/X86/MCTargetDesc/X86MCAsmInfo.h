//===-- X86MCAsmInfo.h - X86 asm properties --------------------*- C++ -*--===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the declaration of the X86MCAsmInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_X86_MCTARGETDESC_X86MCASMINFO_H
#define LLVM_LIB_TARGET_X86_MCTARGETDESC_X86MCASMINFO_H

#include "MCTargetDesc/X86MCExpr.h"
#include "llvm/MC/MCAsmInfoCOFF.h"
#include "llvm/MC/MCAsmInfoDarwin.h"
#include "llvm/MC/MCAsmInfoELF.h"
#include "llvm/MC/MCExpr.h"

namespace llvm {
class Triple;

class X86MCAsmInfoDarwin : public MCAsmInfoDarwin {
  virtual void anchor();

public:
  explicit X86MCAsmInfoDarwin(const Triple &Triple);
};

struct X86_64MCAsmInfoDarwin : public X86MCAsmInfoDarwin {
  explicit X86_64MCAsmInfoDarwin(const Triple &Triple);
  const MCExpr *
  getExprForPersonalitySymbol(const MCSymbol *Sym, unsigned Encoding,
                              MCStreamer &Streamer) const override;
};

class X86ELFMCAsmInfo : public MCAsmInfoELF {
  void anchor() override;

public:
  explicit X86ELFMCAsmInfo(const Triple &Triple);
};

class X86MCAsmInfoMicrosoft : public MCAsmInfoMicrosoft {
  void anchor() override;

public:
  explicit X86MCAsmInfoMicrosoft(const Triple &Triple);
};

class X86MCAsmInfoMicrosoftMASM : public X86MCAsmInfoMicrosoft {
  void anchor() override;

public:
  explicit X86MCAsmInfoMicrosoftMASM(const Triple &Triple);
};

class X86MCAsmInfoGNUCOFF : public MCAsmInfoGNUCOFF {
  void anchor() override;

public:
  explicit X86MCAsmInfoGNUCOFF(const Triple &Triple);
};

namespace X86 {
using Specifier = uint16_t;

enum {
  S_None,
  S_COFF_SECREL,

  S_ABS8 = MCSymbolRefExpr::FirstTargetSpecifier,
  S_DTPOFF,
  S_DTPREL,
  S_GOT,
  S_GOTENT,
  S_GOTNTPOFF,
  S_GOTOFF,
  S_GOTPCREL,
  S_GOTPCREL_NORELAX,
  S_GOTREL,
  S_GOTTPOFF,
  S_INDNTPOFF,
  S_NTPOFF,
  S_PCREL,
  S_PLT,
  S_PLTOFF,
  S_SIZE,
  S_TLSCALL,
  S_TLSDESC,
  S_TLSGD,
  S_TLSLD,
  S_TLSLDM,
  S_TLVP,
  S_TLVPPAGE,
  S_TLVPPAGEOFF,
  S_TPOFF,
};
} // namespace X86
} // namespace llvm

#endif
