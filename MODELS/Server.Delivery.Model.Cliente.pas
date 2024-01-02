unit Server.Delivery.Model.Cliente;

interface

uses
  System.Generics.Collections, System.SysUtils, DataSet.Serialize,
  {FIREDAC CONNECTION}
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait,
  FireDAC.Comp.UI, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
  {Interfaces}
  Server.Delivery.DTO, Server.Delivery.Model.Interfaces, System.JSON, DM.Server,
  cqlbr.interfaces;

type
  TModelServerDeliveryCliente = class(TInterfacedObject, iModelServerDeliveryCliente<TCLIENTE>)
  private
    FConnection: iModelServerDeliveryConnection;
    FQuery: TFDQuery;
    FSQL: ICQL;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iModelServerDeliveryCliente<TCLIENTE>;
    function Save(aValue: TCLIENTE): TJSONObject;
    function GetAll: TJSONArray;
    function GetByID(aID: Integer): TJSONObject;
    function GetByContato(aContato: string): TJSONObject;
    function Update(aValue: TCLIENTE): TJSONObject;
    function Delete(aID: Integer): TJSONObject; overload;
    function Delete(aValue: string): TJSONObject; overload;
    function ListAll: TObjectList<TCLIENTE>;
    function ListOne(aID: Integer): TCLIENTE;
  end;

implementation

{ TModelSistemaVendaProduto }

constructor TModelServerDeliveryCliente.Create;
begin
  FConnection := DM.Server.DataModuleServer.ServerConnection;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection.Connection;
  FConnection.Connection.TxOptions.AutoCommit := False;
  FSQL := DM.Server.DataModuleServer.ServerConnection.SQL;
end;

function TModelServerDeliveryCliente.Delete(aID: Integer): TJSONObject;
begin
  with FQuery do
  begin
    try
      Connection.StartTransaction;
      SQL.Text := FSQL
                     .Delete
                     .From('clientes')
                     .Where('id')
                     .Equal(':id')
                     .AsString;
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

function TModelServerDeliveryCliente.Delete(aValue: string): TJSONObject;
begin
  with FQuery do
  begin
    try
      Connection.StartTransaction;
      SQL.Text := FSQL
                     .Delete
                     .From('clientes')
                     .Where('id')
                     .Equal(':id')
                     .&Or('contato')
                     .Equal(':contato')
                     .AsString;
      ParamByName('id').Value := aValue;
      ParamByName('contato').Value := aValue;
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

destructor TModelServerDeliveryCliente.Destroy;
begin
  FreeAndNil(FQuery);
  inherited;
end;

function TModelServerDeliveryCliente.GetAll: TJSONArray;
begin
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL.Select.ALL.From('clientes').AsString;
    Open;
  end;

  Result := FQuery.ToJSONArray();
end;

function TModelServerDeliveryCliente.GetByContato(aContato: string): TJSONObject;
begin
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL
                  .Select
                  .ALL
                  .From('clientes')
                  .Where('contato')
                  .Equal(':contato')
                  .AsString;
    ParamByName('contato').Value := aContato;
    Open;
  end;
  Result := FQuery.ToJSONObject();
end;

function TModelServerDeliveryCliente.GetByID(aID: Integer): TJSONObject;
begin
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL
                  .Select
                  .ALL
                  .From('clientes')
                  .Where('id')
                  .Equal(':id')
                  .AsString;
    ParamByName('id').Value := aID;
    Open;
  end;
  Result := FQuery.ToJSONObject();
end;

function TModelServerDeliveryCliente.ListAll: TObjectList<TCLIENTE>;
begin

end;

function TModelServerDeliveryCliente.ListOne(aID: Integer): TCLIENTE;
begin

end;

class function TModelServerDeliveryCliente.New: iModelServerDeliveryCliente<TCLIENTE>;
begin
  Result := Self.Create;
end;

function TModelServerDeliveryCliente.Save(aValue: TCLIENTE): TJSONObject;
begin
  with FQuery do
  begin
    try
      Connection.StartTransaction;
      SQL.Text := FSQL.Insert.Into('clientes').&Set('nome', aValue.NOME).&Set('contato', aValue.CONTATO).AsString;
      ExecSQL;
      Connection.Commit;

      Close;
      SQL.Text := FSQL.Select.All.From('clientes').Limit(1).Desc.AsString;
      Open;

      Result := FQuery.ToJSONObject();
    except
      on E: Exception do
      begin
        Connection.Rollback;
        Result := TJSONObject.Create;
      end;
    end;
  end;

end;

function TModelServerDeliveryCliente.Update(aValue: TCLIENTE): TJSONObject;
begin
  with FQuery do
  begin
    Connection.StartTransaction;
    SQL.Text := FSQL
                   .Update('clientes')
                   .&Set('nome',':nome')
                   .Where('id')
                   .Equal(':id')
                   .AsString;
    try
      ParamByName('id').Value := aValue.ID;
      ParamByName('nome').Value := aValue.NOME;
      ExecSQL;
      Connection.Commit;

      ParamByName('id').Value := aValue.ID;
      Close;
      SQL.Text := FSQL
                     .Select
                     .All
                     .From('clientes')
                     .Where('id = :id')
                     .AsString;
      Open;

      Result := FQuery.ToJSONObject();
    except
      on E: Exception do
      begin
        Connection.Rollback;
        Result := TJSONObject.Create;
      end;
    end;
  end;
end;

end.

