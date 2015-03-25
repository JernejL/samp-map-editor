{$define TDC}

{$define Delphi}

{$ifdef fpc}
{$undef Delphi}
{$endif}

// delphi

{$ifdef Delphi}
{$B-} // enables short-circuit bitwise evaluation.

{.$A+}
{.$DEBUGINFO OFF}    // will prevent placing Debug info to your code.
{.$LOCALSYMBOLS OFF} // will prevent placing local symbols to your code.
{.$O+}               // optimize code, remove unnecessary variables etc.
{.$STACKFRAMES OFF}
{.$REFERENCEINFO OFF}
{.$ASSERTIONS OFF}
{.$Q-} // removes code for Integer overflow-checking.
{.$R-} // removes code for range checking of strings, arrays etc.
{.$S-} // removes code for stack-checking.
{.$Y-} // will prevent placing smybol information to your code.
{.$WRITEABLECONST OFF} // Writeable typed constants OFF
{.$IOCHECKS OFF}
{.$REFERENCEINFO OFF}
{.$LOCALSYMBOLS OFF}
{.$TYPEINFO OFF}

{$SAFEDIVIDE OFF} // FDIV bug on old pentiums is repaired already by OS
{$endif}

// freepascal

{$ifdef fpc}

// switch to delphi compatible mode
{$asmmode intel}
{$mode delphi}

{$DEBUGINFO OFF}    // will prevent placing Debug info to your code.
{.$LOCALSYMBOLS OFF} // will prevent placing local symbols to your code.
{$ASSERTIONS OFF}
{$Q-} // removes code for Integer overflow-checking.
{$R-} // removes code for range checking of strings, arrays etc.
{$S-} // removes code for stack-checking.
{.$Y-} // will prevent placing smybol information to your code.
{$B-} // enables short-circuit bitwise evaluation. // ??
{$WRITEABLECONST OFF} // Writeable typed constants OFF
{$IOCHECKS OFF}
{.$REFERENCEINFO OFF}
{.$LOCALSYMBOLS OFF}
{$TYPEINFO OFF}
{$M+}
{$endif}
