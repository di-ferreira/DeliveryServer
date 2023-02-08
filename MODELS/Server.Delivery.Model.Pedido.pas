unit Server.Delivery.Model.Pedido;

interface

uses
  System.Generics.Collections, System.SysUtils, System.JSON, REST.Json,
  DataSet.Serialize,
  {FIREDAC CONNECTION}
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait,
  FireDAC.Comp.UI, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
  {Interfaces}
  Server.Delivery.DTO, Server.Delivery.Model.Interfaces,
  Server.Delivery.SQLite.Connection;

type
  TModelServerDeliveryPedido = class(TInterfacedObject, iModelServerDeliveryPedido<TPEDIDO>)
  private
    FConnection: iModelServerDeliveryConnection;
    FQuery: TFDQuery;
    FSQL: string;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iModelServerDeliveryPedido<TPEDIDO>;
    function Save(aValue: TPEDIDO): TJSONObject;
    function CreateWithItems(aValue: TPEDIDO): TJSONObject;
    function GetAll: TJSONArray;
    function GetByID(aID: Integer): TJSONObject;
    function GetByCaixa(aIDCaixa: Integer): TJSONArray;
    function GetByCliente(aIDCliente: Integer): TJSONArray;
    function Update(aValue: TPEDIDO): TJSONObject;
    function Delete(aID: Integer): TJSONObject;
  end;

implementation

uses
  Server.Delivery.Controller.Interfaces, Server.Delivery.Controller;
{ TModelServerDeliveryPedido }

constructor TModelServerDeliveryPedido.Create;
begin
  FConnection := TServerDeliverySQLiteConnection.New;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection.Connection;
  FConnection.Connection.TxOptions.AutoCommit := False;
end;

function TModelServerDeliveryPedido.CreateWithItems(aValue: TPEDIDO): TJSONObject;
var
  CaixaJSON, ClienteJSON, EnderecoJSON, PedidoJSON, PedidoResultJSON, lItemJSON: TJSONObject;
  lItem: TITEM_PEDIDO;
  lItemsJSONResult: TJSONArray;
  lController: iControllerServerDelivery;
begin
  lController := TControllerServerDelivery.New;

  CaixaJSON := TJSONObject.Create;
  ClienteJSON := TJSONObject.Create;
  EnderecoJSON := TJSONObject.Create;
  PedidoJSON := TJSONObject.Create;
  PedidoResultJSON := TJSONObject.Create;

  CaixaJSON := lController.CAIXA.GetOpen;

  FSQL := 'INSERT INTO PEDIDOS ("DATA", TOTAL, CANCELADO, ABERTO, OBS, CAIXA, CLIENTE, ENDERECO_ENTREGA) VALUES(CURRENT_TIMESTAMP, :TOTAL, :CANCELADO, :ABERTO, :OBS, :CAIXA, :CLIENTE, :ENDERECO_ENTREGA);';

  try
    with FQuery do
    begin
      Connection.StartTransaction;
      SQL.Text := FSQL;
      ParamByName('TOTAL').Value := aValue.TOTAL;
      ParamByName('CANCELADO').Value := aValue.CANCELADO;
      ParamByName('ABERTO').Value := aValue.ABERTO;
      ParamByName('OBS').Value := aValue.OBS;
      ParamByName('CAIXA').Value := CaixaJSON.GetValue<integer>('id');
      ParamByName('CLIENTE').Value := aValue.CLIENTE.ID;
      ParamByName('ENDERECO_ENTREGA').Value := aValue.ENDERECO_ENTREGA.ID;
      ExecSQL;

      lItemsJSONResult := TJSONArray.Create;

      for lItem in aValue.ITEMS do
      begin
        SQL.Clear;
        FSQL := 'INSERT INTO ITEMS_PEDIDO (TOTAL, QUANTIDADE, ITEM_CARDAPIO, PEDIDO) VALUES (:TOTAL, :QUANTIDADE, :ITEM_CARDAPIO, (SELECT ID FROM PEDIDOS ORDER BY ID DESC LIMIT 1));';
        SQL.Text := FSQL;
        ParamByName('TOTAL').AsCurrency := lItem.TOTAL;
        ParamByName('QUANTIDADE').AsInteger := lItem.QUANTIDADE;
        ParamByName('ITEM_CARDAPIO').AsInteger := lItem.ITEM_CARDAPIO.ID;
        ExecSQL;

        Close;
        SQL.Clear;
        FSQL := 'SELECT ID FROM ITEMS_PEDIDO ORDER BY ID DESC LIMIT 1;';
        SQL.Text := FSQL;
        Open;

        lItemJSON := TJSONObject.Create;
        lItemJSON.AddPair('id', FQuery.FieldByName('ID').AsInteger);
        lItemJSON.AddPair('total', lItem.TOTAL);
        lItemJSON.AddPair('quantidade', lItem.QUANTIDADE);
        lItemJSON.AddPair('itemCardapio', lController.CARDAPIO.GetByID(lItem.ITEM_CARDAPIO.ID));

        lItemsJSONResult.Add(lItemJSON);
      end;

      Connection.Commit;

      FSQL := 'SELECT ID, "DATA" AS DATA_PEDIDO, TOTAL, CANCELADO, ABERTO, OBS, CAIXA, CLIENTE, ENDERECO_ENTREGA FROM PEDIDOS ORDER BY ID DESC LIMIT 1;';

      Close;
      SQL.Text := FSQL;
      Open;
      PedidoJSON := FQuery.ToJSONObject();

      ClienteJSON := lController.CLIENTE.GetByID(PedidoJSON.GetValue<integer>('cliente'));

      EnderecoJSON := lController.ENDERECO.GetByID(PedidoJSON.GetValue<integer>('enderecoEntrega'));

      CaixaJSON := lController.CAIXA.GetOpen;

      PedidoResultJSON.AddPair('id', PedidoJSON.GetValue<integer>('id')).AddPair('dataPedido', FormatDateTime('dd-mm-yy hh:mm:ss', PedidoJSON.GetValue<TDateTime>('dataPedido'))).AddPair('items', lItemsJSONResult).AddPair('total', PedidoJSON.GetValue<Double>('total')).AddPair('cancelado', PedidoJSON.GetValue<Boolean>('cancelado')).AddPair('aberto', PedidoJSON.GetValue<Boolean>('aberto')).AddPair('obs', PedidoJSON.GetValue<string>('obs')).AddPair('cliente', ClienteJSON).AddPair('enderecoEntrega', EnderecoJSON).AddPair('caixa', CaixaJSON);
    end;
    Result := PedidoResultJSON;
  except

    on E: Exception do
    begin
      with FQuery do
      begin
        Connection.Rollback;
        Result := TJSONObject.Create;
      end;
    end;
  end;
