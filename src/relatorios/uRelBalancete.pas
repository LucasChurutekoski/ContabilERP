unit uRelBalancete;

{ Balancete de verificacao impresso com FastReport.
  O layout e montado em codigo (sem arquivo .fr3) e os dados vem da MESMA
  consulta da tela (TConsultaService.AbrirBalancete). So esta unit conhece o
  FastReport: se a ferramenta mudar, o resto do sistema nao muda. }

interface

uses
  FireDAC.Comp.Client;

procedure ImprimirBalancete(AConexao: TFDConnection; const AEmitidoPor: string);

implementation

uses
  // frBaseGraphicsTypes: nas versoes recentes do FastReport, TfrxHAlign (haLeft...) mora aqui
  System.SysUtils, Vcl.Graphics, frBaseGraphicsTypes, frxClass, frxDBSet, frxExportPDF, uConsultaService;

const
  LARGURA = 718; // largura util de uma folha A4 retrato, em pixels do FastReport

function Texto(ABanda: TfrxBand; const ATexto: string; AEsquerda, ATopo, ALargura, AAltura: Extended;
  ATamanho: Integer; ANegrito: Boolean; AAlinhamento: TfrxHAlign): TfrxMemoView;
begin
  Result := TfrxMemoView.Create(ABanda);
  Result.CreateUniqueName;
  Result.SetBounds(AEsquerda, ATopo, ALargura, AAltura);
  Result.Text := ATexto;
  Result.Font.Name := 'Arial';
  Result.Font.Size := ATamanho;
  if ANegrito then
    Result.Font.Style := [fsBold];
  Result.HAlign := AAlinhamento;
end;

function CampoTexto(ABanda: TfrxBand; ADados: TfrxDBDataset; const ACampo: string;
  AEsquerda, ALargura: Extended): TfrxMemoView;
begin
  Result := Texto(ABanda, '', AEsquerda, 0, ALargura, 18, 9, False, haLeft);
  Result.DataSet := ADados;
  Result.DataField := ACampo;
end;

function CampoValor(ABanda: TfrxBand; const ACampo: string; AEsquerda: Extended): TfrxMemoView;
begin
  // Os valores vem em centavos: a expressao divide por 100 e o formato poe milhar e decimais
  Result := Texto(ABanda, '[<Balancete."' + ACampo + '"> / 100]', AEsquerda, 0, 90, 18, 9, False, haRight);
  Result.DisplayFormat.Kind := fkNumeric;
  Result.DisplayFormat.FormatStr := '%2.2n';
end;

procedure ImprimirBalancete(AConexao: TFDConnection; const AEmitidoPor: string);
var
  Consulta: TConsultaService;
  Query: TFDQuery;
  Totais: TTotaisBalancete;
  Relatorio: TfrxReport;
  Dados: TfrxDBDataset;
  ExportarPDF: TfrxPDFExport;
  Pagina: TfrxReportPage;
  Banda: TfrxBand;
  Situacao: string;
begin
  Consulta := TConsultaService.Create(AConexao);
  Query := TFDQuery.Create(nil);
  Dados := TfrxDBDataset.Create(nil);
  ExportarPDF := TfrxPDFExport.Create(nil); // criar o componente habilita "Exportar para PDF" no preview
  Relatorio := TfrxReport.Create(nil);
  try
    Consulta.AbrirBalancete(Query);
    Totais := Consulta.TotaisBalancete;

    // Ponte entre o DataSet do Delphi e o relatorio
    Dados.UserName := 'Balancete';
    Dados.DataSet := Query;
    Relatorio.DataSets.Add(Dados);

    Pagina := TfrxReportPage.Create(Relatorio);
    Pagina.CreateUniqueName;
    Pagina.SetDefaults;

    // Titulo: sai uma vez, no topo da primeira pagina
    Banda := TfrxReportTitle.Create(Pagina);
    Banda.CreateUniqueName;
    Banda.Top := 0;
    Banda.Height := 56;
    Texto(Banda, 'Balancete de Verificação', 0, 0, LARGURA, 26, 14, True, haCenter);
    Texto(Banda, 'Contábil ERP  -  emitido em ' + FormatDateTime('dd/mm/yyyy hh:nn', Now) +
      ' por ' + AEmitidoPor, 0, 30, LARGURA, 18, 9, False, haCenter);

    // Cabecalho das colunas: repete em toda pagina
    Banda := TfrxPageHeader.Create(Pagina);
    Banda.CreateUniqueName;
    Banda.Top := 80;
    Banda.Height := 22;
    Texto(Banda, 'Código', 0, 2, 70, 18, 9, True, haLeft);
    Texto(Banda, 'Conta', 75, 2, 260, 18, 9, True, haLeft);
    Texto(Banda, 'Débitos', 340, 2, 90, 18, 9, True, haRight);
    Texto(Banda, 'Créditos', 435, 2, 90, 18, 9, True, haRight);
    Texto(Banda, 'Saldo devedor', 530, 2, 90, 18, 9, True, haRight);
    Texto(Banda, 'Saldo credor', 625, 2, 90, 18, 9, True, haRight);

    // Dados: uma linha por conta do DataSet
    Banda := TfrxMasterData.Create(Pagina);
    Banda.CreateUniqueName;
    Banda.Top := 130;
    Banda.Height := 18;
    TfrxMasterData(Banda).DataSet := Dados;
    CampoTexto(Banda, Dados, 'codigo', 0, 70);
    CampoTexto(Banda, Dados, 'nome', 75, 260);
    CampoValor(Banda, 'debitos_c', 340);
    CampoValor(Banda, 'creditos_c', 435);
    CampoValor(Banda, 'saldo_devedor_c', 530);
    CampoValor(Banda, 'saldo_credor_c', 625);

    // Resumo: sai uma vez, no fim, com os totais calculados pelo servico
    Banda := TfrxReportSummary.Create(Pagina);
    Banda.CreateUniqueName;
    Banda.Top := 180;
    Banda.Height := 56;
    Texto(Banda, 'TOTAIS', 75, 6, 260, 18, 10, True, haLeft);
    Texto(Banda, FormatFloat('#,##0.00', Totais.Devedor), 530, 6, 90, 18, 10, True, haRight);
    Texto(Banda, FormatFloat('#,##0.00', Totais.Credor), 625, 6, 90, 18, 10, True, haRight);
    if Totais.Fecha then
      Situacao := 'Balancete fechado: soma dos saldos devedores = soma dos saldos credores'
    else
      Situacao := 'ATENÇÃO: o balancete não fechou';
    Texto(Banda, Situacao, 0, 32, LARGURA, 18, 10, True, haCenter);

    Relatorio.PrepareReport;
    Relatorio.ShowPreparedReport; // janela de visualizacao: imprimir, exportar PDF...
  finally
    Relatorio.Free;
    ExportarPDF.Free;
    Dados.Free;
    Query.Free;
    Consulta.Free;
  end;
end;

end.
