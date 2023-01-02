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
  lID_CLIENTE: Integer;
  lCliente, lResult: TJSONObject;
  lValue: string;
  lController: iControllerServerDelivery;
  lClienteValue: TCLIENTE;
begin
  Res.ContentType('application/json;charset=UTF-8');
  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id_cliente'];

  if lValue.Length < 10 then
  begin
    if TryStrToInt(lValue, lID_CLIENTE) then
      lCliente := lController.CLIENTE.GetByID(lID_CLIENTE);
  end
  else
    lCliente := lController.CLIENTE.GetByContato(lValue);

  lClienteValue := TJSON.JsonToObject<TCLIENTE>(lCliente.ToJSON);

  lResult := lCliente.AddPair('ENDERECOS', lController.ENDERECO.GetAll(lClienteValue.ID));

  if lResult.Count > 0 then
    Res.Send(lResult.ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send(lResult.ToJSON).Status(THTTPStatus.NoContent);
end;

procedure GetEnderecosByID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lParamID: string;
  lResult: TJSONObject;
  lCliente: TCLIENTE;
  lEnderecoValue: TENDERECO;
  lController: iControllerServerDelivery;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lParamID := Req.Params['id'];

  if TryStrToInt(lParamID, lID) then
    lResult := lController.ENDERECO.GetByID(lID)
  else
  begin
    Res.Send(TJSONObject.Create().AddPair('Message', 'ID inválida').ToJSON).Status(THTTPStatus.NotFound);
    exit;
  end;

  if lResult.Count > 0 then
  begin
    lResult.AddPair('cliente', lController.CLIENTE.GetByID(lResult.GetValue<integer>('idCliente')));

    lResult.RemovePair('idCliente');

    Res.Send(lResult.ToJSON).Status(THTTPStatus.OK);
  end
  else
    Res.Send(TJSONObject.Create().AddPair('Message', 'Endereço não encontrado!').ToJSON).Status(THTTPStatus.NotFound);
end;

procedure CreateEndereco(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONValue;
  lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lCliente: TCLIENTE;
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
    Res.Send(TJSONObject.Create.AddPair('Message', 'Erro ao salvar Endereço!').ToJSON).Status(THTTPStatus.BadRequest);
end;

procedure UpdateEnderecos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lParamID: string;
  lBody: TJSONValue;
  lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lCliente: TCLIENTE;
  lEnderecoValue: TENDERECO;
begin
  Res.ContentType('application/json;charset=UTF-8');
  lController := TControllerServerDelivery.New;
  lParamID := Req.Params['id'];

  if TryStrToInt(lParamID, lID) then
  begin
    lBody := TJSONObject.ParseJSONValue(Req.Body);
    lEnderecoValue := TENDERECO.Create;
    lEnderecoValue.ID := lID;
    lEnderecoValue.RUA := lBody.GetValue<string>('RUA');
    lEnderecoValue.NUMERO := lBody.GetValue<string>('NUMERO');
    lEnderecoValue.BAIRRO := lBody.GetValue<string>('BAIRRO');
    lEnderecoValue.COMPLEMENTO := lBody.GetValue<string>('COMPLEMENTO');
    lEnderecoValue.CIDADE := lBody.GetValue<string>('CIDADE');
    lEnderecoValue.ESTADO := lBody.GetValue<string>('ESTADO');

    lResult := lController.ENDERECO.Update(lEnderecoValue);

    lResult.AddPair('cliente', lController.CLIENTE.GetByID(lResult.GetValue<integer>('idCliente')));

    lResult.RemovePair('idCliente');
  end
  else
  begin
    Res.Send(TJSONObject.Create.AddPair('Message', 'Endereço não encontrado').ToJSON).Status(THTTPStatus.NotFound);
    exit;
  end;


  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('Message', 'Endereço atualizado com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send(TJSONObject.Create.AddPair('Message', 'Erro ao atualizar Endereço!').ToJSON).Status(THTTPStatus.BadRequest);
end;

procedure DeleteEnderecos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody, lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lEndereco: TENDERECO;
begin
  Res.ContentType('application/json;charset=UTF-8');
  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];

  if TryStrToInt(lValue, lID) then
      lBody := lController.ENDERECO.GetByID(lID);

  if lBody.Count > 0 then
  begin
    lEndereco := TJSON.JsonToObject<TENDERECO>(lBody);

    lResult := lController.ENDERECO.Delete(lEndereco.ID);

    if lResult.Count > 0 then
      Res.Send(lResult.ToJSON).Status(THTTPStatus.InternalServerError)
    else
      Res.Send(TJSONObject.Create.AddPair('Message', 'Endereço excluído!').ToJSON).Status(THTTPStatus.Accepted)
  end
  else
    Res.Send(TJSONObject.Create.AddPair('Message', 'Endereço não encontrado').ToJSON).Status(THTTPStatus.NotFound);
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
    .Get(':id', GetEnderecosByID)
    .Put(':id', UpdateEnderecos)
    .Delete(':id', DeleteEnderecos);
{*)}
end;

end.

