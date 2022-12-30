unit Controllers.Server.Delivery.Endereco.Route;

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

procedure GetEnderecos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONArray;
  lController: iControllerServerDelivery;
begin
  lController := TControllerServerDelivery.New;

  lBody := lController.CLIENTE.GetAll;

  if lBody.Count > 0 then
    Res.Send(lBody.ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send(lBody.ToJSON).Status(THTTPStatus.NoContent);
end;

procedure GetEnderecosByID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody: TJSONObject;
  lController: iControllerServerDelivery;
begin
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

procedure CreateEndereco(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONValue;
  lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lCliente:TCLIENTE;
  lEnderecoValue: TENDERECO;
begin
  Res.ContentType('application/json;charset=UTF-8');
  lController := TControllerServerDelivery.New;
  lBody := TJSONObject.ParseJSONValue(Req.Body);
  lEnderecoValue := TENDERECO.Create;
  lCliente := TJSON.JsonToObject<TCLIENTE>(lController.CLIENTE.GetByContato(Req.Params['id_cliente']));
  lEnderecoValue.CLIENTE := lCliente;
  lEnderecoValue.ID := lBody.GetValue<integer>('ID');
  lEnderecoValue.RUA := lBody.GetValue<string>('RUA');
  lEnderecoValue.NUMERO := lBody.GetValue<string>('NUMERO');
  lEnderecoValue.BAIRRO := lBody.GetValue<string>('BAIRRO');
  lEnderecoValue.COMPLEMENTO := lBody.GetValue<string>('COMPLEMENTO');
  lEnderecoValue.CIDADE := lBody.GetValue<string>('CIDADE');
  lEnderecoValue.ESTADO := lBody.GetValue<string>('ESTADO');

  lResult := lController.ENDERECO.Save(lEnderecoValue);

  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('Message', 'Endereço adicionado com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.Created)
  else
    Res.Send(TJSONObject.Create.AddPair('ERROR', 'Erro ao salvar Endereço!').ToJSON).Status(THTTPStatus.BadRequest);
end;

procedure UpdateEnderecos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody: TJSONObject;
  lController: iControllerServerDelivery;
  lClienteUpdated: TCLIENTE;
begin
  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];

  if lValue.Length < 10 then
  begin
    if TryStrToInt(lValue, lID) then
      lBody := lController.CLIENTE.GetByID(lID);
  end
  else
    lBody := lController.CLIENTE.GetByContato(lValue);

  lClienteUpdated := TJSON.JsonToObject<TCLIENTE>(Req.Body);

  if lBody.Count > 0 then
    Res.Send(lController.CLIENTE.Update(lClienteUpdated).ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send(TJSONObject.Create.AddPair('RESULT', 'Cliente não encontrado').ToJSON).Status(THTTPStatus.NotFound);
end;

procedure DeleteEnderecos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody, lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lCliente: TCLIENTE;
begin
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
      Res.Send(TJSONObject.Create.AddPair('RESULT', 'Cliente excluído!').ToJSON).Status(THTTPStatus.Accepted)
  end
  else
    Res.Send(TJSONObject.Create.AddPair('RESULT', 'Cliente não encontrado').ToJSON).Status(THTTPStatus.NotFound);
end;

procedure Registry;
begin
{(*}
  THorse
    .Group
      .Prefix('cliente/:id_cliente/endereco')
    .Get('', GetEnderecos)
    .Post('', CreateEndereco)
    .Get(':id', GetEnderecosByID)
    .Put(':id', UpdateEnderecos)
    .Delete(':id', DeleteEnderecos);

    THorse
    .Group
      .Prefix('endereco')
    .Get(':id', GetEnderecosByID);
{*)}
end;

end.

