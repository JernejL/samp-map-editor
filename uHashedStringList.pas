{******************************************************************************}
{                                                                              }
{   Unit: uHashedStringList.pas                                                }
{                                                                              }
{   Scope: TStringList replacement                                             }
{                                                                              }
{   Info: implements almost all methods of TStringList, easily extendable      }
{                                                                              }
{   Copyright© Dorin Duminica                                                  }
{                                                                              }
{******************************************************************************}
unit uHashedStringList;

interface

uses
  SysUtils,
  Classes;

type
  PStringHashRec = ^TStringHashRec;
  TStringHashRec = record
    Value: String;
    HashSensitive: Integer;
    HashInsensitive: Integer;
  end;// TStringHashRec = record

  PStringRec = ^TStringRec;
  TStringRec = record
    StringValue: PStringHashRec;
    Value: PStringHashRec;
    ObjectRef: TObject;
  end;// TStringEntry = record

type
  TurboHashedStringList = class
  private
    FList: TList;
    function GetValue(Name: String; bCaseSensitive: Boolean): String;
    procedure SetValue(Name: String; bCaseSensitive: Boolean;
      const Value: String);
    function GetItem(Index: Integer): PStringRec;
    function GetText(Index: Integer): String;
    procedure SetItem(Index: Integer; const Value: PStringRec);
    procedure SetText(Index: Integer; const Value: String);
  public
    constructor Create;
    destructor Destroy; OVERRIDE;
  public
    function Add(const s: String; const Value: String = ''): Integer; OVERLOAD;
    function Add(const s: String; AObject: TObject): Integer; OVERLOAD;
    function StringExists(const s: String): Boolean; OVERLOAD;
    function Append(const s: String; const Value: String = ''): Integer; OVERLOAD;
    function Append(const s: String; AObject: TObject): Integer; OVERLOAD;
    function StringExists(const s: String; var atIndex: Integer): Boolean; OVERLOAD;
    function Count: Integer;
    function IndexOfName(const s: String): Integer; OVERLOAD;
    function IndexOfName(const s: String; bCaseSensitive: Boolean): Integer; OVERLOAD;
    function IndexOfValue(const s: String): Integer; OVERLOAD;
    function IndexOfValue(const s: String; bCaseSensitive: Boolean): Integer; OVERLOAD;
    function StringExists(const s: String; var atIndex: Integer;
      const bCaseSensitive: Boolean): Boolean; OVERLOAD;
    function ValueExists(const s: String): Boolean; OVERLOAD;
    function ValueExists(const s: String; var atIndex: Integer): Boolean; OVERLOAD;
    function ValueExists(const s: String; var atIndex: Integer;
      const bCaseSensitive: Boolean): Boolean; OVERLOAD;
    procedure Clear;
    procedure Delete(Index: Integer; const bFreeObject: Boolean = False);
    procedure Exchange(Index1, Index2: Integer);
    procedure Insert(Index: Integer; const s: String; const Value: String = ''); OVERLOAD;
    procedure Insert(Index: Integer; const s: String; AObject: TObject); OVERLOAD;
  public
    property Values[Name: String; bCaseSensitive: Boolean]: String
      read GetValue write SetValue;
    property Items[Index: Integer]: PStringRec
      read GetItem write SetItem;
    property Strings[Index: Integer]: String
      read GetText write SetText; DEFAULT;
  end;// TurboHashedStringList = class

implementation

uses Math;

function HashStringInsensitive(const Value: string): Integer;
var
  Index : Integer;
begin
  Result := 0;;
  for Index := 1 to Length(Value) do
    Result := ((Result shl 7) or (Result shr 25)) + Ord(UpCase(Value[Index]));
end;// function HashStringInsensitive(const Value: string): Integer;

function HashStringSensitive(const Value: string): Integer;
var
  Index : Integer;
begin
  Result := 0;;
  for Index := 1 to Length(Value) do
    Result := ((Result shl 7) or (Result shr 25)) + Ord(Value[Index]);
end;// function HashStringSensitive(const Value: string): Integer;

{ TurboHashedStringList }

function TurboHashedStringList.Add(const s, Value: String): Integer;
var
  StringData: PStringRec;
begin
  New(StringData);
  New(StringData.StringValue);
  New(StringData.Value);
  StringData.StringValue.Value := s;
  StringData.StringValue.HashSensitive := HashStringSensitive(s);
  StringData.StringValue.HashInsensitive := HashStringInsensitive(s);
  StringData.Value.Value := Value;
  StringData.Value.HashSensitive := HashStringSensitive(Value);
  StringData.Value.HashInsensitive := HashStringInsensitive(Value);
  Result := FList.Add(StringData)
