unit Controllers.Server.Delivery.Caixa.Route;

interface
{(*}
uses
  Horse,
  System.JSON,
  System.SysUtils,
  Rest.Json,
  Server.Delivery.Controller.Interfaces,
  Server.Delivery.Controller,
  Server.Delivery.DTO, System.Generics.Collections, Fnc_Utils;
{*)}

procedure Registry;

implementation

procedure GetCaixas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lResult: TJSONArray;
  lQueryParams: TDictionary<string, string>;
  lController: iControllerServerDelivery;
  lDateCaixa, lInicialDate, lFinalDate: TDateTime;
  dt: TDateTime;
begin
  Res.ContentType('application/json;charset=UTF-8');
  lController := TControllerServerDelivery.New;
  lQueryParams := Req.Query.Dictionary;

  if lQueryParams.Count > 0 then
  begin
    if lQueryParams.ContainsKey('dataCaixa') then
    begin
      lDateCaixa := ReturnFormatedDate(lQueryParams.Items['dataCaixa'], 'yyyy-mm-dd');
      lResult := lController.CAIXA.GetByDate(lDateCaixa);
    end;

    if lQueryParams.ContainsKey('dataInicial') and lQueryParams.ContainsKey('dataFinal') then
    begin
      lInicialDate :=  ReturnFormatedDate(lQueryParams.Items['dataInicial'], 'yyyy-mm-dd');
      lFinalDate :=  ReturnFormatedDate(lQueryParams.Items['dataFinal'], 'yyyy-mm-dd');
      lResult := lController.CAIXA.GetBetweenDates(lInicialDate, lFinalDate);
    end;
  end
  else
    lResult := lController.CAIXA.GetAll;

  if lResult.Count > 0 then
    Res.Send(lResult.ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send<TJSONArray>(lResult).Status(THTTPStatus.NoContent);
end;

procedure GetCaixaByID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody: TJSONObject;
  lController: iControllerServerDelivery;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];

  if TryStrToInt(lValue, lID) then
    lBody := lController.CAIXA.GetByID(lID)
  else
  begin
    Res.Send(TJSONObject.Create().AddPair('Message', 'ID inválida').ToJSON).Status(THTTPStatus.NotFound);
    exit;
  end;

  if lBody.Count > 0 then
    Res.Send(lBody.ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send(lBody.ToJSON).Status(THTTPStatus.NotFound);
end;

procedure CreateCaixa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lResult, lSearchJSON: TJSONObject;
  lSearch: TCAIXA;
  lCurrentDate, lCaixaDate: string;
  lController: iControllerServerDelivery;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lSearchJSON := lController.CAIXA.GetOpen();
  lSearch := TJSON.JsonToObject<TCAIXA>(lSearchJSON);

  if lSearchJSON.Count > 0 then
  begin
    lSearch.DATA := lSearchJSON.GetValue<TDate>('dataAbertura');
    lCurrentDate := FormatDateTime('yyyy/mm/dd', Date);
    lCaixaDate := FormatDateTime('yyyy/mm/dd', lSearch.DATA);

    if lCurrentDate = lCaixaDate then
    begin
      Res.Send(TJSONObject.Create.AddPair('message', 'Caixa já está aberto!').ToJSON).Status(THTTPStatus.BadRequest);
      exit;
    end
    else
      lController.CAIXA.CloseCaixa(lSearch.ID);
  end;

  lResult := lController.CAIXA.Save();

  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('message', 'Caixa aberto com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.Created)
  else
    Res.Send(TJSONObject.Create.AddPair('error', 'Erro ao abrir caixa').ToJSON).Status(THTTPStatus.BadRequest);
end;

procedure CloseCaixa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lController: iControllerServerDelivery;
  lCardapioUpdated: TCARDAPIO;
  lBody: TJSONValue;
  lResult: TJSONObject;
  lProdutos: TObjectList<TPRODUTO>;
  lProduto: TPRODUTO;
  lProdutosJsonArray: TJSONArray;
  lTipo: TTIPO_CARDAPIO;
  I: Integer;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];

  if TryStrToInt(lValue, lID) then
  begin
    lResult := lController.CAIXA.CloseCaixa(lID);

    if lResult.Count > 0 then
      Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('message', 'Caixa fechado com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.OK)
    else
      Res.Send(TJSONObject.Create.AddPair('message', 'Erro ao fechar caixa!').ToJSON).Status(THTTPStatus.BadRequest);
  end
  else
  begin
    Res.Send(TJSONObject.Create().AddPair('Message', 'ID inválida').ToJSON).Status(THTTPStatus.NotFound);
    exit;
  end;
end;

procedure Registry;
begin
{(*}
  THorse
    .Group
      .Prefix('/caixas')
    .Post('', CreateCaixa)
    .Get('', GetCaixas)
    .Get(':id', GetCaixaByID)
    .Put('/fechar/:id', CloseCaixa);
{*)}
end;

end.

