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

  lBody := lController.PRODUTO.GetAll;

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
    lBody := lController.PRODUTO.GetByID(lID)
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
  S: string;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lBody := TJSONObject.ParseJSONValue(Req.Body);

  lClienteJSON := lBody.GetValue<TJSONObject>('cliente');
  lCliente := TJSON.JsonToObject<TCLIENTE>(lClienteJSON);

  lEnderecoJSON := lBody.GetValue<TJSONObject>('endereco_entrega');
  lEndereco := TENDERECO.Create;
  lEndereco.ID := lEnderecoJSON.GetValue<integer>('id');
  lEndereco.RUA := lEnderecoJSON.GetValue<string>('rua');
  lEndereco.NUMERO := lEnderecoJSON.GetValue<string>('numero');
  lEndereco.BAIRRO := lEnderecoJSON.GetValue<string>('bairro');
  lEndereco.CIDADE := lEnderecoJSON.GetValue<string>('complemento');
  lEndereco.ESTADO := lEnderecoJSON.GetValue<string>('cidade');
  lEndereco.COMPLEMENTO := lEnderecoJSON.GetValue<string>('estado');
  lEndereco.CLIENTE := lCliente;

  lTPPagamentoJsonArray := lBody.GetValue<TJSONArray>('tipos_pagamento');
  lTPPagamento := TObjectList<TTIPOPGTO>.Create;
  for I := 0 to Pred(lTPPagamentoJsonArray.Count) do
    lTPPagamento.Add(TJSON.JsonToObject<TTIPOPGTO>(lController.TIPO_PGTO.GetByID(lTPPagamentoJsonArray.Items[I].GetValue<Integer>('id'))));

  lPedido := TPEDIDO.Create;
  lPedido.ID := lBody.GetValue<integer>('id');
  lPedido.ABERTO := lBody.GetValue<Boolean>('aberto');
  lPedido.CANCELADO := lBody.GetValue<Boolean>('cancelado');
  lPedido.OBS := lBody.GetValue<string>('obs');
  lPedido.CLIENTE := lCliente;
  lPedido.ENDERECO_ENTREGA := lEndereco;
  lPedido.TIPO_PAGAMENTO := lTPPagamento;

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

procedure UpdatePedido(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody, lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lProdutoFound, lProdutoBody: TPRODUTO;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];

  if TryStrToInt(lValue, lID) then
  begin
    lBody := lController.PRODUTO.GetByID(lID);
  end
  else
  begin
    Res.Send(TJSONObject.Create().AddPair('Message', 'ID inválida').ToJSON).Status(THTTPStatus.NotFound);
    exit;
  end;

  lProdutoFound := TJSON.JsonToObject<TPRODUTO>(lBody);

  lProdutoBody := TJSON.JsonToObject<TPRODUTO>(Req.Body);

  lProdutoFound.NOME := lProdutoBody.NOME;
  lProdutoFound.ESTOQUE := lProdutoBody.ESTOQUE;
  lProdutoFound.CUSTO := lProdutoBody.CUSTO;
  lProdutoFound.LUCRO := lProdutoBody.LUCRO;

  lResult := lController.PRODUTO.Update(lProdutoFound);

  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('message', 'Produto atualizado com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send(TJSONObject.Create.AddPair('message', 'Erro ao atualizar produto!').ToJSON).Status(THTTPStatus.InternalServerError);
end;

procedure DeletePedido(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody, lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lProduto: TPRODUTO;
begin
  Res.ContentType('application/json;charset=UTF-8');
  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];

  if TryStrToInt(lValue, lID) then
    lBody := lController.PRODUTO.GetByID(lID);

  if lBody.Count > 0 then
  begin
    lProduto := TJSON.JsonToObject<TPRODUTO>(lBody);
    lResult := lController.PRODUTO.Delete(lProduto.ID);
    if lResult.Count > 0 then
      Res.Send(lResult.ToJSON).Status(THTTPStatus.InternalServerError)
    else
      Res.Send(TJSONObject.Create.AddPair('message', 'Produto excluído com sucesso!').ToJSON).Status(THTTPStatus.OK)
  end
  else
    Res.Send(TJSONObject.Create.AddPair('message', 'Produto não encontrado').ToJSON).Status(THTTPStatus.NotFound);
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
    .Put(':id', UpdatePedido)
    .Delete(':id', DeletePedido);
//    .Prefix('pedidos/:id_pedido')
//    .Post('',CreateItem)
//    .Get('',GetItems)
//    .Get(':id',GetItem)
//    .Put(':id', UpdateItem)
//    .Delete(':id', DeleteItem)

{*)}
end;

end.