end;

function TModelServerDeliveryPedido.Delete(aID: Integer): TJSONObject;
begin
  FSQL := 'DELETE FROM PRODUTOS WHERE id = :id';
  with FQuery do
  begin
    SQL.Text := FSQL;
    Connection.StartTransaction;
    try
      ParamByName('id').Value := aID;
      ExecSQL;
      Connection.Commit;
      Result := TJSONObject.Create;
    except
      on E: Exception do
      begin
        Connection.Rollback;
        Result := TJSONObject.Create.AddPair('result', E.Message);
      end;
    end;
  end;
end;

destructor TModelServerDeliveryPedido.Destroy;
begin
  FreeAndNil(FQuery);
  inherited;
end;

function TModelServerDeliveryPedido.GetAll: TJSONArray;
var
  CaixaJSON, ClienteJSON, EnderecoJSON, PedidoJSON, lItemJSON: TJSONObject;
  lItemsJSONResult, PedidoJSONSearch, PedidoJSONResult: TJSONArray;
  lController: iControllerServerDelivery;
  I, J: Integer;
begin
  lController := TControllerServerDelivery.New;

  CaixaJSON := TJSONObject.Create;
  ClienteJSON := TJSONObject.Create;
  EnderecoJSON := TJSONObject.Create;

  FSQL := 'SELECT ID, "DATA" AS DATA_PEDIDO, TOTAL, CANCELADO, ABERTO, OBS, CAIXA, CLIENTE, ENDERECO_ENTREGA FROM PEDIDOS;';

  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    Open;
    PedidoJSONSearch := FQuery.ToJSONArray();
    PedidoJSONResult := TJSONArray.Create;
    lItemsJSONResult := TJSONArray.Create;

    for I := 0 to Pred(PedidoJSONSearch.Count) do
    begin
      lItemsJSONResult := lController.ITEM_PEDIDO.GetByPedido(PedidoJSONSearch.Items[I].GetValue<integer>('id'));

      ClienteJSON := lController.CLIENTE.GetByID(PedidoJSONSearch.Items[I].GetValue<integer>('cliente'));

      EnderecoJSON := lController.ENDERECO.GetByID(PedidoJSONSearch.Items[I].GetValue<integer>('enderecoEntrega'));

      CaixaJSON := lController.CAIXA.GetByID(PedidoJSONSearch.Items[I].GetValue<integer>('caixa'));

      PedidoJSON := TJSONObject.Create;
      PedidoJSON.AddPair('id', PedidoJSONSearch.Items[I].GetValue<integer>('id')).AddPair('dataPedido', FormatDateTime('dd-mm-yy hh:mm:ss', PedidoJSONSearch.Items[I].GetValue<TDateTime>('dataPedido'))).AddPair('items', lItemsJSONResult).AddPair('total', PedidoJSONSearch.Items[I].GetValue<Double>('total')).AddPair('cancelado', PedidoJSONSearch.Items[I].GetValue<Boolean>('cancelado')).AddPair('aberto', PedidoJSONSearch.Items[I].GetValue<Boolean>('aberto')).AddPair('obs', PedidoJSONSearch.Items[I].GetValue<string>('obs')).AddPair('cliente', ClienteJSON).AddPair('enderecoEntrega', EnderecoJSON).AddPair('caixa', CaixaJSON);

      PedidoJSONResult.Add(PedidoJSON);
    end;
  end;

  Result := PedidoJSONResult;
