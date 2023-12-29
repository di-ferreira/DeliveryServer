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
  TModelServerDeliveryCliente = class(TInterfacedObject,
    iModelServerDeliveryCliente<TCLIENTE>)
  private
    FConnection: iModelServerDeliveryConnection;
    FQuery: TFDQuery;
    FSQL: string;
    FCQL:ICQL;
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
  FCQL := DM.Server.DataModuleServer.ServerConnection.SQL;
end;

function TModelServerDeliveryCliente.Delete(aID: Integer): TJSONObject;
begin
  FSQL := 'delete from clientes where id = :id';
  with FQuery do
  begin
    try
      Connection.StartTransaction;
      SQL.Text := FSQL;
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
  FSQL := 'delete from clientes where id = :id or contato = :contato';
  with FQuery do
  begin
    try
      Connection.StartTransaction;
      SQL.Text := FSQL;
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
    SQL.Text := FCQL.Select.ALL.From('clientes').AsString;
    Open;
  end;

  Result := FQuery.ToJSONArray();
end;

function TModelServerDeliveryCliente.GetByContato(aContato: string)
  : TJSONObject;
begin
  FSQL := 'select id, nome, contato from clientes where contato=:contato';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('contato').Value := aContato;
    Open;
  end;
  Result := FQuery.ToJSONObject();
end;

function TModelServerDeliveryCliente.GetByID(aID: Integer): TJSONObject;
begin
  FSQL := 'select id, nome, contato from clientes where id=:id';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
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

class function TModelServerDeliveryCliente.New
  : iModelServerDeliveryCliente<TCLIENTE>;
begin
  Result := Self.Create;
end;

function TModelServerDeliveryCliente.Save(aValue: TCLIENTE): TJSONObject;
begin
  with FQuery do
  begin
    try
      Connection.StartTransaction;
      SQL.Text := FCQL
                  .Insert
                  .Into('clientes')
                  .&Set('nome', aValue.NOME)
                  .&Set('contato', aValue.CONTATO)
                  .AsString;
      ExecSQL;
      Connection.Commit;

      Close;
      SQL.Text := FCQL
                  .Select
                  .All
                  .From('clientes')
                  .Where('id=last_insert_rowid()').AsString;
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
  FSQL := 'update clientes set nome = :nome where id = :id';
  with FQuery do
  begin
    Connection.StartTransaction;
    SQL.Text := FSQL;
    try
      ParamByName('id').Value := aValue.ID;
      ParamByName('nome').Value := aValue.NOME;
      ExecSQL;
      Connection.Commit;

      FSQL := 'select id, nome, contato from clientes where id=:id;';
      ParamByName('id').Value := aValue.ID;
      Close;
      SQL.Text := FSQL;
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
