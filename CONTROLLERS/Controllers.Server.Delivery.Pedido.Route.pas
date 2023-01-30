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
  Server.Delivery.DTO;
{*)}

procedure Registry;

implementation

procedure GetProdutos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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

procedure GetProdutoByID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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

procedure CreateProduto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONValue;
  lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lProdutoValue: TPRODUTO;
  body:string;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lBody := TJSONObject.ParseJSONValue(Req.Body);

  lProdutoValue := TJSON.JsonToObject<TPRODUTO>(lBody.ToJSON);
  lProdutoValue.LUCRO := lBody.GetValue<Double>('percentual_lucro');
   body := lBody.ToString;
  lResult := lController.PRODUTO.Save(lProdutoValue);

  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('message', 'Produto adicionado com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.Created)
  else
    Res.Send(TJSONObject.Create.AddPair('error', 'Erro ao salvar Produto').ToJSON).Status(THTTPStatus.BadRequest);
end;

procedure UpdateProduto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody, lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lProdutoFound,lProdutoBody: TPRODUTO;
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

procedure DeleteProduto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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
      .Prefix('pedidos')
    .Post('', CreateProduto)
    .Get('', GetProdutos)
    .Get(':id', GetProdutoByID)
    .Put(':id', UpdateProduto)
    .Delete(':id', DeleteProduto);
{*)}
end;

end.

