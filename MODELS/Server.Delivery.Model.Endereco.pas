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
    function ListAll: TObjectList<TENDERECO>;
    function ListOne(aID: Integer): TENDERECO;
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
  FSQL := 'delete from enderecos where id = :id';
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

destructor TModelServerDeliveryEndereco.Destroy;
begin
  FreeAndNil(FQuery);
  inherited;
end;

function TModelServerDeliveryEndereco.GetAll: TJSONArray;
begin
  FSQL := 'select id, rua, numero, bairro, complemento, cidade, estado from enderecos;';
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
  FSQL := 'select id, rua, numero, bairro, complemento, cidade, estado from enderecos where id_cliente = :id_cliente;';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('id_cliente').Value := aID_CLIENTE;
    Open;
  end;

  Result := FQuery.ToJSONArray();
end;

function TModelServerDeliveryEndereco.GetByID(aID: Integer): TJSONObject;
var
  lEndereco: TJSONObject;
begin
  FSQL := 'select id, rua, numero, bairro, complemento, cidade, estado, id_cliente from enderecos where id=:id';

  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('id').Value := aID;
    Open;
  end;

  lEndereco := FQuery.ToJSONObject();

  Result := lEndereco;
end;

function TModelServerDeliveryEndereco.ListAll: TObjectList<TENDERECO>;
begin

end;

function TModelServerDeliveryEndereco.ListOne(aID: Integer): TENDERECO;
begin

end;

class function TModelServerDeliveryEndereco.New: iModelServerDeliveryEndereco<TENDERECO>;
begin
  Result := Self.Create;
end;

function TModelServerDeliveryEndereco.Save(aValue: TENDERECO): TJSONObject;
var
  vResult: TJSONObject;
begin
  FSQL := 'insert into enderecos (id, rua, numero, bairro, complemento, cidade, estado, id_cliente) values (null, :rua, :numero, :bairro, :complemento, :cidade, :estado, :id_cliente)';

  with FQuery do
  begin
    try
      Connection.StartTransaction;
      SQL.Text := FSQL;
      ParamByName('rua').Value := aValue.RUA;
      ParamByName('numero').Value := aValue.NUMERO;
      ParamByName('bairro').Value := aValue.BAIRRO;
      ParamByName('complemento').Value := aValue.COMPLEMENTO;
      ParamByName('cidade').Value := aValue.CIDADE;
      ParamByName('estado').Value := aValue.ESTADO;
      ParamByName('id_cliente').Value := aValue.CLIENTE.ID;
      ExecSQL;
      FSQL := 'select enderecos.id, enderecos.rua, enderecos.numero, enderecos.bairro, enderecos.complemento, enderecos.cidade, enderecos.estado, enderecos.id_cliente, clientes.nome, clientes.contato from' + ' enderecos inner join clientes  on enderecos.id_cliente = clientes.id where enderecos.id = last_insert_rowid();';

      Close;
      SQL.Text := FSQL;
      Open;

      vResult := TJSONObject.Create().AddPair('id', FieldByName('id').AsInteger).AddPair('rua', FieldByName('rua').AsString).AddPair('numero', FieldByName('numero').AsString).AddPair('bairro', FieldByName('bairro').AsString).AddPair('complemento', FieldByName('complemento').AsString).AddPair('cidade', FieldByName('cidade').AsString).AddPair('estado', FieldByName('estado').AsString).AddPair('cliente', TJSONObject.Create().AddPair('id', FieldByName('id_cliente').AsInteger).AddPair('nome', FieldByName('nome').AsString).AddPair('contato', FieldByName('contato').AsString));

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
  FSQL := 'update enderecos set rua = :rua, numero = :numero, bairro = :bairro, complemento = :complemento, cidade = :cidade, estado = :estado where id = :id;';

  with FQuery do
  begin
    try
      Connection.StartTransaction;
      SQL.Text := FSQL;
      ParamByName('rua').Value := aValue.RUA;
      ParamByName('numero').Value := aValue.NUMERO;
      ParamByName('bairro').Value := aValue.BAIRRO;
      ParamByName('complemento').Value := aValue.COMPLEMENTO;
      ParamByName('cidade').Value := aValue.CIDADE;
      ParamByName('estado').Value := aValue.ESTADO;
      ParamByName('id').Value := aValue.ID;
      ExecSQL;

      FSQL := 'select id, rua, numero, bairro, complemento, cidade, estado, id_cliente from enderecos where id=:id';

      with FQuery do
      begin
        Close;
        SQL.Text := FSQL;
        ParamByName('id').Value := aValue.ID;
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

