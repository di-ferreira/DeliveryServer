unit Server.Delivery.Model.TipoCardapio;

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
  TModelServerDeliveryTipoCardapio = class(TInterfacedObject, iModelServerDelivery<TTIPO_CARDAPIO>)
  private
    FConnection: iModelServerDeliveryConnection;
    FQuery: TFDQuery;
    FSQL: string;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iModelServerDelivery<TTIPO_CARDAPIO>;
    function Save(aValue: TTIPO_CARDAPIO): TJSONObject;
    function GetAll: TJSONArray;
    function GetByID(aID: Integer): TJSONObject;
    function Update(aValue: TTIPO_CARDAPIO): TJSONObject;
    function Delete(aID: Integer): TJSONObject;
  end;

implementation
{ TModelServerDeliveryTipoCardapio }

constructor TModelServerDeliveryTipoCardapio.Create;
begin
  FConnection := TServerDeliverySQLiteConnection.New;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection.Connection;
  FConnection.Connection.TxOptions.AutoCommit := False;
end;

function TModelServerDeliveryTipoCardapio.Delete(aID: Integer): TJSONObject;
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

destructor TModelServerDeliveryTipoCardapio.Destroy;
begin
  FreeAndNil(FQuery);
  inherited;
end;

function TModelServerDeliveryTipoCardapio.GetAll: TJSONArray;
begin
  FSQL := 'SELECT ID, DESCRICAO FROM TIPOS_CARDAPIO';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    Open;
  end;
  Result := FQuery.ToJSONArray();
end;

function TModelServerDeliveryTipoCardapio.GetByID(aID: Integer): TJSONObject;
begin
  FSQL := 'SELECT ID, DESCRICAO FROM TIPOS_CARDAPIO WHERE ID=:ID';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('ID').Value := aID;
    Open;
  end;
  Result := FQuery.ToJSONObject();
end;

class function TModelServerDeliveryTipoCardapio.New: iModelServerDelivery<TTIPO_CARDAPIO>;
begin
  Result := Self.Create;
end;

function TModelServerDeliveryTipoCardapio.Save(aValue: TTIPO_CARDAPIO): TJSONObject;
begin
  FSQL := 'INSERT INTO TIPOS_CARDAPIO (ID, DESCRICAO) VALUES (Null, :DESCRICAO);';

  try
    with FQuery do
    begin
      Connection.StartTransaction;
      SQL.Text := FSQL;
      ParamByName('DESCRICAO').Value := aValue.DESCRICAO;
      ExecSQL;
      Connection.Commit;

      FSQL := 'SELECT ID, DESCRICAO FROM TIPOS_CARDAPIO WHERE ID=last_insert_rowid();';

      Close;
      SQL.Text := FSQL;
      Open;
    end;
    Result := FQuery.ToJSONObject();
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

function TModelServerDeliveryTipoCardapio.Update(aValue: TTIPO_CARDAPIO): TJSONObject;
begin
  FSQL := 'UPDATE TIPOS_CARDAPIO SET DESCRICAO = :DESCRICAO WHERE id = :id';
  try
    with FQuery do
    begin
      Connection.StartTransaction;
      SQL.Text := FSQL;

      ParamByName('id').Value := aValue.ID;
      ParamByName('DESCRICAO').Value := aValue.DESCRICAO;
      ExecSQL;
      Connection.Commit;

      FSQL := 'SELECT ID, DESCRICAO FROM TIPOS_CARDAPIO WHERE ID=:ID;';

      Close;
      SQL.Text := FSQL;
      ParamByName('ID').Value := aValue.ID;
      Open;
    end;
    Result := FQuery.ToJSONObject();
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

