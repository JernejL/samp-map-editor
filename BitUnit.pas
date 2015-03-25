{**********************************************************************}
{*                                                                    *}
{* Bit Unit, a unit for easy bit manipulation                         *}
{* Author:                                                            *}
{* Theodoros Bebekis                                                  *}
{* Thessaloniki, Greece                                               *}
{* bebekis@mail.otenet.gr                                             *}
{*                                                                    *}
{* Delfi's 2003 update                                                *}
{* 3 new functions:                                                   *}
{* setbit, getbit, bitcopy                                            *}
{* delfi_2_4@yahoo.com                                                *}
{*                                                                    *}
{**********************************************************************}

unit BitUnit;

interface

function IsBitSet(const       i, Nth: integer): boolean;
function BitToOn(const        i, Nth: integer): integer;
function BitToOff(const       i, Nth: integer): integer;
function BitToggle(const      i, Nth: integer): integer;
function ReverseAllBits(const i: integer): integer;

// new
function bitcopy(source, dest, start, count, deststart: integer): integer;
function getbit(source, index: integer): boolean;
function setbit(source, index: integer; to_: boolean): integer;


implementation

// IsBitSet
//  returns True if a bit is ON (1)
//  Nth can have any bit order value in [0..31]

function IsBitSet(const i, Nth: integer): boolean;
begin
Result:= (i and (1 shl Nth)) <> 0;
end;


// BitToOn
// sets a bit in number to on and returns new number

function BitToOn(const i, Nth: integer): integer;
begin
if not IsBitSet(i, Nth)
then Result := i or (1 shl Nth) else Result:=i;
end;

// BitToOff
// sets a bit in number to off and returns new number
function BitToOff(const i, Nth: integer): integer;
begin
  if IsBitSet(i, Nth)
  then Result := i and ((1 shl Nth) xor $FFFFFFFF)
  else Result:=i;
end;

// BitToggle
// toggles the state of a bit

function BitToggle(const i, Nth: integer): integer;
begin
Result := i xor (1 shl Nth);
end;

// ReverseAllBits
// reverses all bits (all zeroes to ones and ones to zeroes)

function ReverseAllBits(const i: integer): integer;
var N:integer;
begin
Result:= i;
for N:=0 to 31 do  Result:= Result xor (1 shl N);
end;

// Added Delfi's functions

// setbit
//

function setbit(source, index: integer; to_: boolean): integer;
begin
case to_ of
true: result:= bittoon(source, index);
false: result:= bittooff(source, index);
end;
end;

// getbit
// same as isbitset with a name that makes more sense in the code where you use it.

function getbit(source, index: integer): boolean;
begin
Result:= (source and (1 shl index)) <> 0;
end;

// bitcopy
// copies a range of bits from source to dest

function bitcopy(source, dest, start, count, deststart: integer): integer;
var
N: integer;
begin
result:= dest;

 for n:= start to start + count do begin
 dest:= setbit(dest, deststart + n, getbit(source, n));
// if isbitset(source, n) then dest:= bittoon(dest, deststart + n) else dest:= bittooff(dest, deststart + n);
 end;

result:= dest;
end;

end.
