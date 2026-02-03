unit Tela.ConsultaPais;

interface

uses
  Servico.Pais, Modelo.Pais, ShellAPI, Winapi.UxTheme,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.NumberBox,
  Vcl.ExtCtrls, Vcl.VirtualImage, Vcl.Imaging.pngimage, Vcl.OleCtrls, SHDocVw,
  Winapi.WebView2, Winapi.ActiveX, Vcl.Edge, Vcl.ComCtrls, Vcl.Samples.Gauges;

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
    EdtSubRegiao: TEdit;
    EdtPopulacao: TEdit;
    ImgBandeira: TImage;
    ImgEmblema: TImage;
    LblEmblema: TLabel;
    LblBandeira: TLabel;
    BtnTestarTodos: TButton;
    PbTeste: TProgressBar;
    LblProgresso: TLabel;
    EdgBrowserMapa: TEdgeBrowser;
    grpFiltro: TGroupBox;
    grpDados: TGroupBox;
    cbbListaPaises: TComboBox;
    LblFusosHorarios: TLabel;
    LblListaPaises: TLabel;
    BtnMapa: TButton;
    grpMapa: TGroupBox;
    mmoFusosHorarios: TMemo;
    LblPaisProcessado: TLabel;
    procedure BtnConsultarClick(Sender: TObject);
    procedure EdtPaisKeyPress(Sender: TObject; var Key: Char);
    procedure BtnMapaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CarregarListaPaises;
    procedure BtnTestarTodosClick(Sender: TObject);
    procedure cbbListaPaisesClick(Sender: TObject);
    procedure cbbListaPaisesDropDown(Sender: TObject);
    procedure BtnConsultarEnter(Sender: TObject);
    procedure cbbListaPaisesEnter(Sender: TObject);
    procedure EdtPaisEnter(Sender: TObject);
  private
    FPais: TPais;
    FListaPaises: TStringList;
    function ConsultarPais(PPais: string): Boolean;
    procedure ModificarComponentes;
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
    if not ConsultarPais(EdtPais.Text) then
    begin
      ShowMessage('Digite o país para poder consultar');
      Exit;
    end;
      PreencherCampos;
      ModificarComponentes;
  except
    On E:Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TFrmTelaConsultaPaises.BtnConsultarEnter(Sender: TObject);
begin
  cbbListaPaises.ItemIndex := -1;
end;

procedure TFrmTelaConsultaPaises.BtnMapaClick(Sender: TObject);
begin
  //ShellExecute(0, 'open', PChar(FPais.Mapa), nil, nil, SW_SHOWNORMAL);
  EdgBrowserMapa.Navigate(FPais.Mapa);
end;

procedure TFrmTelaConsultaPaises.BtnTestarTodosClick(Sender: TObject);
var
  LListaPaises: TStringList;
  LServicoPaises: TServicoPaises;
begin
  EdtPais.Clear;
  cbbListaPaises.ItemIndex := -1;
  LServicoPaises := TServicoPaises.Create;
  LListaPaises := TStringList.Create;
  try
    try
      LListaPaises := LServicoPaises.ObterTodosPaises;
      PbTeste.Max := LListaPaises.Count;
      for var i := 0 to LListaPaises.Count -1 do
      begin
        LblPaisProcessado.Caption := LListaPaises.Strings[i];
        ConsultarPais(LblPaisProcessado.Caption);
        PreencherCampos;
        ModificarComponentes;
        PbTeste.Position := PbTeste.Position + 1;
        LblProgresso.Caption := (i + 1).ToString + ' de ' + (LListaPaises.Count).ToString;
        FrmTelaConsultaPaises.Update; // força repaint do form
        Application.ProcessMessages;
      end;
    except
      on E:Exception do
      begin
        FrmTelaConsultaPaises.Update; // força repaint do form
        Application.ProcessMessages;
        ShowMessage(E.Message);
      end;
    end;
  finally
    ShowMessage('Teste Finalizado');
    LListaPaises.Free;
    LServicoPaises.Free;
  end;
end;


procedure TFrmTelaConsultaPaises.CarregarListaPaises;
var
  LServicoPaises: TServicoPaises;
begin
  LServicoPaises := TServicoPaises.Create;
  try
    try
      FListaPaises := LServicoPaises.ObterTodosPaises;
      for var i := 0 to FListaPaises.Count -1 do
        cbbListaPaises.AddItem(FListaPaises.Strings[i], FListaPaises);
    Except
      on E:Exception do
        ShowMessage(E.Message);
    end;
  finally
    LServicoPaises.Free;
  end;
