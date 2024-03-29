unit Controllers.Server.Delivery.Pedido.Route;

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

procedure GetPedidos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONArray;
  lController: iControllerServerDelivery;
begin
  Res.ContentType('application/json;charset=UTF-8');
  lController := TControllerServerDelivery.New;

  lBody := lController.PEDIDO.GetAll;

  if lBody.Count > 0 then
    Res.Send(lBody.ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send<TJSONArray>(lBody).Status(THTTPStatus.NoContent);
end;

procedure GetPedidoByID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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
    lBody := lController.PEDIDO.GetByID(lID)
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

procedure CreatePedido(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONValue;
  lResult, lClienteJSON, lEnderecoJSON, lCaixaJSON, lCardapioJSON: TJSONObject;
  lTPPagamentoJsonArray, lItemsJsonArray: TJSONArray;
  lController: iControllerServerDelivery;
  lPedido: TPEDIDO;
  lCliente: TCLIENTE;
  lEndereco: TENDERECO;
  lTPPagamento: TObjectList<TTIPOPGTO>;
  lCardapio: TCARDAPIO;
  lItems: TObjectList<TITEM_PEDIDO>;
  lItem: TITEM_PEDIDO;
  I: Integer;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lPedido := TPEDIDO.Create;
  lEndereco := TENDERECO.Create;
  lBody := TJSONObject.ParseJSONValue(Req.Body);

  lClienteJSON := lBody.GetValue<TJSONObject>('cliente');
  lCliente := TJSON.JsonToObject<TCLIENTE>(lClienteJSON);

  lEnderecoJSON := lBody.GetValue<TJSONObject>('endereco_entrega');

  lEndereco.ID := lEnderecoJSON.GetValue<integer>('id');
  lEndereco.RUA := lEnderecoJSON.GetValue<string>('rua');
  lEndereco.NUMERO := lEnderecoJSON.GetValue<string>('numero');
  lEndereco.BAIRRO := lEnderecoJSON.GetValue<string>('bairro');
  lEndereco.CIDADE := lEnderecoJSON.GetValue<string>('complemento');
  lEndereco.ESTADO := lEnderecoJSON.GetValue<string>('cidade');
  lEndereco.COMPLEMENTO := lEnderecoJSON.GetValue<string>('estado');
  lEndereco.CLIENTE := lCliente;

  if lBody.TryGetValue('tipos_pagamento', lTPPagamentoJsonArray) then
  begin

    lTPPagamentoJsonArray := lBody.GetValue<TJSONArray>('tipos_pagamento');
    lTPPagamento := TObjectList<TTIPOPGTO>.Create;
    for I := 0 to Pred(lTPPagamentoJsonArray.Count) do
      lTPPagamento.Add(TJSON.JsonToObject<TTIPOPGTO>(lController.TIPO_PGTO.GetByID(lTPPagamentoJsonArray.Items[I].GetValue<Integer>('id'))));

    lPedido.TIPO_PAGAMENTO := lTPPagamento;
  end;

  lPedido.ID := lBody.GetValue<integer>('id');
  lPedido.ABERTO := lBody.GetValue<Boolean>('aberto');
  lPedido.CANCELADO := lBody.GetValue<Boolean>('cancelado');
  lPedido.OBS := lBody.GetValue<string>('obs');
  lPedido.CLIENTE := lCliente;
  lPedido.ENDERECO_ENTREGA := lEndereco;

  lItemsJsonArray := lBody.GetValue<TJSONArray>('items');
  lItems := TObjectList<TITEM_PEDIDO>.Create;

  for I := 0 to Pred(lItemsJsonArray.Count) do
  begin
    lCardapioJSON := lItemsJsonArray.Items[I].GetValue<TJSONObject>('item_cardapio');
    lCardapio := TJSON.JsonToObject<TCARDAPIO>(lCardapioJSON);
    lItem := TITEM_PEDIDO.Create;
    lItem.ID := 0;
    lItem.PEDIDO := lPedido;
    lItem.ITEM_CARDAPIO := lCardapio;
    lItem.QUANTIDADE := lItemsJsonArray.Items[I].GetValue<integer>('quantidade');

    lItems.Add(lItem);
  end;

  lPedido.ITEMS := lItems;

  if lPedido.ITEMS.Count > 0 then
    lResult := lController.PEDIDO.CreateWithItems(lPedido)
  else
    lResult := lController.PEDIDO.Save(lPedido);

  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('message', 'Pedido adicionado com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.Created)
  else
    Res.Send(TJSONObject.Create.AddPair('error', 'Erro ao adicionar Pedido').ToJSON).Status(THTTPStatus.BadRequest);
end;

procedure CancelarPedido(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody: TJSONValue;
  lResult, lCardapioJSON, lPedidoJSON: TJSONObject;
  lController: iControllerServerDelivery;
  lPedidoFound: TPEDIDO;
  lItemsJsonArray: TJSONArray;
  lCardapio: TCARDAPIO;
  lItem: TITEM_PEDIDO;
  lItems: TObjectList<TITEM_PEDIDO>;
  I: Integer;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];
  lBody := TJSONObject.ParseJSONValue(Req.Body);

  if TryStrToInt(lValue, lID) then
  begin
    lPedidoJSON := lController.PEDIDO.GetByID(lID);
  end
  else
  begin
    Res.Send(TJSONObject.Create().AddPair('Message', 'ID inv�lida').ToJSON).Status(THTTPStatus.NotFound);
    exit;
  end;

  lPedidoFound := TPEDIDO.Create;

  lItemsJsonArray := lBody.GetValue<TJSONArray>('items');
  lItems := TObjectList<TITEM_PEDIDO>.Create;

  lPedidoFound.ID := lPedidoJSON.GetValue<integer>('id');
  lPedidoFound.OBS := lPedidoJSON.GetValue<string>('obs');
  lPedidoFound.ABERTO := lPedidoJSON.GetValue<Boolean>('aberto');
  lPedidoFound.ENDERECO_ENTREGA := TJSON.JsonToObject<TENDERECO>(lPedidoJSON.GetValue<TJSONObject>);

  for I := 0 to Pred(lItemsJsonArray.Count) do
  begin
    lCardapioJSON := lItemsJsonArray.Items[I].GetValue<TJSONObject>('item_cardapio');
    lCardapio := TJSON.JsonToObject<TCARDAPIO>(lCardapioJSON);
    lItem := TITEM_PEDIDO.Create;
    lItem.ID := 0;
    lItem.PEDIDO := lPedidoFound;
    lItem.ITEM_CARDAPIO := lCardapio;
    lItem.QUANTIDADE := lItemsJsonArray.Items[I].GetValue<integer>('quantidade');

    lItems.Add(lItem);
  end;

  lPedidoFound.ITEMS := lItems;
  lPedidoFound.CANCELADO := true;

  lResult := lController.PEDIDO.Update(lPedidoFound);

  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('message', 'Pedido cancelado com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send(TJSONObject.Create.AddPair('message', 'Erro ao cancelar pedido!').ToJSON).Status(THTTPStatus.InternalServerError);
end;

procedure FecharPedido(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID, I: Integer;
  lValue: string;
  lBody: TJSONValue;
  lResult, lCardapioJSON, lPedidoJSON: TJSONObject;
  lController: iControllerServerDelivery;
  lPedidoFound: TPEDIDO;
  lItemsJsonArray, lTiposPagamentoArray: TJSONArray;
  lCardapio: TCARDAPIO;
  lTipoPagamento: TTIPOPGTO;
  lTiposPagamento: TObjectList<TTIPOPGTO>;
  lItem: TITEM_PEDIDO;
  lItems: TObjectList<TITEM_PEDIDO>;
  lTotalTipoPgto: Double;
  lDiferencaPgto, lDif: Boolean;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];
  lBody := TJSONObject.ParseJSONValue(Req.Body);

  if TryStrToInt(lValue, lID) then
  begin
    lPedidoJSON := lController.PEDIDO.GetByID(lID);
  end
  else
  begin
    Res.Send(TJSONObject.Create().AddPair('Message', 'ID inv�lida').ToJSON).Status(THTTPStatus.NotFound);
    exit;
  end;

  lPedidoFound := TPEDIDO.Create;

  lItemsJsonArray := lBody.GetValue<TJSONArray>('items');
  lTiposPagamentoArray := lBody.GetValue<TJSONArray>('tipos_pagamento');
  lItems := TObjectList<TITEM_PEDIDO>.Create;

  lPedidoFound.ID := lPedidoJSON.GetValue<integer>('id');
  lPedidoFound.OBS := lPedidoJSON.GetValue<string>('obs');
  lPedidoFound.CANCELADO := lPedidoJSON.GetValue<Boolean>('cancelado');
  lPedidoFound.ENDERECO_ENTREGA := TJSON.JsonToObject<TENDERECO>(lPedidoJSON.GetValue<TJSONObject>('enderecoEntrega'));

  for I := 0 to Pred(lItemsJsonArray.Count) do
  begin
    lCardapioJSON := lItemsJsonArray.Items[I].GetValue<TJSONObject>('item_cardapio');
    lCardapio := TJSON.JsonToObject<TCARDAPIO>(lCardapioJSON);
    lItem := TITEM_PEDIDO.Create;
    lItem.ID := 0;
    lItem.PEDIDO := lPedidoFound;
    lItem.ITEM_CARDAPIO := lCardapio;
    lItem.QUANTIDADE := lItemsJsonArray.Items[I].GetValue<integer>('quantidade');

    lItems.Add(lItem);
  end;

  lTiposPagamento := TObjectList<TTIPOPGTO>.Create;

  for I := 0 to Pred(lTiposPagamentoArray.Count) do
  begin
    lTipoPagamento := TTIPOPGTO.Create;
    lTipoPagamento.ID := lTiposPagamentoArray.Items[I].GetValue<integer>('id');
    lTipoPagamento.DESCRICAO := lTiposPagamentoArray.Items[I].GetValue<string>('descricao');
    lTipoPagamento.VALOR_PAGO := lTotalTipoPgto + lTiposPagamentoArray.Items[I].GetValue<Double>('valor');

    lTotalTipoPgto := lTotalTipoPgto + lTiposPagamentoArray.Items[I].GetValue<Double>('valor');
    lTiposPagamento.Add(lTipoPagamento);
  end;

  lPedidoFound.ITEMS := lItems;
  lPedidoFound.TIPO_PAGAMENTO := lTiposPagamento;
  lPedidoFound.ABERTO := False;

  lDiferencaPgto := lBody.GetValue<Boolean>('diferencaPagamento');

  lDif :=  (lPedidoFound.TOTAL <> lTotalTipoPgto);

  if (lDif AND not lDiferencaPgto) then
  begin
    Res.Send(TJSONObject.Create.AddPair('message', 'Pagamento diferente do total!').ToJSON).Status(THTTPStatus.BadRequest);
    exit;
  end;

  lResult := lController.PEDIDO.Update(lPedidoFound);

  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('message', 'Pedido fechado com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send(TJSONObject.Create.AddPair('message', 'Erro ao fechar pedido!').ToJSON).Status(THTTPStatus.InternalServerError);
end;

procedure DeleteItem(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody, lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lItemPedido: TITEM_PEDIDO;
begin
  Res.ContentType('application/json;charset=UTF-8');
  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];

  if TryStrToInt(lValue, lID) then
    lBody := lController.ITEM_PEDIDO.GetByID(lID)
  else
  begin
    Res.Send(TJSONObject.Create().AddPair('Message', 'ID inv�lida').ToJSON).Status(THTTPStatus.NotFound);
    exit;
  end;

  if lBody.Count > 0 then
  begin
    lItemPedido := TJSON.JsonToObject<TITEM_PEDIDO>(lBody);
    lResult := lController.ITEM_PEDIDO.Delete(lItemPedido.ID);
    if lResult.Count > 0 then
      Res.Send(lResult.ToJSON).Status(THTTPStatus.InternalServerError)
    else
      Res.Send(TJSONObject.Create.AddPair('message', 'Item exclu�do com sucesso!').ToJSON).Status(THTTPStatus.OK)
  end
  else
    Res.Send(TJSONObject.Create.AddPair('message', 'Item n�o encontrado').ToJSON).Status(THTTPStatus.NotFound);
end;

procedure AddItem(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONValue;
  lResult, lCardapioJSON, lPedidoJSON: TJSONObject;
  lController: iControllerServerDelivery;
  lPedido: TPEDIDO;
  lCardapio: TCARDAPIO;
  lItem: TITEM_PEDIDO;
  I, lPedidoID: Integer;
  lPedidoIDParam: string;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lBody := TJSONObject.ParseJSONValue(Req.Body);
  lPedidoIDParam := Req.Params['id_pedido'];

  if TryStrToInt(lPedidoIDParam, lPedidoID) then
  begin
    lPedido := TPEDIDO.Create;
    lPedidoJSON := lController.PEDIDO.GetByID(lPedidoID);
    lPedido.ID := lPedidoJSON.GetValue<integer>('id');
    lPedido.OBS := lPedidoJSON.GetValue<string>('obs');
    lPedido.CANCELADO := lPedidoJSON.GetValue<Boolean>('cancelado');
    lPedido.ABERTO := lPedidoJSON.GetValue<Boolean>('aberto');
  end
  else
  begin
    Res.Send(TJSONObject.Create().AddPair('Message', 'ID inv�lida').ToJSON).Status(THTTPStatus.NotFound);
    exit;
  end;

  lCardapioJSON := lBody.GetValue<TJSONObject>('item_cardapio');
  lCardapio := TJSON.JsonToObject<TCARDAPIO>(lController.CARDAPIO.GetByID(lCardapioJSON.GetValue<integer>('id')));
  lItem := TITEM_PEDIDO.Create;
  lItem.ID := 0;
  lItem.PEDIDO := lPedido;
  lItem.ITEM_CARDAPIO := lCardapio;
  lItem.QUANTIDADE := lBody.GetValue<integer>('quantidade');

  lResult := lController.ITEM_PEDIDO.Save(lItem);

  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('message', 'Item adicionado com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.Created)
  else
    Res.Send(TJSONObject.Create.AddPair('error', 'Erro ao adicionar Item').ToJSON).Status(THTTPStatus.BadRequest);
end;

procedure EditItem(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue, s: string;
  lResult, lBody: TJSONObject;
  lController: iControllerServerDelivery;
  lItemPedido, lItemPedidoFound: TITEM_PEDIDO;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];

  if TryStrToInt(lValue, lID) then
  begin
    lBody := lController.ITEM_PEDIDO.GetByID(lID);
  end
  else
  begin
    Res.Send(TJSONObject.Create().AddPair('Message', 'ID inv�lida').ToJSON).Status(THTTPStatus.NotFound);
    exit;
  end;
  s := lBody.ToJSON;
  lItemPedidoFound := TJSON.JsonToObject<TITEM_PEDIDO>(lBody);

  lItemPedido := TJSON.JsonToObject<TITEM_PEDIDO>(Req.Body);

  lItemPedido.ITEM_CARDAPIO := TJSON.JsonToObject<TCARDAPIO>(lBody.GetValue<TJSONObject>('itemCardapio'));

  lItemPedido.ID := lItemPedidoFound.ID;

  lResult := lController.ITEM_PEDIDO.Update(lItemPedido);

  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('message', 'Item atualizado com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send(TJSONObject.Create.AddPair('message', 'Erro ao atualizar item!').ToJSON).Status(THTTPStatus.InternalServerError);
end;

procedure GetItemByID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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
    lBody := lController.ITEM_PEDIDO.GetByID(lID)
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

procedure GetItems(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody: TJSONArray;
  lController: iControllerServerDelivery;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id_pedido'];

  if TryStrToInt(lValue, lID) then
    lBody := lController.ITEM_PEDIDO.GetByPedido(lID)
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

procedure Registry;
begin
{(*}
  THorse
    .Group
      .Prefix('/pedidos')
    .Post('', CreatePedido)
    .Get('', GetPedidos)
    .Get(':id', GetPedidoByID)
    .Put(':id/cancelar', CancelarPedido)
    .Put(':id/fechar', FecharPedido)
    .Post(':id_pedido/items', AddItem)
    .Get(':id_pedido/items', GetItems)
    .Get(':id_pedido/items/:id', GetItemByID)
    .Put(':id_pedido/items/:id', EditItem)
    .Delete(':id_pedido/items/:id', DeleteItem);

{*)}
end;

end.

