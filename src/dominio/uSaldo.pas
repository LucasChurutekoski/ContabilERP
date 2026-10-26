unit uSaldo;

{ Saldo de uma conta: diferenca entre debitos e creditos, do lado maior.
  E um "record com metodos": um valor simples, sem banco e sem tela }

interface

type
  TSaldo = record
    Debitos: Currency;
    Creditos: Currency;

    class function Calcular(const ADebitos, ACreditos: Currency): TSaldo; static;

    function Valor: Currency;                            // sempre >= 0
    function Lado: Char;                                 // 'D', 'C' ou ' ' (zerado)
    function Invertido(const ANatureza: Char): Boolean;  // saldo do lado oposto a natureza
    function Texto: string;                              // ex.: '13.500,00 D'
  end;

implementation

uses
  System.SysUtils;

class function TSaldo.Calcular(const ADebitos, ACreditos: Currency): TSaldo;
begin
  Result.Debitos := ADebitos;
  Result.Creditos := ACreditos;
end;

function TSaldo.Valor: Currency;
begin
  Result := Abs(Debitos - Creditos);
end;

function TSaldo.Lado: Char;
begin
  if Debitos > Creditos then
    Result := 'D'
  else if Creditos > Debitos then
    Result := 'C'
  else
    Result := ' ';
end;

function TSaldo.Invertido(const ANatureza: Char): Boolean;
begin
  // Ex.: Bancos (natureza D) com saldo credor = conta "estourada"
  Result := (Lado <> ' ') and (Lado <> ANatureza);
end;

function TSaldo.Texto: string;
begin
  if Lado = ' ' then
    Result := FormatFloat('#,##0.00', 0)
  else
    Result := FormatFloat('#,##0.00', Valor) + ' ' + Lado;
end;

end.
