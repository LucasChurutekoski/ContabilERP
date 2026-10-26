unit uDocumento;

{ CPF e CNPJ: mascara progressiva (enquanto digita) e validacao dos
  digitos verificadores (modulo 11). Regra pura, sem tela e sem banco. }

interface

function SomenteDigitos(const ATexto: string): string;

// Formata ate 11 digitos como CPF (000.000.000-00) e de 12 a 14 como CNPJ (00.000.000/0000-00)
function FormatarDocumento(const ADigitos: string): string;

// True se tiver 11 digitos (CPF) ou 14 (CNPJ) com os digitos verificadores corretos
function DocumentoValido(const ADigitos: string): Boolean;

implementation

uses
  System.SysUtils;

function SomenteDigitos(const ATexto: string): string;
var
  C: Char;
begin
  Result := '';
  for C in ATexto do
    if CharInSet(C, ['0'..'9']) then
      Result := Result + C;
end;

function AplicarMascara(const ADigitos, AMascara: string): string;
var
  I, D: Integer;
begin
  // Percorre a mascara: '#' recebe o proximo digito, o resto e separador
  Result := '';
  D := 1;
  for I := 1 to Length(AMascara) do
  begin
    if D > Length(ADigitos) then
      Break;
    if AMascara[I] = '#' then
    begin
      Result := Result + ADigitos[D];
      Inc(D);
    end
    else
      Result := Result + AMascara[I];
  end;
end;

function FormatarDocumento(const ADigitos: string): string;
begin
  if Length(ADigitos) <= 11 then
    Result := AplicarMascara(ADigitos, '###.###.###-##')
  else
    Result := AplicarMascara(Copy(ADigitos, 1, 14), '##.###.###/####-##');
end;

function TodosIguais(const ADigitos: string): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 2 to Length(ADigitos) do
    if ADigitos[I] <> ADigitos[1] then
      Exit(False);
end;

function DigitoCPF(const ABase: string): Char;
var
  I, Soma, Resto: Integer;
begin
  // Pesos decrescentes: 10..2 para o 1o digito, 11..2 para o 2o
  Soma := 0;
  for I := 1 to Length(ABase) do
    Soma := Soma + StrToInt(ABase[I]) * (Length(ABase) + 2 - I);
  Resto := (Soma * 10) mod 11;
  if Resto = 10 then
    Resto := 0;
  Result := Char(Ord('0') + Resto);
end;

function DigitoCNPJ(const ABase: string): Char;
const
  PESOS = '6543298765432'; // os 12 ultimos para o 1o digito, os 13 para o 2o
var
  I, Inicio, Soma, Resto: Integer;
begin
  Soma := 0;
  Inicio := Length(PESOS) - Length(ABase) + 1;
  for I := 1 to Length(ABase) do
    Soma := Soma + StrToInt(ABase[I]) * StrToInt(PESOS[Inicio + I - 1]);
  Resto := Soma mod 11;
  if Resto < 2 then
    Result := '0'
  else
    Result := Char(Ord('0') + 11 - Resto);
end;

function DocumentoValido(const ADigitos: string): Boolean;
var
  Base: string;
begin
  Result := False;
  if TodosIguais(ADigitos) then
    Exit; // 111.111.111-11 passa no calculo, mas nao e valido

  if Length(ADigitos) = 11 then
  begin
    Base := Copy(ADigitos, 1, 9);
    Base := Base + DigitoCPF(Base);
    Base := Base + DigitoCPF(Base);
    Result := Base = ADigitos;
  end
  else if Length(ADigitos) = 14 then
  begin
    Base := Copy(ADigitos, 1, 12);
    Base := Base + DigitoCNPJ(Base);
    Base := Base + DigitoCNPJ(Base);
    Result := Base = ADigitos;
  end;
end;

end.