end;

function TModelServerDeliveryPedido.GetByCaixa(aIDCaixa: Integer): TJSONArray;
begin

end;

function TModelServerDeliveryPedido.GetByCliente(aIDCliente: Integer): TJSONArray;
begin

end;

function TModelServerDeliveryPedido.GetByID(aID: Integer): TJSONObject;
var
  CaixaJSON,
  ClienteJSON,
  EnderecoJSON,
  PedidoJSON,
  lItemJSON,
  PedidoJSONSearch: TJSONObject;
  lItemsJSONResult: TJSONArray;
  lController: iControllerServerDelivery;
  I, J: Integer;
begin
  lController := TControllerServerDelivery.New;

  CaixaJSON := TJSONObject.Create;
  ClienteJSON := TJSONObject.Create;
  EnderecoJSON := TJSONObject.Create;

  FSQL := 'SELECT ID, "DATA" AS DATA_PEDIDO, TOTAL, CANCELADO, ABERTO, OBS, CAIXA, CLIENTE, ENDERECO_ENTREGA FROM PEDIDOS WHERE ID = :ID;';

  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('ID').Value := aID;
    Open;
    PedidoJSONSearch := FQuery.ToJSONObject();

    lItemsJSONResult := TJSONArray.Create;


      lItemsJSONResult := lController.ITEM_PEDIDO.GetByPedido(PedidoJSONSearch.GetValue<integer>('id'));

      ClienteJSON := lController.CLIENTE.GetByID(PedidoJSONSearch.GetValue<integer>('cliente'));

      EnderecoJSON := lController.ENDERECO.GetByID(PedidoJSONSearch.GetValue<integer>('enderecoEntrega'));

      CaixaJSON := lController.CAIXA.GetByID(PedidoJSONSearch.GetValue<integer>('caixa'));

      PedidoJSON := TJSONObject.Create;
      PedidoJSON.AddPair('id', PedidoJSONSearch.GetValue<integer>('id')).AddPair('dataPedido', FormatDateTime('dd-mm-yy hh:mm:ss', PedidoJSONSearch.GetValue<TDateTime>('dataPedido'))).AddPair('items', lItemsJSONResult).AddPair('total', PedidoJSONSearch.GetValue<Double>('total')).AddPair('cancelado', PedidoJSONSearch.GetValue<Boolean>('cancelado')).AddPair('aberto', PedidoJSONSearch.GetValue<Boolean>('aberto')).AddPair('obs', PedidoJSONSearch.GetValue<string>('obs')).AddPair('cliente', ClienteJSON).AddPair('enderecoEntrega', EnderecoJSON).AddPair('caixa', CaixaJSON);
  end;

  Result := PedidoJSON;
end;

class function TModelServerDeliveryPedido.New: iModelServerDeliveryPedido<TPEDIDO>;
begin
  Result := Self.Create;
end;

function TModelServerDeliveryPedido.Save(aValue: TPEDIDO): TJSONObject;
var
  CaixaJSON, ClienteJSON, EnderecoJSON, PedidoJSON, PedidoResultJSON: TJSONObject;
