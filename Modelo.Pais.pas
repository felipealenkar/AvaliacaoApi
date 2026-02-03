unit Modelo.Pais;

interface

uses
  System.Classes;

type
  TPais = class
    private
      FNome: string;
      FCapital: string;
      FRegiao: string;
      FSubRegiao: string;
      FPopulacao: int64;
      FFusosHorarios: TStringList;
      FMoeda: string;
      FEmblema: TMemoryStream;
      FBandeira: TMemoryStream;
      FMapa: string;
    public
      property Nome: string read FNome write FNome;
      property Capital: string read FCapital write FCapital;
      property Regiao: string read FRegiao write FRegiao;
      property SubRegiao: string read FSubRegiao write FSubRegiao;
      property Populacao: int64 read FPopulacao write FPopulacao;
      property FusosHorarios: TStringList read FFusosHorarios write FFusosHorarios;
      property Moeda: string read FMoeda write FMoeda;
      property Emblema: TMemoryStream read FEmblema write FEmblema;
      property Bandeira: TMemoryStream read FBandeira write FBandeira;
      property Mapa: string read FMapa write FMapa;

      constructor Create;
      destructor Destroy; override;
  end;

implementation

{ TPais }

constructor TPais.Create;
begin
  FEmblema := TMemoryStream.Create;
  FBandeira := TMemoryStream.Create;
  FFusosHorarios := TStringList.Create;
end;

destructor TPais.Destroy;
begin
  FEmblema.Free;
  FBandeira.Free;
  FFusosHorarios.Free;
  inherited;
end;

end.
