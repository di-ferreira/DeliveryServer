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
  TModelServerDeliveryEndereco = class(TInterfacedObject, iModelServerDeliveryEndereco<TENDERECO>)
  private
    FConnection: iModelServerDeliveryConnection;
    FQuery: TFDQuery;
    FSQL: string;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iModelServerDeliveryEndereco<TENDERECO>;
    function Save(aValue: TENDERECO): TJSONObject;
    function GetAll: TJSONArray; overload;
    function GetAll(aID_CLIENTE: Integer): TJSONArray; overload;
    function GetByID(aID: Integer): TJSONObject;
    function Update(aValue: TENDERECO): TJSONObject;
    function Delete(aID: Integer): TJSONObject; overload;
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
  FSQL := 'DELETE FROM ENDERECOS WHERE ID = :ID';
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

destructor TModelServerDeliveryEndereco.Destroy;
begin
  FreeAndNil(FQuery);
  inherited;
end;

function TModelServerDeliveryEndereco.GetAll: TJSONArray;
begin
  FSQL := 'SELECT ID, RUA, NUMERO, BAIRRO, COMPLEMENTO, CIDADE, ESTADO FROM ENDERECOS;';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    Open;
  end;

  Result := FQuery.ToJSONArray();
end;

function TModelServerDeliveryEndereco.GetAll(aID_CLIENTE: Integer): TJSONArray;
begin
  FSQL := 'SELECT ID, RUA, NUMERO, BAIRRO, COMPLEMENTO, CIDADE, ESTADO FROM ENDERECOS WHERE ID_CLIENTE = :ID_CLIENTE;';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('ID_CLIENTE').Value := aID_CLIENTE;
    Open;
  end;

  Result := FQuery.ToJSONArray();
end;

function TModelServerDeliveryEndereco.GetByID(aID: Integer): TJSONObject;
var
  lEndereco: TJSONObject;
begin
  FSQL := 'SELECT ID, RUA, NUMERO, BAIRRO, COMPLEMENTO, CIDADE, ESTADO, ID_CLIENTE FROM ENDERECOS WHERE ID=:ID';

  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('ID').Value := aID;
    Open;
  end;

  lEndereco := FQuery.ToJSONObject();

  Result := lEndereco;
end;

class function TModelServerDeliveryEndereco.New: iModelServerDeliveryEndereco<TENDERECO>;
begin
  Result := Self.Create;
end;

function TModelServerDeliveryEndereco.Save(aValue: TENDERECO): TJSONObject;
var
  vResult: TJSONObject;
begin
  FSQL := 'INSERT INTO ENDERECOS (ID, RUA, NUMERO, BAIRRO, COMPLEMENTO, CIDADE, ESTADO, ID_CLIENTE) VALUES (null, :RUA, :NUMERO, :BAIRRO, :COMPLEMENTO, :CIDADE, :ESTADO, :ID_CLIENTE)';

  with FQuery do
  begin
    try
      Connection.StartTransaction;
      SQL.Text := FSQL;
      ParamByName('RUA').Value := aValue.RUA;
      ParamByName('NUMERO').Value := aValue.NUMERO;
      ParamByName('BAIRRO').Value := aValue.BAIRRO;
      ParamByName('COMPLEMENTO').Value := aValue.COMPLEMENTO;
      ParamByName('CIDADE').Value := aValue.CIDADE;
      ParamByName('ESTADO').Value := aValue.ESTADO;
      ParamByName('ID_CLIENTE').Value := aValue.CLIENTE.ID;
      ExecSQL;
      FSQL := 'SELECT ENDERECOS.ID, ENDERECOS.RUA, ENDERECOS.NUMERO, ENDERECOS.BAIRRO, ENDERECOS.COMPLEMENTO, ENDERECOS.CIDADE, ENDERECOS.ESTADO, ENDERECOS.ID_CLIENTE, CLIENTES.NOME, CLIENTES.CONTATO FROM' + ' ENDERECOS INNER JOIN CLIENTES  ON ENDERECOS.ID_CLIENTE = CLIENTES.ID WHERE ENDERECOS.ID = last_insert_rowid();';

      Close;
      SQL.Text := FSQL;
      Open;

      vResult := TJSONObject.Create().AddPair('ID', FieldByName('ID').AsInteger).AddPair('RUA', FieldByName('RUA').AsString).AddPair('NUMERO', FieldByName('NUMERO').AsString).AddPair('BAIRRO', FieldByName('BAIRRO').AsString).AddPair('COMPLEMENTO', FieldByName('COMPLEMENTO').AsString).AddPair('CIDADE', FieldByName('CIDADE').AsString).AddPair('ESTADO', FieldByName('ESTADO').AsString).AddPair('CLIENTE', TJSONObject.Create().AddPair('ID', FieldByName('ID_CLIENTE').AsInteger).AddPair('NOME', FieldByName('NOME').AsString).AddPair('CONTATO', FieldByName('CONTATO').AsString));

      Connection.Commit;
      Result := vResult;
    except
      on E: Exception do
      begin
        Connection.Rollback;
        Result := TJSONObject.Create;
      end;
    end;
  end;

end;

function TModelServerDeliveryEndereco.Update(aValue: TENDERECO): TJSONObject;
var
  vResult: TJSONObject;
begin
  FSQL := 'UPDATE ENDERECOS SET RUA = :RUA, NUMERO = :NUMERO, BAIRRO = :BAIRRO, COMPLEMENTO = :COMPLEMENTO, CIDADE = :CIDADE, ESTADO = :ESTADO WHERE ID = :ID;';

  with FQuery do
  begin
    try
      Connection.StartTransaction;
      SQL.Text := FSQL;
      ParamByName('RUA').Value := aValue.RUA;
      ParamByName('NUMERO').Value := aValue.NUMERO;
      ParamByName('BAIRRO').Value := aValue.BAIRRO;
      ParamByName('COMPLEMENTO').Value := aValue.COMPLEMENTO;
      ParamByName('CIDADE').Value := aValue.CIDADE;
      ParamByName('ESTADO').Value := aValue.ESTADO;
      ParamByName('ID').Value := aValue.ID;
      ExecSQL;

      FSQL := 'SELECT ID, RUA, NUMERO, BAIRRO, COMPLEMENTO, CIDADE, ESTADO, ID_CLIENTE FROM ENDERECOS WHERE ID=:ID';

      with FQuery do
      begin
        Close;
        SQL.Text := FSQL;
        ParamByName('ID').Value := aValue.ID;
        Open;
      end;

      Connection.Commit;

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

