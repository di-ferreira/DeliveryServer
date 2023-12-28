unit Server.Delivery.Model.TipoPgto;

interface

uses
  System.Generics.Collections, System.SysUtils, System.JSON, REST.JSON,
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
  DM.Server;

type
  TModelServerDeliveryTipoPgto = class(TInterfacedObject,
    iModelServerDelivery<TTIPOPGTO>)
  private
    FConnection: iModelServerDeliveryConnection;
    FQuery: TFDQuery;
    FSQL: string;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iModelServerDelivery<TTIPOPGTO>;
    function Save(aValue: TTIPOPGTO): TJSONObject;
    function GetAll: TJSONArray;
    function GetByID(aID: Integer): TJSONObject;
    function Update(aValue: TTIPOPGTO): TJSONObject;
    function Delete(aID: Integer): TJSONObject;
    function ListAll: TObjectList<TTIPOPGTO>;
    function ListOne(aID: Integer): TTIPOPGTO;
  end;

implementation

{ TModelServerDeliveryTipoPgto }

constructor TModelServerDeliveryTipoPgto.Create;
begin
  FConnection := DM.Server.DataModuleServer.ServerConnection;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection.Connection;
  FConnection.Connection.TxOptions.AutoCommit := False;
end;

function TModelServerDeliveryTipoPgto.Delete(aID: Integer): TJSONObject;
begin
  FSQL := 'DELETE FROM TIPOS_PAGAMENTO WHERE id = :id';
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

destructor TModelServerDeliveryTipoPgto.Destroy;
begin
  FreeAndNil(FQuery);
  inherited;
end;

function TModelServerDeliveryTipoPgto.GetAll: TJSONArray;
begin
  FSQL := 'SELECT ID, DESCRICAO FROM TIPOS_PAGAMENTO';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    Open;
  end;
  Result := FQuery.ToJSONArray();
end;

function TModelServerDeliveryTipoPgto.GetByID(aID: Integer): TJSONObject;
begin
  FSQL := 'SELECT ID, DESCRICAO FROM TIPOS_PAGAMENTO WHERE ID=:ID';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('ID').Value := aID;
    Open;
  end;
  Result := FQuery.ToJSONObject();
end;

function TModelServerDeliveryTipoPgto.ListAll: TObjectList<TTIPOPGTO>;
begin

end;

function TModelServerDeliveryTipoPgto.ListOne(aID: Integer): TTIPOPGTO;
begin

end;

class function TModelServerDeliveryTipoPgto.New
  : iModelServerDelivery<TTIPOPGTO>;
begin
  Result := Self.Create;
end;

function TModelServerDeliveryTipoPgto.Save(aValue: TTIPOPGTO): TJSONObject;
begin
  FSQL := 'INSERT INTO TIPOS_PAGAMENTO (ID, DESCRICAO) VALUES (Null, :DESCRICAO);';

  try
    with FQuery do
    begin
      Connection.StartTransaction;
      SQL.Text := FSQL;
      ParamByName('DESCRICAO').Value := aValue.DESCRICAO;
      ExecSQL;
      Connection.Commit;

      FSQL := 'SELECT ID, DESCRICAO FROM TIPOS_PAGAMENTO WHERE ID=last_insert_rowid();';

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

function TModelServerDeliveryTipoPgto.Update(aValue: TTIPOPGTO): TJSONObject;
begin
  FSQL := 'UPDATE TIPOS_PAGAMENTO SET DESCRICAO = :DESCRICAO WHERE id = :id';
  try
    with FQuery do
    begin
      Connection.StartTransaction;
      SQL.Text := FSQL;

      ParamByName('id').Value := aValue.ID;
      ParamByName('DESCRICAO').Value := aValue.DESCRICAO;
      ExecSQL;
      Connection.Commit;

      FSQL := 'SELECT ID, DESCRICAO FROM TIPOS_PAGAMENTO WHERE ID=:ID;';

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
