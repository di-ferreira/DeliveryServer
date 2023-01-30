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
    function GetAll: TJSONArray;
    function GetByID(aID: Integer): TJSONObject;
    function Update(aValue: TPEDIDO): TJSONObject;
    function Delete(aID: Integer): TJSONObject;
    function GetByCaixa(aIDCaixa:Integer): TJSONArray;
    function GetByCliente(aIDCliente:Integer): TJSONArray;
  end;

implementation
{ TModelServerDeliveryPedido }

constructor TModelServerDeliveryPedido.Create;
begin
  FConnection := TServerDeliverySQLiteConnection.New;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection.Connection;
  FConnection.Connection.TxOptions.AutoCommit := False;
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

function TModelServerDeliveryPedido.GetByCaixa(aIDCaixa: Integer): TJSONArray;
begin

end;

function TModelServerDeliveryPedido.GetByCliente(
  aIDCliente: Integer): TJSONArray;
begin

end;

function TModelServerDeliveryPedido.GetByID(aID: Integer): TJSONObject;
begin
  FSQL := 'SELECT ID, NOME, ESTOQUE, CUSTO, PERCENTUAL_LUCRO AS LUCRO FROM PRODUTOS WHERE ID=:ID';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('ID').Value := aID;
    Open;
  end;
  Result := FQuery.ToJSONObject();
end;

class function TModelServerDeliveryPedido.New: iModelServerDeliveryPedido<TPEDIDO>;
begin
  Result := Self.Create;
end;

function TModelServerDeliveryPedido.Save(aValue: TPEDIDO): TJSONObject;
begin
//  FSQL := 'INSERT INTO PRODUTOS (ID, NOME, ESTOQUE, CUSTO, PERCENTUAL_LUCRO) VALUES (Null, :NOME, :ESTOQUE, :CUSTO, :PERCENTUAL_LUCRO);';
//
//  try
//    with FQuery do
//    begin
//      Connection.StartTransaction;
//      SQL.Text := FSQL;
//      ParamByName('NOME').Value := aValue.NOME;
//      ParamByName('ESTOQUE').Value := aValue.ESTOQUE;
//      ParamByName('CUSTO').Value := aValue.CUSTO;
//      ParamByName('PERCENTUAL_LUCRO').Value := aValue.LUCRO;
//      ExecSQL;
//      Connection.Commit;
//
//      FSQL := 'SELECT ID, NOME, ESTOQUE, CUSTO, PERCENTUAL_LUCRO AS LUCRO FROM PRODUTOS WHERE ID=last_insert_rowid();';
//
//      Close;
//      SQL.Text := FSQL;
//      Open;
//    end;
//    Result := FQuery.ToJSONObject();
//  except
//
//    on E: Exception do
//    begin
//      with FQuery do
//      begin
//        Connection.Rollback;
//        Result := TJSONObject.Create;
//      end;
//    end;
//  end;
end;

function TModelServerDeliveryPedido.Update(aValue: TPEDIDO): TJSONObject;
begin
//  FSQL := 'UPDATE PRODUTOS SET nome = :nome, ESTOQUE = :ESTOQUE, CUSTO = :CUSTO, PERCENTUAL_LUCRO = :PERCENTUAL_LUCRO WHERE id = :id';
//  try
//    with FQuery do
//    begin
//      Connection.StartTransaction;
//      SQL.Text := FSQL;
//
//      ParamByName('id').Value := aValue.ID;
//      ParamByName('nome').Value := aValue.NOME;
//      ParamByName('ESTOQUE').Value := aValue.ESTOQUE;
//      ParamByName('CUSTO').Value := aValue.CUSTO;
//      ParamByName('PERCENTUAL_LUCRO').Value := aValue.LUCRO;
//      ExecSQL;
//      Connection.Commit;
//
//      FSQL := 'SELECT ID, NOME, ESTOQUE, CUSTO, PERCENTUAL_LUCRO AS LUCRO FROM PRODUTOS WHERE ID=:ID;';
//
//      Close;
//      SQL.Text := FSQL;
//      ParamByName('ID').Value := aValue.ID;
//      Open;
//    end;
//    Result := FQuery.ToJSONObject();
//  except
//    on E: Exception do
//    begin
//      with FQuery do
//      begin
//        Connection.Rollback;
//        Result := TJSONObject.Create;
//      end;
//    end;
//  end;
end;

end.

