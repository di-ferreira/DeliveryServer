unit Server.Delivery.Model.Endereco;

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
  TModelServerDeliveryEndereco = class(TInterfacedObject, iModelServerDelivery<TENDERECO>)
  private
    FConnection: iModelServerDeliveryConnection;
    FQuery: TFDQuery;
    FSQL: string;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iModelServerDelivery<TENDERECO>;
    function Save(aValue: TENDERECO): TJSONObject;
    function GetAll: TJSONArray;
    function GetByID(aID: Integer): TJSONObject;
    function GetByContato(aContato: string): TJSONObject;
    function Update(aValue: TENDERECO): TJSONObject;
    function Delete(aID: Integer): TJSONObject; overload;
    function Delete(aValue: string): TJSONObject; overload;
  end;

implementation

{ TModelSistemaVendaProduto }

constructor TModelServerDeliveryEndereco.Create;
begin
  FConnection := TServerDeliverySQLiteConnection.New;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection.Connection;
  FConnection.Connection.TxOptions.AutoCommit := False;
end;

function TModelServerDeliveryEndereco.Delete(aID: Integer): TJSONObject;
begin
  FSQL := 'DELETE FROM CLIENTES WHERE id = :id';
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
        Result := TJSONObject.Create.AddPair('RESULT', E.Message);
      end;
    end;
  end;
end;

function TModelServerDeliveryEndereco.Delete(aValue: string): TJSONObject;
begin
  FSQL := 'DELETE FROM CLIENTES WHERE id = :id OR contato = :contato';
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
        Result := TJSONObject.Create.AddPair('RESULT', E.Message);
      end;
    end;
  end;
end;

destructor TModelServerDeliveryEndereco.Destroy;
begin
  FreeAndNil(FQuery);
  inherited;
end;

function TModelServerDeliveryEndereco.GetAll: TJSONArray;
begin
  FSQL := 'SELECT id, nome, contato FROM CLIENTES';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    Open;
  end;

  Result := FQuery.ToJSONArray();
end;

function TModelServerDeliveryEndereco.GetByContato(aContato: string): TJSONObject;
begin
  FSQL := 'SELECT id, nome, contato FROM CLIENTES WHERE contato=:contato';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('contato').Value := aContato;
    Open;
  end;
  Result := FQuery.ToJSONObject();
end;

function TModelServerDeliveryEndereco.GetByID(aID: Integer): TJSONObject;
begin
  FSQL := 'SELECT id, nome, contato FROM CLIENTES WHERE id=:id';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('id').Value := aID;
    Open;
  end;
  Result := FQuery.ToJSONObject();
end;

class function TModelServerDeliveryEndereco.New: iModelServerDelivery<TENDERECO>;
begin
  Result := Self.Create;
end;

function TModelServerDeliveryEndereco.Save(aValue: TENDERECO): TJSONObject;
begin
//  FSQL := 'INSERT INTO CLIENTES (id, nome, contato) VALUES (NULL,:nome,:contato)';
//
//  with FQuery do
//  begin
//    try
//      Connection.StartTransaction;
//      SQL.Text := FSQL;
//      ParamByName('nome').Value := aValue.NOME;
//      ParamByName('contato').Value := aValue.CONTATO;
//      ExecSQL;
//      Connection.Commit;
//      FSQL := 'SELECT id, nome, contato FROM CLIENTES WHERE ID=last_insert_rowid();';
//
//      Close;
//      SQL.Text := FSQL;
//      Open;
//
//      Result := FQuery.ToJSONObject();
//    except
//      on E: Exception do
//      begin
//        Connection.Rollback;
//        Result := TJSONObject.Create;
//      end;
//    end;
//  end;

end;

function TModelServerDeliveryEndereco.Update(aValue: TENDERECO): TJSONObject;
begin
//  FSQL := 'UPDATE CLIENTES SET nome = :nome WHERE id = :id';
//  with FQuery do
//  begin
//    Connection.StartTransaction;
//    SQL.Text := FSQL;
//    try
//      try
//        ParamByName('id').Value := aValue.ID;
//        ParamByName('nome').Value := aValue.NOME;
//        ExecSQL;
//        Connection.Commit;
//      except
//        on E: Exception do
//        begin
//          Connection.Rollback;
//          Result := TJSONObject.Create.AddPair('RESULT', 'Erro ao Atualizar Cliente');
//        end;
//      end;
//    finally
//      Result := TJSONObject.Create.AddPair('RESULT', 'Atualizado com sucesso!');
//    end;
//  end;
end;

end.

