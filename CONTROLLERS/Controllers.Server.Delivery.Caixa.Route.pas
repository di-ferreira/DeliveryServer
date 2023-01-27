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
  Server.Delivery.DTO, System.Generics.Collections;
{*)}

procedure Registry;

implementation

procedure GetCaixas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONArray;
  lController: iControllerServerDelivery;
begin
  Res.ContentType('application/json;charset=UTF-8');
  lController := TControllerServerDelivery.New;

  lBody := lController.CAIXA.GetAll;

  if lBody.Count > 0 then
    Res.Send(lBody.ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send<TJSONArray>(lBody).Status(THTTPStatus.NoContent);
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
    lBody := lController.CARDAPIO.GetByID(lID)
  else
  begin
    Res.Send(TJSONObject.Create().AddPair('Message', 'ID inv�lida').ToJSON).Status(THTTPStatus.NotFound);
    exit;
  end;

  if lBody.Count > 0 then
    Res.Send(lBody.ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send(lBody.ToJSON).Status(THTTPStatus.NotFound);
end;

procedure GetCaixaByDate(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody: TJSONArray;
  lController: iControllerServerDelivery;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];

  if TryStrToInt(lValue, lID) then
    lBody := lController.CARDAPIO.GetByTipo(lID)
  else
  begin
    Res.Send(TJSONObject.Create().AddPair('Message', 'ID inv�lida').ToJSON).Status(THTTPStatus.NotFound);
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
  lSearch.DATA := lSearchJSON.GetValue<TDate>('dataAbertura');
  lCurrentDate := FormatDateTime('yyyy/mm/dd', Date);
  lCaixaDate := FormatDateTime('yyyy/mm/dd', lSearch.DATA);

  if Assigned(lSearch) then
    if lCurrentDate = lCaixaDate then
    begin
      Res.Send(TJSONObject.Create.AddPair('message', 'Caixa j� est� aberto!').ToJSON).Status(THTTPStatus.BadRequest);
      exit;
    end
    else
      lController.CAIXA.CloseCaixa(lSearch.ID);

  lResult := lController.CAIXA.Save();

  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('message', 'Caixa aberto com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.Created)
  else
    Res.Send(TJSONObject.Create.AddPair('error', 'Erro ao abrir caixa').ToJSON).Status(THTTPStatus.BadRequest);
end;

procedure UpdateCardapio(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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
    lCardapioUpdated := TJSON.JsonToObject<TCARDAPIO>(lController.CARDAPIO.GetByID(lID));
  end
  else
  begin
    Res.Send(TJSONObject.Create().AddPair('Message', 'ID inv�lida').ToJSON).Status(THTTPStatus.NotFound);
    exit;
  end;

  lBody := TJSONObject.ParseJSONValue(Req.Body);
  lProdutosJsonArray := lBody.GetValue<TJSONArray>('produto');
  lProdutos := TObjectList<TPRODUTO>.Create;

  for I := 0 to Pred(lProdutosJsonArray.Count) do
  begin
    if lProdutosJsonArray.Items[I].GetValue<Integer>('id') > 0 then
      lProdutos.Add(TJSON.JsonToObject<TPRODUTO>(lController.PRODUTO.GetByID(lProdutosJsonArray.Items[I].GetValue<Integer>('id'))))
    else
    begin
      lProduto := TPRODUTO.Create;
      lProduto.ID := 0;
      lProduto.NOME := lProdutosJsonArray.Items[I].GetValue<string>('nome');
      lProduto.ESTOQUE := lProdutosJsonArray.Items[I].GetValue<Integer>('estoque');
      lProduto.CUSTO := lProdutosJsonArray.Items[I].GetValue<Double>('custo');
      lProduto.LUCRO := lProdutosJsonArray.Items[I].GetValue<Double>('percentual_lucro');

      lProdutos.Add(TJSON.JsonToObject<TPRODUTO>(lController.PRODUTO.Save(lProduto)));
    end;
  end;

  lTipo := TJSON.JsonToObject<TTIPO_CARDAPIO>(lBody.GetValue<TJSONObject>('tipo_cardapio'));
  lCardapioUpdated.PRODUTO := lProdutos;
  lCardapioUpdated.TIPO_CARDAPIO := lTipo;
  lCardapioUpdated.DESCRICAO := lBody.GetValue<string>('descricao');

  lResult := lController.CARDAPIO.Update(lCardapioUpdated);

  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('message', 'Cardapio atualizado com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send(TJSONObject.Create.AddPair('message', 'Erro ao atualizar Cardapio!').ToJSON).Status(THTTPStatus.BadRequest);
end;

procedure DeleteCardapio(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody, lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lCardapio: TCARDAPIO;
begin
  Res.ContentType('application/json;charset=UTF-8');
  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];

  if TryStrToInt(lValue, lID) then
    lBody := lController.CARDAPIO.GetByID(lID);

  if lBody.Count > 0 then
  begin
    lCardapio := TJSON.JsonToObject<TCARDAPIO>(lBody);
    lResult := lController.CARDAPIO.Delete(lCardapio.ID);
    if lResult.Count > 0 then
      Res.Send(lResult.ToJSON).Status(THTTPStatus.InternalServerError)
    else
      Res.Send(TJSONObject.Create.AddPair('message', 'Card�pio exclu�do com sucesso!').ToJSON).Status(THTTPStatus.OK)
  end
  else
    Res.Send(TJSONObject.Create.AddPair('message', 'Card�pio n�o encontrado').ToJSON).Status(THTTPStatus.NotFound);
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
    .Get('/tipo/:id', GetCaixaByDate)
    .Put(':id', UpdateCardapio)
    .Delete(':id', DeleteCardapio);
{*)}
end;

end.