begin
  FSQL := 'INSERT INTO PEDIDOS ("DATA", TOTAL, CANCELADO, ABERTO, OBS, CAIXA, CLIENTE, ENDERECO_ENTREGA) VALUES(CURRENT_TIMESTAMP, :TOTAL, :CANCELADO, :ABERTO, :OBS, :CAIXA, :CLIENTE, :ENDERECO_ENTREGA);';

  try
    with FQuery do
    begin
      Connection.StartTransaction;
      SQL.Text := FSQL;
      ParamByName('TOTAL').Value := aValue.TOTAL;
      ParamByName('CANCELADO').Value := aValue.CANCELADO;
      ParamByName('ABERTO').Value := aValue.ABERTO;
      ParamByName('OBS').Value := aValue.OBS;
      ParamByName('CAIXA').Value := aValue.CAIXA.ID;
      ParamByName('CLIENTE').Value := aValue.CLIENTE.ID;
      ParamByName('ENDERECO_ENTREGA').Value := aValue.ENDERECO_ENTREGA.ID;
      ExecSQL;

      CaixaJSON := TJSONObject.Create;
      ClienteJSON := TJSONObject.Create;
      EnderecoJSON := TJSONObject.Create;
      PedidoJSON := TJSONObject.Create;
      PedidoResultJSON := TJSONObject.Create;

      FSQL := 'SELECT ID, "DATA" AS DATA_PEDIDO, TOTAL, CANCELADO, ABERTO, OBS, CAIXA, CLIENTE, ENDERECO_ENTREGA FROM PEDIDOS ORDER BY ID DESC LIMIT 1;';

      Close;
      SQL.Text := FSQL;
      Open;
      PedidoJSON := FQuery.ToJSONObject();

      FSQL := 'SELECT ID, "DATA" AS DATA_ABERTURA, ABERTO, TOTAL FROM CAIXAS WHERE ID = :ID;';

      Close;
      SQL.Text := FSQL;
      ParamByName('ID').Value := PedidoJSON.GetValue<integer>('caixa');
      Open;
      CaixaJSON := FQuery.ToJSONObject();

      FSQL := 'SELECT id AS ID, nome AS NOME, contato AS CONTATO FROM CLIENTES WHERE ID = :ID;';

      Close;
      SQL.Text := FSQL;
      ParamByName('ID').Value := PedidoJSON.GetValue<integer>('cliente');
      Open;
      ClienteJSON := FQuery.ToJSONObject();

      FSQL := 'SELECT ID, RUA, NUMERO, BAIRRO, COMPLEMENTO, CIDADE, ESTADO FROM ENDERECOS WHERE ID = :ID;';

      Close;
      SQL.Text := FSQL;
      ParamByName('ID').Value := PedidoJSON.GetValue<integer>('enderecoEntrega');
      Open;
      EnderecoJSON := FQuery.ToJSONObject();

      PedidoResultJSON.AddPair('id', PedidoJSON.GetValue<integer>('id')).AddPair('dataPedido', FormatDateTime('dd-mm-yy hh:mm:ss', PedidoJSON.GetValue<TDateTime>('dataPedido'))).AddPair('total', PedidoJSON.GetValue<Double>('total')).AddPair('cancelado', PedidoJSON.GetValue<Boolean>('cancelado')).AddPair('aberto', PedidoJSON.GetValue<Boolean>('aberto')).AddPair('obs', PedidoJSON.GetValue<string>('obs')).AddPair('cliente', ClienteJSON).AddPair('enderecoEntrega', EnderecoJSON).AddPair('caixa', CaixaJSON);

      Connection.Commit;
    end;
    Result := PedidoResultJSON;
  except

    on E: Exception do
    begin
      with FQuery do
      begin
        Connection.Rollback;
        Result := TJSONObject.Create;
      end;
    end;
  end;
end;

function TModelServerDeliveryPedido.Update(aValue: TPEDIDO): TJSONObject;
var
  aPedido:TJSONObject;
  aTipoPgto:TTIPOPGTO;
begin
  FSQL := 'UPDATE PEDIDOS SET TOTAL=:TOTAL, CANCELADO=:CANCELADO, ABERTO=:ABERTO, OBS=:OBS, ENDERECO_ENTREGA=:ENDERECO_ENTREGA WHERE ID=:ID;';
  try
    with FQuery do
    begin
      Connection.StartTransaction;
      SQL.Text := FSQL;

      ParamByName('ID').Value := aValue.ID;
      ParamByName('TOTAL').Value := aValue.TOTAL;
      ParamByName('CANCELADO').Value := aValue.CANCELADO;
      ParamByName('ABERTO').Value := aValue.ABERTO;
      ParamByName('OBS').Value := aValue.OBS;
      ParamByName('ENDERECO_ENTREGA').Value := aValue.ENDERECO_ENTREGA.ID;
      ExecSQL;

      if aValue.TIPO_PAGAMENTO.Count > 0 then
      begin
      for aTipoPgto in aValue.TIPO_PAGAMENTO do
        begin
          FSQL := 'INSERT INTO PEDIDOS_TIPOS_PAGAMENTOS (ID_PEDIDO, ID_TIPO_PAGAMENTO) VALUES(:ID_PEDIDO, :ID_TIPO_PAGAMENTO);';
          SQL.Text := FSQL;

          ParamByName('ID_PEDIDO').Value := aValue.ID;
          ParamByName('ID_TIPO_PAGAMENTO').Value := aTipoPgto.ID;
          ExecSQL;
        end;
      end;

      Connection.Commit;

      aPedido := TJSONObject.Create;

      aPedido := Self.GetByID(aValue.ID);
    end;
    Result := aPedido;
  except
    on E: Exception do
    begin
      with FQuery do
      begin
        Connection.Rollback;
        Result := TJSONObject.Create;
      end;
    end;
  end;
end;

end.

