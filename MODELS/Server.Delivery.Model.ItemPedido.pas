unit Server.Delivery.Model.ItemPedido;

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
  TModelServerDeliveryItemPedido = class(TInterfacedObject, iModelServerDeliveryItemPedido<TITEM_PEDIDO>)
  private
    FConnection: iModelServerDeliveryConnection;
    FQuery: TFDQuery;
    FSQL: string;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iModelServerDeliveryItemPedido<TITEM_PEDIDO>;
    function Save(aValue: TITEM_PEDIDO): TJSONObject;
    function GetAll: TJSONArray;
    function GetByID(aID: Integer): TJSONObject;
    function GetByPedido(aIDPedido: Integer): TJSONArray;
    function Update(aValue: TITEM_PEDIDO): TJSONObject;
    function Delete(aID: Integer): TJSONObject;
  end;

implementation

uses
  Server.Delivery.Controller.Interfaces, Server.Delivery.Controller;

{ TModelServerDeliveryItemPedido }

constructor TModelServerDeliveryItemPedido.Create;
begin
  FConnection := TServerDeliverySQLiteConnection.New;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection.Connection;
  FConnection.Connection.TxOptions.AutoCommit := False;
end;

function TModelServerDeliveryItemPedido.Delete(aID: Integer): TJSONObject;
begin
  FSQL := 'DELETE FROM ITEMS_PEDIDO WHERE id = :id';
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

destructor TModelServerDeliveryItemPedido.Destroy;
begin
  FreeAndNil(FQuery);
  inherited;
end;

function TModelServerDeliveryItemPedido.GetAll: TJSONArray;
begin
  FSQL := 'SELECT ID, NOME, ESTOQUE, CUSTO, PERCENTUAL_LUCRO AS LUCRO FROM PRODUTOS';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    Open;
  end;
  Result := FQuery.ToJSONArray();
end;

function TModelServerDeliveryItemPedido.GetByID(aID: Integer): TJSONObject;
var
  lItemJSON: TJSONObject;
  lController: iControllerServerDelivery;
begin
  lController := TControllerServerDelivery.New;
  FSQL := 'SELECT ID, TOTAL, QUANTIDADE, ITEM_CARDAPIO, PEDIDO FROM ITEMS_PEDIDO WHERE ID=:ID';
  with FQuery do
  begin
    SQL.Text := FSQL;
    ParamByName('ID').Value := aID;
    Open;

    lItemJSON := TJSONObject.Create;
    lItemJSON.AddPair('id', FQuery.FieldByName('ID').AsInteger);
    lItemJSON.AddPair('total', FQuery.FieldByName('TOTAL').AsFloat);
    lItemJSON.AddPair('quantidade', FQuery.FieldByName('QUANTIDADE').AsInteger);
    lItemJSON.AddPair('itemCardapio', lController.CARDAPIO.GetByID(FQuery.FieldByName('ITEM_CARDAPIO').AsInteger));
    lItemJSON.AddPair('pedido', lController.PEDIDO.GetByID(FQuery.FieldByName('PEDIDO').AsInteger));
    Open;
  end;
  Result := lItemJSON;
end;

function TModelServerDeliveryItemPedido.GetByPedido(aIDPedido: Integer): TJSONArray;
var
  lItems, lItemsResult: TJSONArray;
  lItem: TJSONObject;
  lController: iControllerServerDelivery;
  I: Integer;
  s, sID: string;
begin
  FSQL := 'SELECT ID, TOTAL, QUANTIDADE, ITEM_CARDAPIO, PEDIDO FROM ITEMS_PEDIDO WHERE PEDIDO = :PEDIDO;';

  lItems := TJSONArray.Create;
  lItemsResult := TJSONArray.Create;
  lController := TControllerServerDelivery.New;

  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('PEDIDO').Value := aIDPedido;
    Open;
  end;

  lItems := FQuery.ToJSONArray();


  for I := 0 to Pred(lItems.Count) do
  begin
    lItem := TJSONObject.Create;
    lItem.AddPair('id', lItems.Items[I].GetValue<integer>('id'));
    lItem.AddPair('total', lItems.Items[I].GetValue<Double>('total'));
    lItem.AddPair('quantidade', lItems.Items[I].GetValue<integer>('quantidade'));
    lItem.AddPair('itemCardapio', lController.CARDAPIO.GetByID(lItems.Items[I].GetValue<integer>('itemCardapio')));

    lItemsResult.Add(lItem);
  end;

  Result := lItemsResult;
