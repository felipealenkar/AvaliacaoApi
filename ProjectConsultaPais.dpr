program ProjectConsultaPais;

uses
  Vcl.Forms,
  Tela.ConsultaPais in 'Tela.ConsultaPais.pas' {FrmTelaConsultaPaises},
  Servico.Pais in 'Servico.Pais.pas',
  Modelo.Pais in 'Modelo.Pais.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmTelaConsultaPaises, FrmTelaConsultaPaises);
  Application.Run;
end.
