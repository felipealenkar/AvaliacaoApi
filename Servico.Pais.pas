unit Servico.Pais;

interface

uses
  Vcl.Dialogs,
  System.JSON,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  Modelo.Pais,
  System.Generics.Collections,
  System.SysUtils,
  System.Classes,
  REST.Client,
  REST.Types;

type
  TServicoPais = class
    private
      FClient: TRESTClient;
      FRequest: TRESTRequest;
      FResponse: TRESTResponse;
    public
      constructor Create;
      destructor Destroy; override;
      function ObterDadosDoPais(PPais: string): TPais;
      function ColetarCampoSeExistir(PJsonObject: TJSONObject; PCampo: String): string;
      function ObterImagemComTREST(PJsonString: string): TMemoryStream;
      function ObterImagemComTNetHttp(PJsonString: string): TMemoryStream;
      function AlimentarClasse(PJsonString: string): TPais;
  end;

implementation

function TServicoPais.AlimentarClasse(PJsonString: string): TPais;
var
  LJsonArray: TJSONArray;
    LJsonObject: TJSONObject;
      LTranslationsObject: TJSONObject;
        LPorObject: TJSONObject;
      LCapitalArray: TJSONArray;
    LCurrenciesObject: TJSONObject;
    LFlagsObject: TJSONObject;
    LcoatOfArmsObject: TJSONObject;
    LMapsObject: TJSONObject;
  LPair: TJSONPair;
begin
  Result := TPais.Create;
  try
    LJsonArray := TJSONArray.ParseJSONValue(PJsonString) as TJSONArray;
    LJsonObject := LJsonArray.Items[0] as TJSONObject;

    LTranslationsObject := LJsonObject.GetValue('translations') as TJSONObject;
    LPorObject := LTranslationsObject.GetValue('por') as TJSONObject;
    LCapitalArray := LJsonObject.GetValue('capital') as TJSONArray;
    LCurrenciesObject := LJsonObject.GetValue('currencies') as TJSONObject;
    LPair := LCurrenciesObject.Pairs[0];
    LCurrenciesObject := LPair.JsonValue as TJSONObject;
    LcoatOfArmsObject := LJsonObject.GetValue('coatOfArms') as TJSONObject;
    LFlagsObject := LJsonObject.GetValue('flags') as TJSONObject;
    LMapsObject := LJsonObject.GetValue('maps') as TJSONObject;

    Result.Nome := LPorObject.GetValue<string>('official');
    Result.Capital := LCapitalArray.Items[0].GetValue<string>;
    Result.Regiao := LJsonObject.GetValue<string>('region');
    Result.SubRegiao := LJsonObject.GetValue<string>('subregion');
    Result.Populacao := LJsonObject.GetValue<int64>('population');
    Result.Moeda := Format('%s - %s', [LCurrenciesObject.GetValue<string>('name'),
      LCurrenciesObject.GetValue<string>('symbol')]);

    //Tratamento feito devido a alguns países não possuírem os campos de emblema, bandeira e mapas
    //Resultando em erro.
    if ColetarCampoSeExistir(LcoatOfArmsObject, 'png') <> '' then
      Result.Emblema.LoadFromStream(ObterImagemComTNetHttp(LcoatOfArmsObject.GetValue<string>('png')));

    if ColetarCampoSeExistir(LFlagsObject, 'png') <> '' then
      Result.Bandeira.LoadFromStream(ObterImagemComTNetHttp(LFlagsObject.GetValue<string>('png')));

    if ColetarCampoSeExistir(LMapsObject, 'googleMaps') <> '' then
      Result.Mapa := LMapsObject.GetValue<string>('googleMaps');
  except
    raise;
  end;
end;

{ ConsultorPais }

constructor TServicoPais.Create;
begin
  FClient := TRESTClient.Create('https://restcountries.com/v3.1/name/');
  // Para testar se o timeout funciona
  //FClient := TRESTClient.Create('http://10.255.255.1');
  FRequest := TRESTRequest.Create(nil);
  FResponse := TRESTResponse.Create(nil);

  FRequest.Client := FClient;
  FRequest.Response := FResponse;
end;

destructor TServicoPais.Destroy;
begin
  FResponse.Free;
  FRequest.Free;
  FClient.Free;
  inherited;
end;

function TServicoPais.ColetarCampoSeExistir(PJsonObject: TJSONObject; PCampo: String): string;
begin
  Result := '';
  if Assigned(PJsonObject) then
    PJsonObject.TryGetValue<string>(PCampo, Result);
end;

function TServicoPais.ObterImagemComTREST(PJsonString: string): TMemoryStream;
// Função funciona mas não está sendo usada
// Foi mantida aqui apenas para fins de estudo, ao consultar o país senegal ocorre erro de encoding
// Pelo que pesquisei algo no retorno desse emblema tem caracteres UTF8 e TRestClient usa ANSI
// Tentei converter várias vezes de várias formas para UTF8 mas sempre dava erro
// Solução, usar a função ObterImagemComTNetHttp que usa TNetHTTPClient ao invés de TREST.
var
  LClient: TRESTClient;
  LRequest: TRESTRequest;
  LResponse: TRESTResponse;
begin
  LClient := TRESTClient.Create(PJsonString);
  LRequest := TRESTRequest.Create(nil);
  LResponse := TRESTResponse.Create(nil);

  LRequest.Client := LClient;
  LRequest.Response := LResponse;
  LRequest.Resource := '';
  LRequest.Method := rmGET;

  Result := TMemoryStream.Create;
  try
    try
      LRequest.Execute;

      if FResponse.StatusCode <> 200 then
        raise Exception.Create('Não foi possível carregar a bandeira');

      Result.WriteBuffer(LResponse.RawBytes[0], Length(LResponse.RawBytes));
      Result.Position := 0;
    except
      Result.Free;
      raise;
    end;
  finally
    LResponse.Free;
    LRequest.Free;
    LClient.Free;
  end;
end;

function TServicoPais.ObterImagemComTNetHttp(PJsonString: string): TMemoryStream;
var
  LHttpClient: TNetHTTPClient;
  LIHTTPResp: IHTTPResponse;
begin
  Result := TMemoryStream.Create;
  LHttpClient := TNetHTTPClient.Create(nil);
  LHttpClient.ConnectionTimeout := 10000;
  try
    try
      LIHTTPResp := LHttpClient.Get(PJsonString, Result);
      Result.Position := 0;

      if LIHTTPResp.StatusCode <> 200 then
        raise Exception.Create('Não foi possível carregar a bandeira');
    except
      Result.Free;
      raise;
    end;
  finally
    LHttpClient.Free;
  end;
end;

function TServicoPais.ObterDadosDoPais(PPais: string): TPais;
begin
  FRequest.Timeout := 10000;
  FRequest.Resource := PPais;
  FRequest.Method := rmGET;
  try
    FRequest.Execute;

    if FResponse.StatusCode <> 200 then
    begin
      if FResponse.StatusCode = 400 then
        raise Exception.Create('Erro na requisição')
      else if FResponse.StatusCode = 404 then
        raise Exception.Create('País não encontrado')
      else if FResponse.StatusCode = 500 then
        raise Exception.Create('Erro interno da API')
      else
        raise Exception.CreateFmt('Erro na requisição %s - %s', [FResponse.StatusCode, FResponse.StatusText]);
    end;
    Result := AlimentarClasse(FResponse.Content);
  Except
    on E:Exception do
    begin
    if E.Message.ToLower.Contains('time') or E.Message.ToLower.Contains('tempo') then
      raise Exception.Create('Tempo limite excedido.')
    else
      raise;
    end;
  end;
end;

end.
