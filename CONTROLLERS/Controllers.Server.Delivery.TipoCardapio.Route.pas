unit Controllers.Server.Delivery.TipoCardapio.Route;

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

procedure GetTPCardapios(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONArray;
  lController: iControllerServerDelivery;
begin
  Res.ContentType('application/json;charset=UTF-8');
  lController := TControllerServerDelivery.New;

  lBody := lController.TIPO_CARDAPIO.GetAll;

  if lBody.Count > 0 then
    Res.Send(lBody.ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send<TJSONArray>(lBody).Status(THTTPStatus.NoContent);
end;

procedure GetTPCardapioByID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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
    lBody := lController.TIPO_CARDAPIO.GetByID(lID)
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

procedure CreateTPCardapio(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONValue;
  lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lTPCardapioValue: TTIPO_CARDAPIO;
begin
  Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lBody := TJSONObject.ParseJSONValue(Req.Body);

  lTPCardapioValue := TJSON.JsonToObject<TTIPO_CARDAPIO>(lBody.ToJSON);

  lResult := lController.TIPO_CARDAPIO.Save(lTPCardapioValue);

  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('message', 'Tipo de Cardápio adicionado com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.Created)
  else
    Res.Send(TJSONObject.Create.AddPair('error', 'Erro ao salvar Tipo de Cardápio').ToJSON).Status(THTTPStatus.BadRequest);
end;

procedure UpdateTPCardapio(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody, lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lTPCardapioFound,lTpCardapioBody: TTIPO_CARDAPIO;
begin
   Res.ContentType('application/json;charset=UTF-8');

  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];

  if TryStrToInt(lValue, lID) then
  begin
    lBody := lController.TIPO_CARDAPIO.GetByID(lID);
  end
  else
  begin
    Res.Send(TJSONObject.Create().AddPair('Message', 'ID inválida').ToJSON).Status(THTTPStatus.NotFound);
    exit;
  end;

  lTPCardapioFound := TJSON.JsonToObject<TTIPO_CARDAPIO>(lBody);

  lTpCardapioBody := TJSON.JsonToObject<TTIPO_CARDAPIO>(Req.Body);

  lTPCardapioFound.DESCRICAO := lTpCardapioBody.DESCRICAO;

  lResult := lController.TIPO_CARDAPIO.Update(lTPCardapioFound);

  if lResult.Count > 0 then
    Res.Send(TJSONArray.Create().Add(TJSONObject.Create.AddPair('message', 'Tipo de Cardápio atualizado com sucesso!')).Add(lResult).ToJSON).Status(THTTPStatus.OK)
  else
    Res.Send(TJSONObject.Create.AddPair('message', 'Erro ao atualizar Tipo de Cardápio!').ToJSON).Status(THTTPStatus.InternalServerError);
end;

procedure DeleteTPCardapio(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lID: Integer;
  lValue: string;
  lBody, lResult: TJSONObject;
  lController: iControllerServerDelivery;
  lTPCardapio: TTIPO_CARDAPIO;
begin
  Res.ContentType('application/json;charset=UTF-8');
  lController := TControllerServerDelivery.New;
  lValue := Req.Params['id'];

   if TryStrToInt(lValue, lID) then
      lBody := lController.TIPO_CARDAPIO.GetByID(lID);

  if lBody.Count > 0 then
  begin
    lTPCardapio := TJSON.JsonToObject<TTIPO_CARDAPIO>(lBody);
    lResult := lController.TIPO_CARDAPIO.Delete(lTPCardapio.ID);
    if lResult.Count > 0 then
      Res.Send(lResult.ToJSON).Status(THTTPStatus.InternalServerError)
    else
      Res.Send(TJSONObject.Create.AddPair('message', 'Tipo de Cardápio excluído com sucesso!').ToJSON).Status(THTTPStatus.OK)
  end
  else
    Res.Send(TJSONObject.Create.AddPair('message', 'Tipo de Cardápio não encontrado').ToJSON).Status(THTTPStatus.NotFound);
end;

procedure Registry;
begin
{(*}
  THorse
    .Group
      .Prefix('/cardapios/tipos')
    .Post('', CreateTPCardapio)
    .Get('', GetTPCardapios)
    .Get(':id', GetTPCardapioByID)
    .Put(':id', UpdateTPCardapio)
    .Delete(':id', DeleteTPCardapio);
{*)}
end;

end.

