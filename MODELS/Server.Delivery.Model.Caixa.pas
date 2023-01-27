unit Server.Delivery.Model.Caixa;

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
  TModelServerDeliveryCaixa = class(TInterfacedObject, iModelServerDeliveryCaixa<TCAIXA>)
  private
    FConnection: iModelServerDeliveryConnection;
    FQuery: TFDQuery;
    FSQL: string;
    function GetByTipo(aID_TIPO: Integer): TJSONArray;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iModelServerDeliveryCaixa<TCAIXA>;
    function Save: TJSONObject; overload;
    function Save(aValue: TCAIXA): TJSONObject; overload;
    function GetAll: TJSONArray;
    function GetByID(aID: Integer): TJSONObject;
    function GetByDate(aDate: TDate): TJSONObject;
    function GetBetweenDates(aInitalDate, aFinalDate: TDate): TJSONArray;
    function GetOpen: TJSONObject;
    function CloseCaixa(aID: Integer): TJSONObject;
    function Update(aValue: TCAIXA): TJSONObject;
    function Delete(aID: Integer): TJSONObject;
  end;

implementation
{ TModelServerDeliveryCaixa }

function TModelServerDeliveryCaixa.CloseCaixa(aID: Integer): TJSONObject;
begin
  FSQL := 'UPDATE CAIXAS SET ABERTO=false WHERE ID=:ID;';
  try
    with FQuery do
    begin
      Connection.StartTransaction;
      SQL.Text := FSQL;

      ParamByName('ID').Value := aID;
      ExecSQL;

      Connection.Commit;

      FSQL := 'SELECT C.ID, C."DATA" AS DATA_ABERTURA, C.ABERTO, C.TOTAL FROM CAIXAS C WHERE C.ID = :ID;';

      Close;
      SQL.Text := FSQL;
      ParamByName('ID').Value := aID;
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

constructor TModelServerDeliveryCaixa.Create;
begin
  FConnection := TServerDeliverySQLiteConnection.New;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection.Connection;
  FConnection.Connection.TxOptions.AutoCommit := False;
end;

function TModelServerDeliveryCaixa.Delete(aID: Integer): TJSONObject;
begin
  FSQL := 'DELETE FROM CARDAPIO_PRODUTO WHERE ID_CARDAPIO = :id';
  with FQuery do
  begin
    SQL.Text := FSQL;
    Connection.StartTransaction;
    try
      ParamByName('id').Value := aID;
      ExecSQL;
      Connection.Commit;
    except
      on E: Exception do
      begin
        Connection.Rollback;
        Result := TJSONObject.Create.AddPair('result', E.Message);
      end;
    end;
  end;

  FSQL := 'DELETE FROM CARDAPIO WHERE ID = :id';
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

destructor TModelServerDeliveryCaixa.Destroy;
begin
  FreeAndNil(FQuery);
  inherited;
end;

function TModelServerDeliveryCaixa.GetAll: TJSONArray;
begin
  FSQL := 'SELECT C.ID, C.DESCRICAO, C.PRECO, T.DESCRICAO AS TIPO FROM CARDAPIO C LEFT JOIN TIPOS_CARDAPIO T ON T.ID = C.TIPO ORDER BY C.ID';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    Open;
  end;
  Result := FQuery.ToJSONArray();
end;

function TModelServerDeliveryCaixa.GetBetweenDates(aInitalDate, aFinalDate: TDate): TJSONArray;
begin

end;

function TModelServerDeliveryCaixa.GetByDate(aDate: TDate): TJSONObject;
begin

end;

function TModelServerDeliveryCaixa.GetByID(aID: Integer): TJSONObject;
begin
  FSQL := 'SELECT C.ID, C.DESCRICAO, C.PRECO, T.DESCRICAO AS TIPO FROM CARDAPIO C LEFT JOIN TIPOS_CARDAPIO T ON T.ID = C.TIPO WHERE C.ID = :ID';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('ID').Value := aID;
    Open;
  end;
  Result := FQuery.ToJSONObject();
end;

function TModelServerDeliveryCaixa.GetByTipo(aID_TIPO: Integer): TJSONArray;
begin
  FSQL := 'SELECT C.ID, C.DESCRICAO, C.PRECO, T.DESCRICAO AS TIPO FROM CARDAPIO C LEFT JOIN TIPOS_CARDAPIO T ON T.ID = C.TIPO WHERE T.ID = :ID';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('ID').Value := aID_TIPO;
    Open;
  end;
  Result := FQuery.ToJSONArray();
end;

function TModelServerDeliveryCaixa.GetOpen: TJSONObject;
begin
  FSQL := 'SELECT C.ID, C."DATA" AS DATA_ABERTURA, C.ABERTO, C.TOTAL FROM CAIXAS C WHERE C.ABERTO = 1;';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    Open;
  end;
  Result := FQuery.ToJSONObject();
end;

class function TModelServerDeliveryCaixa.New: iModelServerDeliveryCaixa<TCAIXA>;
begin
  Result := Self.Create;
end;

function TModelServerDeliveryCaixa.Save(aValue: TCAIXA): TJSONObject;
begin

end;

function TModelServerDeliveryCaixa.Save: TJSONObject;
begin
  FSQL := 'INSERT INTO CAIXAS ("DATA", ABERTO, TOTAL) VALUES(CURRENT_TIMESTAMP, true, 0.00);';

  try
    with FQuery do
    begin
      Connection.StartTransaction;
      SQL.Text := FSQL;
      ExecSQL;

      FSQL := 'SELECT C.ID, C."DATA" AS DATA_ABERTURA, C.ABERTO, C.TOTAL FROM CAIXAS C ORDER BY C.ID DESC LIMIT 1;';

      Close;
      SQL.Text := FSQL;
      Open;
      Connection.Commit;
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

function TModelServerDeliveryCaixa.Update(aValue: TCAIXA): TJSONObject;
begin

end;

end.

