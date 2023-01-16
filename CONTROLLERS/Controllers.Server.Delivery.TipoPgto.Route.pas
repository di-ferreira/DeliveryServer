unit Controllers.Server.Delivery.TipoPgto.Route;

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

procedure GetTPPgtos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONArray;
  lController: iControllerServerDelivery;
begin
  Res.ContentType('application/json;charset=UTF-8');
  lController := TControllerServerDelivery.New;

  lBody := lController.TIPO_PGTO.GetAll;

  if lBody.Count > 0 then
    Res.Send(lBody.ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send<TJSONArray>(lBody).Status(THTTPStatus.NoContent);
end;

procedure GetTPPgtoByID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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
    lBody := lController.TIPO_PGTO.GetByID(lID)
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

procedure CreateTPPgto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONValue;
  lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lTPPgtoValue: TTIPOPGTO;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lBody := TJSONObject.ParseJSONValue(Req.Body);

  lTPPgtoValue := TJSON.JsonToObject<TTIPOPGTO>(lBody.ToJSON);

  lResult := lController.TIPO_PGTO.Save(lTPPgtoValue);

  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('message', 'Tipo de Pagamento adicionado com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.Created)
  else
    Res.Send(TJSONObject.Create.AddPair('error', 'Erro ao salvar Tipo de Pagamento').ToJSON).Status(THTTPStatus.BadRequest);
end;

procedure UpdateTPPgto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody, lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lTPPgtoFound,lTpPgtoBody: TTIPOPGTO;
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
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('message', 'Tipo de Pagamento atualizado com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send(TJSONObject.Create.AddPair('message', 'Erro ao atualizar Tipo de Pagamento!').ToJSON).Status(THTTPStatus.InternalServerError);
end;

procedure DeleteTPPgto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody, lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lTPPgto: TTIPOPGTO;
begin
  Res.ContentType('application/json;charset=UTF-8');
  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];

   if TryStrToInt(lValue, lID) then
      lBody := lController.TIPO_PGTO.GetByID(lID);

  if lBody.Count > 0 then
  begin
    lTPPgto := TJSON.JsonToObject<TTIPOPGTO>(lBody);
    lResult := lController.TIPO_PGTO.Delete(lTPPgto.ID);
    if lResult.Count > 0 then
      Res.Send(lResult.ToJSON).Status(THTTPStatus.InternalServerError)
    else
      Res.Send(TJSONObject.Create.AddPair('message', 'Tipo de Pagamento excluído com sucesso!').ToJSON).Status(THTTPStatus.OK)
  end
  else
    Res.Send(TJSONObject.Create.AddPair('message', 'Tipo de Pagamento não encontrado').ToJSON).Status(THTTPStatus.NotFound);
end;

procedure Registry;
begin
{(*}
  THorse
    .Group
      .Prefix('/tipos-pagamento')
    .Post('', CreateTPPgto)
    .Get('', GetTPPgtos)
    .Get(':id', GetTPPgtoByID)
    .Put(':id', UpdateTPPgto)
    .Delete(':id', DeleteTPPgto);
{*)}
end;

end.

