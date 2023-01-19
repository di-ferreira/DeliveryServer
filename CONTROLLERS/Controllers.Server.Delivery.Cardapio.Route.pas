unit Controllers.Server.Delivery.Cardapio.Route;

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

procedure GetCardapios(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONArray;
  lController: iControllerServerDelivery;
begin
  Res.ContentType('application/json;charset=UTF-8');
  lController := TControllerServerDelivery.New;

  lBody := lController.CARDAPIO.GetAll;

  if lBody.Count > 0 then
    Res.Send(lBody.ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send<TJSONArray>(lBody).Status(THTTPStatus.NoContent);
end;

procedure GetCardapioByID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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
    Res.Send(TJSONObject.Create().AddPair('Message', 'ID inválida').ToJSON).Status(THTTPStatus.NotFound);
    exit;
  end;

  if lBody.Count > 0 then
    Res.Send(lBody.ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send(lBody.ToJSON).Status(THTTPStatus.NotFound);
end;

procedure GetCardapioByTipo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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
    Res.Send(TJSONObject.Create().AddPair('Message', 'ID inválida').ToJSON).Status(THTTPStatus.NotFound);
    exit;
  end;

  if lBody.Count > 0 then
    Res.Send(lBody.ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send(lBody.ToJSON).Status(THTTPStatus.NotFound);
end;

procedure CreateCardapio(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONValue;
  lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lCardapio: TCARDAPIO;
  lProdutos: TObjectList<TPRODUTO>;
  lProduto: TPRODUTO;
  lProdutosJsonArray: TJSONArray;
  lTipo: TTIPO_CARDAPIO;
  I: Integer;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lBody := TJSONObject.ParseJSONValue(Req.Body);
  lProdutosJsonArray := lBody.GetValue<TJSONArray>('produto');
  lProdutos := TObjectList<TPRODUTO>.Create;
  lCardapio := TCARDAPIO.Create;

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
  lCardapio.PRODUTO := lProdutos;
  lCardapio.TIPO_CARDAPIO := lTipo;
  lCardapio.ID := 0;
  lCardapio.DESCRICAO := lBody.GetValue<string>('descricao');

  lResult := lController.CARDAPIO.Save(lCardapio);

  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('message', 'cardapio adicionado com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.Created)
  else
    Res.Send(TJSONObject.Create.AddPair('error', 'Erro ao salvar cardapio').ToJSON).Status(THTTPStatus.BadRequest);
end;

procedure UpdateCardapioo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody, lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lTPPgtoFound, lTpPgtoBody: TTIPOPGTO;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];

  if TryStrToInt(lValue, lID) then
  begin
    lBody := lController.TIPO_PGTO.GetByID(lID);
  end
  else
  begin
    Res.Send(TJSONObject.Create().AddPair('Message', 'ID inválida').ToJSON).Status(THTTPStatus.NotFound);
    exit;
  end;

  lTPPgtoFound := TJSON.JsonToObject<TTIPOPGTO>(lBody);

  lTpPgtoBody := TJSON.JsonToObject<TTIPOPGTO>(Req.Body);

  lTPPgtoFound.DESCRICAO := lTpPgtoBody.DESCRICAO;

  lResult := lController.TIPO_PGTO.Update(lTPPgtoFound);

  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('message', 'Cardapio atualizado com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send(TJSONObject.Create.AddPair('message', 'Erro ao atualizar Cardapio!').ToJSON).Status(THTTPStatus.InternalServerError);
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
      Res.Send(TJSONObject.Create.AddPair('message', 'Cardápio excluído com sucesso!').ToJSON).Status(THTTPStatus.OK)
  end
  else
    Res.Send(TJSONObject.Create.AddPair('message', 'Cardápio não encontrado').ToJSON).Status(THTTPStatus.NotFound);
end;

procedure Registry;
begin
{(*}
  THorse
    .Group
      .Prefix('/cardapios')
    .Post('', CreateCardapio)
    .Get('', GetCardapios)
    .Get(':id', GetCardapioByID)
    .Get('/tipo/:id', GetCardapioByTipo)
    .Put(':id', UpdateCardapioo)
    .Delete(':id', DeleteCardapio);
{*)}
end;

end.

