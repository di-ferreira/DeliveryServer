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
  Server.Delivery.DTO, Server.Delivery.Model.Interfaces,
  Server.Delivery.SQLite.Connection, System.JSON;

type
  TModelServerDeliveryCliente = class(TInterfacedObject, iModelServerDeliveryCliente<TCLIENTE>)
  private
    FConnection: iModelServerDeliveryConnection;
    FQuery: TFDQuery;
    FSQL: string;
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
  end;

implementation

{ TModelSistemaVendaProduto }

constructor TModelServerDeliveryCliente.Create;
begin
  FConnection := TServerDeliverySQLiteConnection.New;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection.Connection;
  FConnection.Connection.TxOptions.AutoCommit := False;
end;

function TModelServerDeliveryCliente.Delete(aID: Integer): TJSONObject;
begin
  FSQL := 'DELETE FROM CLIENTES WHERE ID = :ID';
  with FQuery do
  begin
    try
      Connection.StartTransaction;
      SQL.Text := FSQL;
      ParamByName('ID').Value := aID;
      ExecSQL;
      Connection.Commit;
      Result := TJSONObject.Create;
    except
      on E: Exception do
      begin
        Connection.Rollback;
        Result := TJSONObject.Create.AddPair('RESULT', E.Message);
      end;
    end;
  end;
end;

function TModelServerDeliveryCliente.Delete(aValue: string): TJSONObject;
begin
  FSQL := 'DELETE FROM CLIENTES WHERE ID = :ID OR CONTATO = :CONTATO';
  with FQuery do
  begin
    try
      Connection.StartTransaction;
      SQL.Text := FSQL;
      ParamByName('ID').Value := aValue;
      ParamByName('CONTATO').Value := aValue;
      ExecSQL;
      Connection.Commit;
      Result := TJSONObject.Create;
    except
      on E: Exception do
      begin
        Connection.Rollback;
        Result := TJSONObject.Create.AddPair('RESULT', E.Message);
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
  FSQL := 'SELECT ID, NOME, CONTATO FROM CLIENTES';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    Open;
  end;

  Result := FQuery.ToJSONArray();
end;

function TModelServerDeliveryCliente.GetByContato(aContato: string): TJSONObject;
begin
  FSQL := 'SELECT ID, NOME, CONTATO FROM CLIENTES WHERE CONTATO=:CONTATO';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('CONTATO').Value := aContato;
    Open;
  end;
  Result := FQuery.ToJSONObject();
end;

function TModelServerDeliveryCliente.GetByID(aID: Integer): TJSONObject;
begin
  FSQL := 'SELECT ID, NOME, CONTATO FROM CLIENTES WHERE ID=:ID';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('ID').Value := aID;
    Open;
  end;
  Result := FQuery.ToJSONObject();
end;

class function TModelServerDeliveryCliente.New: iModelServerDeliveryCliente<TCLIENTE>;
begin
  Result := Self.Create;
end;

function TModelServerDeliveryCliente.Save(aValue: TCLIENTE): TJSONObject;
begin
  FSQL := 'INSERT INTO CLIENTES (ID, NOME, CONTATO) VALUES (NULL,:NOME,:CONTATO)';

  with FQuery do
  begin
    try
      Connection.StartTransaction;
      SQL.Text := FSQL;
      ParamByName('NOME').Value := aValue.NOME;
      ParamByName('CONTATO').Value := aValue.CONTATO;
      ExecSQL;
      Connection.Commit;
      FSQL := 'SELECT ID, NOME, CONTATO FROM CLIENTES WHERE ID=last_insert_rowid();';

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

function TModelServerDeliveryCliente.Update(aValue: TCLIENTE): TJSONObject;
begin
  FSQL := 'UPDATE CLIENTES SET NOME = :NOME WHERE ID = :ID';
  with FQuery do
  begin
    Connection.StartTransaction;
    SQL.Text := FSQL;
    try
      ParamByName('ID').Value := aValue.ID;
      ParamByName('NOME').Value := aValue.NOME;
      ExecSQL;
      Connection.Commit;

      FSQL := 'SELECT ID, NOME, CONTATO FROM CLIENTES WHERE ID=:ID;';
      ParamByName('ID').Value := aValue.ID;
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