end;// function TurboHashedStringList.Add(const s, Value: String): Integer;

function TurboHashedStringList.Add(const s: String;
  AObject: TObject): Integer;
begin
  Result := Add(s);
  PStringRec(FList[Result]).ObjectRef := AObject;
end;// function TurboHashedStringList.Add(const s: String;

function TurboHashedStringList.Append(const s, Value: String): Integer;
begin
  Result := Add(s, Value);
end;// function TurboHashedStringList.Append(const s, Value: String): Integer;

function TurboHashedStringList.Append(const s: String;
  AObject: TObject): Integer;
begin
  Result := Add(s, AObject);
end;// function TurboHashedStringList.Append(const s: String;

procedure TurboHashedStringList.Clear;
var
  Index: Integer;
  StringData: PStringRec;
begin
  for Index := FList.Count -1 downto 0 do
    Delete(Index);
end;// procedure TurboHashedStringList.Clear;

function TurboHashedStringList.Count: Integer;
begin
  Result := FList.Count;
end;// function TurboHashedStringList.Count: Integer;

constructor TurboHashedStringList.Create;
begin
  FList := TList.Create;
end;// constructor TurboHashedStringList.Create;

procedure TurboHashedStringList.Delete(Index: Integer;
  const bFreeObject: Boolean);
var
  StringData: PStringRec;
  Obj: TObject;
begin
  StringData := FList[Index];
  if bFreeObject then begin
    Obj := StringData.ObjectRef;
    FreeAndNil(Obj);
  end;// if bFreeObject then begin
  Dispose(StringData.StringValue);
  Dispose(StringData.Value);
  Dispose(StringData);
  FList.Delete(Index);
end;// procedure TurboHashedStringList.Delete(Index: Integer;

destructor TurboHashedStringList.Destroy;
begin
  Clear;
  FreeAndNil(FList);
end;// destructor TurboHashedStringList.Destroy;

procedure TurboHashedStringList.Exchange(Index1, Index2: Integer);
var
  Item1: PStringRec;
  Item2: PStringRec;
  TempI: PStringRec;
begin
  Item1 := FList[Index1];
  Item2 := FList[Index2];
  TempI := Item1;
  Item1 := Item2;
  Item2 := TempI;
end;// procedure TurboHashedStringList.Exchange(Index1, Index2: Integer);

function TurboHashedStringList.GetItem(Index: Integer): PStringRec;
begin
  Result := FList[Index];
end;// function TurboHashedStringList.GetItem(Index: Integer): PStringRec;

function TurboHashedStringList.GetText(Index: Integer): String;
begin
  Result := PStringRec(FList[Index]).StringValue.Value;
end;// function TurboHashedStringList.GetText(Index: Integer): String;

function TurboHashedStringList.GetValue(Name: String;
  bCaseSensitive: Boolean): String;
var
  Index: Integer;
begin
  Result := EmptyStr;
  if StringExists(Name, Index, bCaseSensitive) then
    Result := PStringRec(FList[Index]).Value.Value;
end;// function TurboHashedStringList.GetValue(Name: String;

procedure TurboHashedStringList.Insert(Index: Integer; const s, Value: String);
begin
  Add(s, Value);
  Exchange(Index, FList.Count -1);
end;// procedure TurboHashedStringList.Insert(Index: Integer; const s, Value: String);

function TurboHashedStringList.IndexOfName(const s: String): Integer;
begin
  Result := IndexOfName(s, False);
end;// function TurboHashedStringList.IndexOfName(const s: String): Integer;

function TurboHashedStringList.IndexOfName(const s: String;
  bCaseSensitive: Boolean): Integer;
begin
  StringExists(s, Result, bCaseSensitive);
end;// function TurboHashedStringList.IndexOfName(const s: String;

function TurboHashedStringList.IndexOfValue(const s: String): Integer;
begin
  Result := IndexOfValue(s, False);
end;// function TurboHashedStringList.IndexOfValue(const s: String): Integer;

function TurboHashedStringList.IndexOfValue(const s: String;
  bCaseSensitive: Boolean): Integer;
begin
  ValueExists(s, Result, bCaseSensitive);
end;// function TurboHashedStringList.IndexOfValue(const s: String;

procedure TurboHashedStringList.Insert(Index: Integer; const s: String;
  AObject: TObject);