end;

procedure TFrmTelaConsultaPaises.cbbListaPaisesClick(Sender: TObject);
begin
  try
    if not ConsultarPais(cbbListaPaises.Items.Strings[cbbListaPaises.ItemIndex]) then
    begin
      ShowMessage('Digite o país para poder consultar');
      Exit;
    end;
      PreencherCampos;
      ModificarComponentes;
  except
    On E:Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TFrmTelaConsultaPaises.cbbListaPaisesDropDown(Sender: TObject);
begin
  EdtPais.Clear;
  LblPaisProcessado.Caption := '';
end;

procedure TFrmTelaConsultaPaises.cbbListaPaisesEnter(Sender: TObject);
begin
  EdtPais.Clear;
  LblPaisProcessado.Caption := '';
end;

function TFrmTelaConsultaPaises.ConsultarPais(PPais: string): Boolean;
var
  LServicoPaises: TServicoPaises;
begin
  Result := True;
  LServicoPaises := TServicoPaises.Create;
  if PPais = '' then
  begin
    Result := False;
    Exit;
  end;

  try
    try
      FPais := LServicoPaises.ObterDadosDoPais(PPais);
    except
      raise;
    end;
  finally
    LServicoPaises.Free;
  end;
end;

procedure TFrmTelaConsultaPaises.EdtPaisEnter(Sender: TObject);
begin
  cbbListaPaises.ItemIndex := -1;
  LblPaisProcessado.Caption := '';
end;

procedure TFrmTelaConsultaPaises.EdtPaisKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    BtnConsultar.Click;
  end;
end;

procedure TFrmTelaConsultaPaises.FormCreate(Sender: TObject);
begin
  FPais := TPais.Create;
  FListaPaises := TStringList.Create;
  SetWindowTheme(PbTeste.Handle, '', '');
  EdgBrowserMapa.Navigate('https://restcountries.com/#api-endpoints-using-this-project');
  CarregarListaPaises;
end;

procedure TFrmTelaConsultaPaises.FormDestroy(Sender: TObject);
begin
  FPais.Free;
  FListaPaises.Free;
end;

procedure TFrmTelaConsultaPaises.ModificarComponentes;
begin
  if FPais.Mapa <> '' then
    BtnMapa.Enabled := True
  else
    BtnMapa.Enabled := False;

  if EdtCapital.Text = '' then
  begin
    EdtCapital.Text := 'Não existe capital.';
    EdtCapital.Font.Color := clRed;
  end
  else
    EdtCapital.Font.Color := clBlack;

  if EdtSubRegiao.Text = '' then
  begin
    EdtSubRegiao.Text := 'Não existe subregião.';
    EdtSubRegiao.Font.Color := clRed;
  end
  else
    EdtSubRegiao.Font.Color := clBlack;

  if EdtNomeDaMoeda.Text = '' then
  begin
    EdtNomeDaMoeda.Text := 'Não existe moeda.';
    EdtNomeDaMoeda.Font.Color := clRed;
  end
  else
    EdtNomeDaMoeda.Font.Color := clBlack;

  LblEmblema.Visible := FPais.Emblema.Size = 0;
  LblBandeira.Visible := FPais.Bandeira.Size = 0;
end;

procedure TFrmTelaConsultaPaises.PreencherCampos;
begin
  EdtNomeOficial.Text := FPais.Nome;

  EdtCapital.Text := FPais.Capital;
  EdtRegiao.Text := FPais.Regiao;
  EdtSubRegiao.Text := FPais.SubRegiao;
  EdtPopulacao.Text := FormatFloat('#,##0', FPais.Populacao);
  mmoFusosHorarios.Clear;

  for var i := 0 to FPais.FusosHorarios.Count -1 do
    mmoFusosHorarios.Text := mmoFusosHorarios.Text + FPais.FusosHorarios.Strings[i] + ' | ';
  EdtNomeDaMoeda.Text := FPais.Moeda;

  try
    ImgEmblema.Picture.LoadFromStream(FPais.Emblema);
  except
    ImgEmblema.Picture := nil;
    LblEmblema.Visible := True;
  end;

  try
    ImgBandeira.Picture.LoadFromStream(FPais.Bandeira);
  except
    ImgEmblema.Picture := nil;
    LblBandeira.Visible := True;
  end;
end;
end.
