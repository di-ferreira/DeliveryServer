unit Controllers.Server.Delivery.Cliente.Route;

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

procedure GetClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONArray;
  lController: iControllerServerDelivery;
begin
  lController := TControllerServerDelivery.New;

  lBody := lController.CLIENTE.GetAll;
  Res.ContentType('application/json;charset=UTF-8');

  if lBody.Count > 0 then
    Res.Send(lBody.ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send<TJSONArray>(lBody).Status(THTTPStatus.NoContent);
end;

procedure GetClienteByID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody: TJSONObject;
  lController: iControllerServerDelivery;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];

  if lValue.Length < 10 then
  begin
    if TryStrToInt(lValue, lID) then
      lBody := lController.CLIENTE.GetByID(lID);
  end
  else
    lBody := lController.CLIENTE.GetByContato(lValue);

  if lBody.Count > 0 then
    Res.Send(lBody.ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send(lBody.ToJSON).Status(THTTPStatus.NotFound);
end;

procedure CreateCliente(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONValue;
  lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lClienteValue: TCLIENTE;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lBody := TJSONObject.ParseJSONValue(Req.Body);

  lClienteValue := TJSON.JsonToObject<TCLIENTE>(lBody.ToJSON);

  lResult := lController.CLIENTE.GetByContato(lClienteValue.CONTATO);

  if lResult.Count > 0 then
  begin
    Res.Send(TJSONObject.Create.AddPair('Message', 'Cliente possui cadastro').ToJSON).Status(THTTPStatus.BadRequest);
    exit;
  end;

  lResult := lController.CLIENTE.Save(lClienteValue);

  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('Message', 'Cliente salvo com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.Created)
  else
    Res.Send(TJSONObject.Create.AddPair('ERROR', 'Erro ao salvar Cliente').ToJSON).Status(THTTPStatus.BadRequest);
end;

procedure UpdateCliente(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody, lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lClienteFound,lClienteBody: TCLIENTE;
begin
  Res.ContentType('application/json;charset=UTF-8');
  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];

  if lValue.Length < 10 then
  begin
    if TryStrToInt(lValue, lID) then
      lBody := lController.CLIENTE.GetByID(lID);
  end
  else
    lBody := lController.CLIENTE.GetByContato(lValue);

  lClienteFound := TJSON.JsonToObject<TCLIENTE>(lBody);

  lClienteBody := TJSON.JsonToObject<TCLIENTE>(Req.Body);

  lClienteFound.NOME := lClienteBody.NOME;

  lResult := lController.CLIENTE.Update(lClienteFound);

  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('Message', 'Cliente atualizado com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send(TJSONObject.Create.AddPair('Message', 'Erro ao atualizar cliente!').ToJSON).Status(THTTPStatus.InternalServerError);
end;

procedure DeleteCliente(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody, lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lCliente: TCLIENTE;
begin
  Res.ContentType('application/json;charset=UTF-8');
  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];

  if lValue.Length < 10 then
  begin
    if TryStrToInt(lValue, lID) then
      lBody := lController.CLIENTE.GetByID(lID);
  end
  else
    lBody := lController.CLIENTE.GetByContato(lValue);

  if lBody.Count > 0 then
  begin
    lCliente := TJSON.JsonToObject<TCLIENTE>(lBody);
    lResult := lController.CLIENTE.Delete(lCliente.ID);
    if lResult.Count > 0 then
      Res.Send(lResult.ToJSON).Status(THTTPStatus.InternalServerError)
    else
      Res.Send(TJSONObject.Create.AddPair('Message', 'Cliente excluído!').ToJSON).Status(THTTPStatus.Accepted)
  end
  else
    Res.Send(TJSONObject.Create.AddPair('Message', 'Cliente não encontrado').ToJSON).Status(THTTPStatus.NotFound);
end;

procedure Registry;
begin
{(*}
  THorse
    .Group
      .Prefix('cliente')
    .Get('', GetClientes)
    .Post('', CreateCliente)
    .Get(':id', GetClienteByID)
    .Put(':id', UpdateCliente)
    .Delete(':id', DeleteCliente);
{*)}
end;

end.