begin
  Add(s, AObject);
  Exchange(Index, FList.Count -1);
end;// procedure TurboHashedStringList.Insert(Index: Integer; const s: String;

procedure TurboHashedStringList.SetItem(Index: Integer;
  const Value: PStringRec);
var
  StringData: PStringRec;
begin
  StringData := FList[Index];
  Dispose(StringData);
  FList[Index] := Value;
end;// procedure TurboHashedStringList.SetItem(Index: Integer;

procedure TurboHashedStringList.SetText(Index: Integer;
  const Value: String);
var
  StringData: PStringRec;
begin
  StringData := FList[Index];
  StringData.StringValue.Value := Value;
  StringData.StringValue.HashSensitive := HashStringSensitive(Value);
  StringData.StringValue.HashInsensitive := HashStringInsensitive(Value);
end;// procedure TurboHashedStringList.SetText(Index: Integer;

procedure TurboHashedStringList.SetValue(Name: String;
  bCaseSensitive: Boolean; const Value: String);
var
  Index: Integer;
  StringData: PStringRec;
begin
  if StringExists(Name, Index, bCaseSensitive) then begin
    StringData := FList[Index];
    StringData.Value.Value := Value;
    StringData.Value.HashSensitive := HashStringSensitive(Value);
    StringData.Value.HashInsensitive := HashStringInsensitive(Value); 
  end;// if StringExists(Name, Index, bCaseSensitive) then begin
end;// procedure TurboHashedStringList.SetValue(Name: String;

function TurboHashedStringList.StringExists(const s: String;
  var atIndex: Integer; const bCaseSensitive: Boolean): Boolean;
var
  Index: Integer;
  Hash: Integer;
begin
  Result := True;
  if bCaseSensitive then begin
    Hash := HashStringSensitive(s);
    for Index := 0 to FList.Count -1 do
      if PStringRec(FList[Index]).StringValue.HashSensitive = Hash then begin
        atIndex := Index;
        Exit;
      end;// if PStringRec(FList[Index]).StringValue.HashSensitive = Hash then begin
  end else begin
    Hash := HashStringInsensitive(s);
    for Index := 0 to FList.Count -1 do
      if PStringRec(FList[Index]).StringValue.HashInsensitive = Hash then begin
        atIndex := Index;
        Exit;
      end;// if PStringRec(FList[Index]).StringValue.HashInsensitive = Hash then begin
  end;// if bCaseSensitive then begin
  Result := False;
end;// function TurboHashedStringList.StringExists(const s: String;

function TurboHashedStringList.StringExists(const s: String): Boolean;
var
  Index: Integer;
begin
  Result := StringExists(s, Index);
end;// function TurboHashedStringList.StringExists(const s: String): Boolean;

function TurboHashedStringList.StringExists(const s: String;
  var atIndex: Integer): Boolean;
begin
  Result := StringExists(s, atIndex, False);
end;// function TurboHashedStringList.StringExists(const s: String;

function TurboHashedStringList.ValueExists(const s: String;
  var atIndex: Integer; const bCaseSensitive: Boolean): Boolean;
var
  Index: Integer;
  Hash: Integer;
begin
  Result := True;
  if bCaseSensitive then begin
    Hash := HashStringSensitive(s);
    for Index := 0 to FList.Count -1 do
      if PStringRec(FList[Index]).Value.HashSensitive = Hash then begin
        atIndex := Index;
        Exit;
      end;// if PStringRec(FList[Index]).Value.HashSensitive = Hash then begin
  end else begin
    Hash := HashStringInsensitive(s);
    for Index := 0 to FList.Count -1 do
      if PStringRec(FList[Index]).Value.HashInsensitive = Hash then begin
        atIndex := Index;
        Exit;
      end;// if PStringRec(FList[Index]).Value.HashInsensitive = Hash then begin
  end;// if bCaseSensitive then begin
  Result := False;
end;// function TurboHashedStringList.ValueExists(const s: String;

function TurboHashedStringList.ValueExists(const s: String;
  var atIndex: Integer): Boolean;
begin
  Result := ValueExists(s, atIndex, False);
end;// function TurboHashedStringList.ValueExists(const s: String;

function TurboHashedStringList.ValueExists(const s: String): Boolean;
var
  Index: Integer;
begin
  Result := ValueExists(s, Index);
end;// function TurboHashedStringList.ValueExists(const s: String): Boolean;

end.// unit uHashedStringList;

