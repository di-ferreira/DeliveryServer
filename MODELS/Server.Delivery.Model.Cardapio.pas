unit Server.Delivery.Model.Cardapio;

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
  TModelServerDeliveryCardapio = class(TInterfacedObject, iModelServerDelivery<TCARDAPIO>)
  private
    FConnection: iModelServerDeliveryConnection;
    FQuery: TFDQuery;
    FSQL: string;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iModelServerDelivery<TCARDAPIO>;
    function Save(aValue: TCARDAPIO): TJSONObject;
    function GetAll: TJSONArray;
    function GetByID(aID: Integer): TJSONObject;
    function Update(aValue: TCARDAPIO): TJSONObject;
    function Delete(aID: Integer): TJSONObject;
  end;

implementation
{ TModelServerDeliveryCardapio }

constructor TModelServerDeliveryCardapio.Create;
begin
  FConnection := TServerDeliverySQLiteConnection.New;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection.Connection;
  FConnection.Connection.TxOptions.AutoCommit := False;
end;

function TModelServerDeliveryCardapio.Delete(aID: Integer): TJSONObject;
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

destructor TModelServerDeliveryCardapio.Destroy;
begin
  FreeAndNil(FQuery);
  inherited;
end;

function TModelServerDeliveryCardapio.GetAll: TJSONArray;
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

function TModelServerDeliveryCardapio.GetByID(aID: Integer): TJSONObject;
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

class function TModelServerDeliveryCardapio.New: iModelServerDelivery<TCARDAPIO>;
begin
  Result := Self.Create;
end;

function TModelServerDeliveryCardapio.Save(aValue: TCARDAPIO): TJSONObject;
var
  lProduto: TPRODUTO;
  lResultPRodutos: TJSONArray;
begin
  FSQL := 'INSERT INTO CARDAPIO (ID, DESCRICAO, PRECO, TIPO) VALUES (Null, :DESCRICAO, :PRECO, :TIPO);';

  try
    with FQuery do
    begin
      Connection.StartTransaction;
      SQL.Text := FSQL;
      ParamByName('DESCRICAO').Value := aValue.DESCRICAO;
      ParamByName('PRECO').Value := aValue.PRECO;
      ParamByName('TIPO').Value := aValue.TIPO_CARDAPIO.ID;
      ExecSQL;

      FSQL := 'INSERT INTO CARDAPIO_PRODUTO (ID, ID_CARDAPIO, ID_PRODUTO) VALUES (Null, (SELECT ID FROM CARDAPIO ORDER BY ID DESC LIMIT 1), :ID_PRODUTO);';

      for lProduto in aValue.PRODUTO do
      begin
        SQL.Text := FSQL;
        ParamByName('ID_PRODUTO').Value := lProduto.ID;
        ExecSQL;
      end;

      FSQL := 'SELECT P.ID AS ID, P.NOME AS NOME, P.ESTOQUE AS ESTOQUE, P.CUSTO AS CUSTO, P.PERCENTUAL_LUCRO AS PERCENTUAL ' + 'FROM CARDAPIO_PRODUTO CP LEFT JOIN CARDAPIO C ON CP.ID_CARDAPIO = C.ID LEFT JOIN PRODUTOS P ON CP.ID_PRODUTO = P.ID ' + 'WHERE C.ID = (SELECT ID FROM CARDAPIO ORDER BY ID DESC LIMIT 1);';

      Close;
      SQL.Text := FSQL;
      Open;
      lResultPRodutos := TJSONArray.Create;
      lResultPRodutos := FQuery.ToJSONArray();

      FSQL := 'SELECT C.ID, C.DESCRICAO, C.PRECO, T.DESCRICAO AS TIPO FROM CARDAPIO C LEFT JOIN TIPOS_CARDAPIO T ON T.ID = C.TIPO ORDER BY C.ID DESC LIMIT 1;';

      Close;
      SQL.Text := FSQL;
      Open;
      Connection.Commit;
    end;
    Result := FQuery.ToJSONObject().AddPair('PRODUTOS', lResultPRodutos);
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

function TModelServerDeliveryCardapio.Update(aValue: TCARDAPIO): TJSONObject;
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
