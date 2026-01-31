unit Tela.ConsultaPais;

interface

uses
  Servico.Pais, Modelo.Pais, ShellAPI,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.NumberBox,
  Vcl.ExtCtrls, Vcl.VirtualImage, Vcl.Imaging.pngimage, Vcl.OleCtrls, SHDocVw,
  Winapi.WebView2, Winapi.ActiveX, Vcl.Edge;

type
  TFrmTelaConsultaPaises = class(TForm)
    EdtPais: TEdit;
    LblPais: TLabel;
    BtnConsultar: TButton;
    LblNomeOficial: TLabel;
    EdtNomeOficial: TEdit;
    LblCapital: TLabel;
    EdtCapital: TEdit;
    EdtRegiao: TEdit;
    LblRegiao: TLabel;
    LblPopulacao: TLabel;
    LblNomeDaMoeda: TLabel;
    EdtNomeDaMoeda: TEdit;
    LblSubRegiao: TLabel;
    EdtlSubRegiao: TEdit;
    EdtPopulacao: TEdit;
    ImgBandeira: TImage;
    ImgEmblema: TImage;
    BtnMapa: TButton;
    procedure BtnConsultarClick(Sender: TObject);
    procedure EdtPaisKeyPress(Sender: TObject; var Key: Char);
    procedure BtnMapaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FPais: TPais;
    function ConsultarPais: Boolean;
    procedure PreencherCampos;
  public
    { Public declarations }
  end;

var
  FrmTelaConsultaPaises: TFrmTelaConsultaPaises;

implementation

{$R *.dfm}

procedure TFrmTelaConsultaPaises.BtnConsultarClick(Sender: TObject);
begin
  try
    if not ConsultarPais then
    begin
      ShowMessage('Digite o país para poder consultar');
      Exit;
    end;
      PreencherCampos;
      if FPais.Mapa <> '' then
        BtnMapa.Enabled := True
      else
        BtnMapa.Enabled := False;
  except
    On E:Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TFrmTelaConsultaPaises.BtnMapaClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar(FPais.Mapa), nil, nil, SW_SHOWNORMAL);
end;

function TFrmTelaConsultaPaises.ConsultarPais: Boolean;
var
  LConsultorPais: TServicoPais;
begin
  Result := True;
  LConsultorPais := TServicoPais.Create;
  if EdtPais.Text = '' then
  begin
    Result := False;
    Exit;
  end;

  try
    try
      FPais := LConsultorPais.ObterDadosDoPais(EdtPais.Text);
    except
      raise;
    end;
  finally
    LConsultorPais.Free;
  end;
end;

procedure TFrmTelaConsultaPaises.EdtPaisKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    BtnConsultar.Click;
end;

procedure TFrmTelaConsultaPaises.FormCreate(Sender: TObject);
begin
  FPais := TPais.Create;
end;

procedure TFrmTelaConsultaPaises.FormDestroy(Sender: TObject);
begin
  FPais.Free;
end;

procedure TFrmTelaConsultaPaises.PreencherCampos;
begin
  EdtNomeOficial.Text := FPais.Nome;
  EdtCapital.Text := FPais.Capital;
  EdtRegiao.Text := FPais.Regiao;
  EdtlSubRegiao.Text := FPais.SubRegiao;
  EdtPopulacao.Text := FormatFloat('#,##0', FPais.Populacao);
  EdtNomeDaMoeda.Text := FPais.Moeda;
  ImgEmblema.Picture.LoadFromStream(FPais.Emblema);
  ImgBandeira.Picture.LoadFromStream(FPais.Bandeira);

  if FPais.Emblema.Size = 0 then
    ShowMessage('País sem emblema.');
  if FPais.Bandeira.Size = 0 then
    ShowMessage('País sem bandeira.');
end;
end.
