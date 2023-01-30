unit Fnc_Utils;

interface

uses
  Vcl.Graphics, Winapi.Windows, IdHashMessageDigest, System.SysUtils,
  System.StrUtils, System.Classes;

function HexToColor(aHex: string): TColor;

function Iff(Condicao: Boolean): Boolean;

function AddZero(aValue: string): string; overload;

function AddZero(aValue: Integer): string; overload;

function CopyReverse(S: string; Index, Count: Integer): string;

function StringToMd5(aText: string): string;

function IsEmpty(aValue: string): Boolean;

function StrMultiReplace(Word: string; OldChars, Newchars: array of Char; ReplaceAll: Boolean = True; IgnoreCase: Boolean = False): string; overload;

function StrMultiReplace(aText: string; OldChars, Newchars: array of string; ReplaceAll: Boolean = True; IgnoreCase: Boolean = False): string; overload;

function PercentualDesconto(aValor, aDesconto: Double): Double;

function ValorDesconto(aPercentual, aValue: Double): Double;

function ReturnFormatedDate(aDate, aFormat: string): TDateTime;

implementation

function StringToMd5(aText: string): string;
var
  Hashmd5: TIdHashMessageDigest5;
begin
  Hashmd5 := TIdHashMessageDigest5.Create;
  try
    Result := (Hashmd5.HashStringAsHex(aText));
  finally
    Hashmd5.Free;
  end;
end;

function IsEmpty(aValue: string): Boolean;
begin
  Result := False;
  if Trim(aValue) = '' then
    Result := True;
end;

function HexToColor(aHex: string): TColor;
var
  vColor: string;
begin
  vColor := StringReplace(aHex, '#', '', []);
  Result := RGB(StrToInt('$' + Copy(vColor, 1, 2)), StrToInt('$' + Copy(vColor, 3, 2)), StrToInt('$' + Copy(vColor, 5, 2)));
end;

function Iff(Condicao: Boolean): Boolean;
begin
  Result := False;
  if Condicao then
    Result := True;
end;

function AddZero(aValue: string): string;
var
  vBase: string;
  vCount: Integer;
begin
  vBase := '0000';
  vCount := Length(vBase) - Length(aValue);
  Result := '#' + Copy(vBase, 1, vCount) + aValue;
end;

function AddZero(aValue: Integer): string;
var
  vBase: string;
  vCount: Integer;
begin
  vBase := '0000';
  vCount := Length(vBase) - Length(aValue.ToString);
  Result := '#' + Copy(vBase, 1, vCount) + aValue.ToString;
end;

function CopyReverse(S: string; Index, Count: Integer): string;
begin
  Result := ReverseString(S);
  Result := Copy(Result, Index, Count);
  Result := ReverseString(Result);
end;

function StrMultiReplace(Word: string; OldChars, Newchars: array of Char; ReplaceAll: Boolean = True; IgnoreCase: Boolean = False): string;
var
  I: Integer;
  Flags: TReplaceFlags;
begin
  Assert(Length(OldChars) = Length(Newchars));
  Result := Word;
  for I := 0 to High(OldChars) do
  begin
    if ReplaceAll then
      Flags := [rfReplaceAll];
    if IgnoreCase then
      Flags := Flags + [rfIgnoreCase];

    Result := StringReplace(Result, OldChars[I], Newchars[I], Flags);
  end;
end;

function StrMultiReplace(aText: string; OldChars, Newchars: array of string; ReplaceAll: Boolean = True; IgnoreCase: Boolean = False): string;
var
  I: Integer;
  Flags: TReplaceFlags;
begin
  Assert(Length(OldChars) = Length(Newchars));
  Result := aText;
  for I := 0 to High(OldChars) do
  begin
    if ReplaceAll then
      Flags := [rfReplaceAll];
    if IgnoreCase then
      Flags := Flags + [rfIgnoreCase];

    Result := StringReplace(Result, OldChars[I], Newchars[I], Flags);
  end;
end;

function PercentualDesconto(aValor, aDesconto: Double): Double;
var
  vPercentual, vPer: Double;
begin
  vPercentual := aValor - (aValor - aDesconto);
  vPercentual := vPercentual / aValor;
  vPercentual := vPercentual * 100;
  vPer := vPercentual;
  Result := vPercentual;
end;

function ValorDesconto(aPercentual, aValue: Double): Double;
var
  aValorDesconto: Double;
begin
  aValorDesconto := aPercentual * aValue;
  Result := aValorDesconto / 100;
end;

function ReturnFormatedDate(aDate, aFormat: string): TDateTime;
var
  lDate: string;
  lDateTime: TDateTime;
  lFormato: TFormatSettings;
begin
  lDate := StrMultiReplace(aDate, ['-'], ['/']);
  lFormato.ShortDateFormat := aFormat;
  lDateTime := StrToDateTime(lDate);
  lDate := FormatDateTime(aFormat, lDateTime);
  Result := StrToDateTime(lDate,lFormato);
end;

end.

