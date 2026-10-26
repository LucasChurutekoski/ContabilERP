unit uFrmItens;

{ Cadastro de itens (produtos com estoque) e servicos (sem estoque).
  A conta contabil do item define para onde vai o valor nos lancamentos
  automaticos: produto -> conta do Ativo (Estoques); servico tomado -> Despesa;
  servico prestado -> Receita. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFrmItens = class(TForm)
    Navegador: TDBNavigator;
    Grade: TDBGrid;
    PnlEdicao: TPanel;
    LblCodigo: TLabel;
    EdtCodigo: TDBEdit;
    LblDescricao: TLabel;
    EdtDescricao: TDBEdit;
    LblUnidade: TLabel;
    CbUnidade: TDBLookupComboBox;
    BtnUnidades: TButton;
    RgTipo: TDBRadioGroup;
    LblConta: TLabel;
    CbConta: TDBLookupComboBox;
    BtnContas: TButton;
    Qry: TFDQuery;
    Ds: TDataSource;
    QryContas: TFDQuery;
    DsContas: TDataSource;
    QryUnidades: TFDQuery;
    DsUnidades: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure BtnContasClick(Sender: TObject);
    procedure BtnUnidadesClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure QryNewRecord(DataSet: TDataSet);
    procedure QryBeforePost(DataSet: TDataSet);
    procedure QryBeforeDelete(DataSet: TDataSet);
    procedure QryErroBanco(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
  private
    procedure GarantirEdicao;
  public
    class procedure Executar;
  end;

var
  FrmItens: TFrmItens;

implementation

{$R *.dfm}

uses
  uDM, uSessao, uTelaUtil, uFrmContas, uFrmUnidades;

class procedure TFrmItens.Executar;
var
  Form: TFrmItens;
begin
  Sessao.Exigir('CAD_ITENS');
  Form := TFrmItens.Create(nil);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TFrmItens.FormCreate(Sender: TObject);
begin
  // A lista de contas (lookup) abre antes, para o combo ja ter o que mostrar
  QryContas.Connection := DM.Conexao;
  QryContas.Open;
  QryUnidades.Connection := DM.Conexao;
  QryUnidades.Open;
  Qry.Connection := DM.Conexao;
  Qry.Open;
  // O estoquista cadastra itens, mas nao mexe no plano de contas
  BtnContas.Enabled := Sessao.Pode('CAD_CONTAS');
  ConfigurarCadastro(Ds, Grade, EdtCodigo);
end;

procedure TFrmItens.BtnContasClick(Sender: TObject);
var
  IdEscolhido: Integer;
begin
  // Abre o plano de contas ja posicionado na conta atual do item
  IdEscolhido := TFrmContas.Executar(Qry.FieldByName('id_conta').AsInteger);
  QryContas.Refresh; // traz contas criadas ou renomeadas
  // So aplica se a conta escolhida for valida para item (analitica de Ativo/Despesa)
  if QryContas.Locate('id', IdEscolhido, []) and
     (IdEscolhido <> Qry.FieldByName('id_conta').AsInteger) then
  begin
    GarantirEdicao;
    Qry.FieldByName('id_conta').AsInteger := IdEscolhido;
  end;
end;

procedure TFrmItens.GarantirEdicao;
begin
  // Sem item na tela, a escolha vale para um item novo
  if not (Qry.State in dsEditModes) then
    if Qry.IsEmpty then
      Qry.Append
    else
      Qry.Edit;
end;

procedure TFrmItens.BtnUnidadesClick(Sender: TObject);
var
  SiglaEscolhida: string;
begin
  SiglaEscolhida := TFrmUnidades.Executar(Qry.FieldByName('unidade').AsString);
  QryUnidades.Refresh;
  if QryUnidades.Locate('sigla', SiglaEscolhida, []) and
     (SiglaEscolhida <> Qry.FieldByName('unidade').AsString) then
  begin
    GarantirEdicao;
    Qry.FieldByName('unidade').AsString := SiglaEscolhida;
  end;
end;

procedure TFrmItens.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmarAlteracoesPendentes(Qry);
end;

procedure TFrmItens.QryNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('tipo').AsString := 'P';
  DataSet.FieldByName('unidade').AsString := 'UN';
  DataSet.FieldByName('custo_medio_centavos').AsInteger := 0;
  // Sugere a conta Estoques para produtos novos
  DataSet.FieldByName('id_conta').Value := QryContas.Lookup('codigo', '1.1.3.01', 'id');
end;

procedure TFrmItens.QryBeforePost(DataSet: TDataSet);
var
  Grupo: string;
begin
  if Trim(DataSet.FieldByName('codigo').AsString) = '' then
    raise Exception.Create('Informe o código do item.');
  if Trim(DataSet.FieldByName('descricao').AsString) = '' then
    raise Exception.Create('Informe a descrição do item.');
  if DataSet.FieldByName('id_conta').IsNull then
    raise Exception.Create('Escolha a conta contábil do item.');

  // Regra contabil: produto e um bem (Ativo). Servico nao tem estoque:
  // tomado (comprado) vai para Despesa; prestado (vendido) vai para Receita.
  Grupo := VarToStr(QryContas.Lookup('id', DataSet.FieldByName('id_conta').Value, 'grupo'));
  if (DataSet.FieldByName('tipo').AsString = 'P') and (Grupo <> 'A') then
    raise Exception.Create('Produto deve usar uma conta do Ativo (ex.: 1.1.3.01 Estoques).');
  if (DataSet.FieldByName('tipo').AsString = 'S') and (Grupo <> 'D') and (Grupo <> 'R') then
    raise Exception.Create('Serviço deve usar uma conta de Despesa (serviço tomado, ex.: 5.2.03) ' +
      'ou de Receita (serviço prestado, ex.: 4.1.02).');
end;

procedure TFrmItens.QryBeforeDelete(DataSet: TDataSet);
begin
  ConfirmarExclusao;
end;

procedure TFrmItens.QryErroBanco(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
begin
  Action := daAbort;
  ShowMessage(MensagemErroBanco(E));
end;

end.