end;

class function TModelServerDeliveryItemPedido.New: iModelServerDeliveryItemPedido<TITEM_PEDIDO>;
begin
  Result := Self.Create;
end;

function TModelServerDeliveryItemPedido.Save(aValue: TITEM_PEDIDO): TJSONObject;
var
  lItemJSON: TJSONObject;
  lController: iControllerServerDelivery;
begin
  lController := TControllerServerDelivery.New;
  FSQL := 'INSERT INTO ITEMS_PEDIDO (TOTAL, QUANTIDADE, ITEM_CARDAPIO, PEDIDO) VALUES(:TOTAL, :QUANTIDADE, :ITEM_CARDAPIO, :PEDIDO);';

  try
    with FQuery do
    begin
      Connection.StartTransaction;
      SQL.Text := FSQL;
      ParamByName('TOTAL').Value := aValue.TOTAL;
      ParamByName('QUANTIDADE').Value := aValue.QUANTIDADE;
      ParamByName('ITEM_CARDAPIO').Value := aValue.ITEM_CARDAPIO.ID;
      ParamByName('PEDIDO').Value := aValue.PEDIDO.ID;
      ExecSQL;
      Connection.Commit;

      FSQL := 'SELECT ID, TOTAL, QUANTIDADE, ITEM_CARDAPIO, PEDIDO FROM ITEMS_PEDIDO ORDER BY ID DESC LIMIT 1;';
      SQL.Text := FSQL;
      Open;

      lItemJSON := TJSONObject.Create;
      lItemJSON.AddPair('id', FQuery.FieldByName('ID').AsInteger);
      lItemJSON.AddPair('total', FQuery.FieldByName('TOTAL').AsFloat);
      lItemJSON.AddPair('quantidade', FQuery.FieldByName('QUANTIDADE').AsInteger);
      lItemJSON.AddPair('itemCardapio', lController.CARDAPIO.GetByID(FQuery.FieldByName('ITEM_CARDAPIO').AsInteger));
    end;
    Result := lItemJSON;
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

function TModelServerDeliveryItemPedido.Update(aValue: TITEM_PEDIDO): TJSONObject;
var
  lItemJSON: TJSONObject;
  lController: iControllerServerDelivery;
begin
  lController := TControllerServerDelivery.New;
  FSQL := 'UPDATE ITEMS_PEDIDO SET QUANTIDADE = :QUANTIDADE, TOTAL = :TOTAL WHERE ID = :ID';
  try
    with FQuery do
    begin
      Connection.StartTransaction;
      SQL.Text := FSQL;

      ParamByName('ID').Value := aValue.ID;
      ParamByName('QUANTIDADE').Value := aValue.QUANTIDADE;
      ParamByName('TOTAL').Value := aValue.TOTAL;
      ExecSQL;
      Connection.Commit;

      FSQL := 'SELECT ID, TOTAL, QUANTIDADE, ITEM_CARDAPIO, PEDIDO FROM ITEMS_PEDIDO WHERE ID = :ID;';
      SQL.Text := FSQL;
      ParamByName('ID').Value := aValue.ID;
      Open;

      lItemJSON := TJSONObject.Create;
      lItemJSON.AddPair('id', FQuery.FieldByName('ID').AsInteger);
      lItemJSON.AddPair('total', FQuery.FieldByName('TOTAL').AsFloat);
      lItemJSON.AddPair('quantidade', FQuery.FieldByName('QUANTIDADE').AsInteger);
      lItemJSON.AddPair('itemCardapio', lController.CARDAPIO.GetByID(FQuery.FieldByName('ITEM_CARDAPIO').AsInteger));
    end;
    Result := lItemJSON;
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

