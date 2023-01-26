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
  TModelServerDeliveryCardapio = class(TInterfacedObject, iModelServerDeliveryCardapio<TCARDAPIO>)
  private
    FConnection: iModelServerDeliveryConnection;
    FQuery: TFDQuery;
    FSQL: string;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iModelServerDeliveryCardapio<TCARDAPIO>;
    function Save(aValue: TCARDAPIO): TJSONObject;
    function GetAll: TJSONArray;
    function GetByID(aID: Integer): TJSONObject;
    function GetByTipo(aID_TIPO: Integer): TJSONArray;
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

  FSQL := 'DELETE FROM CARDAPIOS WHERE ID = :id';
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
  FSQL := 'SELECT C.ID, C.DESCRICAO, C.PRECO, T.DESCRICAO AS TIPO FROM CARDAPIOS C LEFT JOIN TIPOS_CARDAPIO T ON T.ID = C.TIPO ORDER BY C.ID';
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
  FSQL := 'SELECT C.ID, C.DESCRICAO, C.PRECO, T.DESCRICAO AS TIPO FROM CARDAPIOS C LEFT JOIN TIPOS_CARDAPIO T ON T.ID = C.TIPO WHERE C.ID = :ID';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('ID').Value := aID;
    Open;
  end;
  Result := FQuery.ToJSONObject();
end;

function TModelServerDeliveryCardapio.GetByTipo(aID_TIPO: Integer): TJSONArray;
begin
  FSQL := 'SELECT C.ID, C.DESCRICAO, C.PRECO, T.DESCRICAO AS TIPO FROM CARDAPIOS C LEFT JOIN TIPOS_CARDAPIO T ON T.ID = C.TIPO WHERE T.ID = :ID';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('ID').Value := aID_TIPO;
    Open;
  end;
  Result := FQuery.ToJSONArray();
end;

class function TModelServerDeliveryCardapio.New: iModelServerDeliveryCardapio<TCARDAPIO>;
begin
  Result := Self.Create;
end;

function TModelServerDeliveryCardapio.Save(aValue: TCARDAPIO): TJSONObject;
var
  lProduto: TPRODUTO;
  lResultPRodutos: TJSONArray;
begin
  FSQL := 'INSERT INTO CARDAPIOS (ID, DESCRICAO, PRECO, TIPO) VALUES (Null, :DESCRICAO, :PRECO, :TIPO);';

  try
    with FQuery do
    begin
      Connection.StartTransaction;
      SQL.Text := FSQL;
      ParamByName('DESCRICAO').Value := aValue.DESCRICAO;
      ParamByName('PRECO').Value := aValue.PRECO;
      ParamByName('TIPO').Value := aValue.TIPO_CARDAPIO.ID;
      ExecSQL;

      FSQL := 'INSERT INTO CARDAPIO_PRODUTO (ID, ID_CARDAPIO, ID_PRODUTO) VALUES (Null, (SELECT ID FROM CARDAPIOS ORDER BY ID DESC LIMIT 1), :ID_PRODUTO);';

      for lProduto in aValue.PRODUTO do
      begin
        SQL.Text := FSQL;
        ParamByName('ID_PRODUTO').Value := lProduto.ID;
        ExecSQL;
      end;

      FSQL := 'SELECT P.ID AS ID, P.NOME AS NOME, P.ESTOQUE AS ESTOQUE, P.CUSTO AS CUSTO, P.PERCENTUAL_LUCRO AS PERCENTUAL ' + 'FROM CARDAPIO_PRODUTO CP LEFT JOIN CARDAPIOS C ON CP.ID_CARDAPIO = C.ID LEFT JOIN PRODUTOS P ON CP.ID_PRODUTO = P.ID ' + 'WHERE C.ID = (SELECT ID FROM CARDAPIOS ORDER BY ID DESC LIMIT 1);';

      Close;
      SQL.Text := FSQL;
      Open;
      lResultPRodutos := TJSONArray.Create;
      lResultPRodutos := FQuery.ToJSONArray();

      FSQL := 'SELECT C.ID, C.DESCRICAO, C.PRECO, T.DESCRICAO AS TIPO FROM CARDAPIOS C LEFT JOIN TIPOS_CARDAPIO T ON T.ID = C.TIPO ORDER BY C.ID DESC LIMIT 1;';

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
var
  lProduto: TPRODUTO;
  lResultPRodutos: TJSONArray;
begin
  FSQL := 'UPDATE CARDAPIOS SET DESCRICAO = :DESCRICAO, PRECO = :PRECO, TIPO = :TIPO WHERE ID = :ID;';
  try
    with FQuery do
    begin
      Connection.StartTransaction;
      SQL.Text := FSQL;

      ParamByName('ID').Value := aValue.ID;
      ParamByName('DESCRICAO').Value := aValue.DESCRICAO;
      ParamByName('PRECO').Value := aValue.PRECO;
      ParamByName('TIPO').Value := aValue.TIPO_CARDAPIO.ID;
      ExecSQL;

      FSQL := 'UPDATE CARDAPIO_PRODUTO SET ID_PRODUTO = :ID_PRODUTO WHERE ID_CARDAPIO = :ID_CARDAPIO;';

      for lProduto in aValue.PRODUTO do
      begin
        SQL.Text := FSQL;
        ParamByName('ID_PRODUTO').Value := lProduto.ID;
        ParamByName('ID_CARDAPIO').Value := aValue.ID;
        ExecSQL;
      end;

      Connection.Commit;

      FSQL := 'SELECT C.ID, C.DESCRICAO, C.PRECO, T.DESCRICAO AS TIPO FROM CARDAPIOS C LEFT JOIN TIPOS_CARDAPIO T ON T.ID = C.TIPO WHERE C.ID = :ID';

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

