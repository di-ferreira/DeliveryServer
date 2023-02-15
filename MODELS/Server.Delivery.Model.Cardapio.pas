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
    FCardapios:TObjectList<TCARDAPIO>;
    FSQL: string;
    function GetProdutoCardapio(aIDCardapio:Integer):TObjectList<TPRODUTO>;
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
    function ListByTipo(aID_TIPO: Integer): TObjectList<TCARDAPIO>;
    function ListAll: TObjectList<TCARDAPIO>;
    function ListOne(aID: Integer): TCARDAPIO;
  end;

implementation
uses
  Server.Delivery.Controller.Interfaces, Server.Delivery.Controller;
{ TModelServerDeliveryCardapio }

constructor TModelServerDeliveryCardapio.Create;
begin
  FConnection := TServerDeliverySQLiteConnection.New;
  FQuery := TFDQuery.Create(nil);
  FCardapios := TObjectList<TCARDAPIO>.Create;
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
  FreeAndNil(FCardapios);
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
var
  lCardapioJSON, lProdutoJSON:TJSONObject;
  lProdutos:TJSONArray;
  lController: iControllerServerDelivery;
  I:integer;
begin
  lController := TControllerServerDelivery.New;

  FSQL := 'SELECT ID, DESCRICAO, PRECO, TIPO FROM CARDAPIOS WHERE ID = :ID';

  lCardapioJSON := TJSONObject.Create;
  lProdutoJSON := TJSONObject.Create;
  lProdutos := TJSONArray.Create;

  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('ID').Value := aID;
    Open;

    lCardapioJSON.AddPair('id', FQuery.FieldByName('ID').AsInteger);
    lCardapioJSON.AddPair('descricao', FQuery.FieldByName('DESCRICAO').AsString);
    lCardapioJSON.AddPair('preco', FQuery.FieldByName('PRECO').AsFloat);
    lCardapioJSON.AddPair('tipo', lController.TIPO_CARDAPIO.GetByID(FQuery.FieldByName('TIPO').AsInteger));

    FSQL := 'SELECT ID, ID_CARDAPIO, ID_PRODUTO FROM CARDAPIO_PRODUTO WHERE ID = :ID_CARDAPIO;';
    Close;
    SQL.Text := FSQL;
    ParamByName('ID_CARDAPIO').Value := aID;
    Open;

    for I := 0 to Pred(FQuery.RecordCount) do
    begin
      lProdutos.Add(lController.PRODUTO.GetByID(FieldByName('ID_PRODUTO').AsInteger));
      FQuery.Next;
    end;

    lCardapioJSON.AddPair('produtos',lProdutos);
  end;

  Result := lCardapioJSON;
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

function TModelServerDeliveryCardapio.GetProdutoCardapio(
  aIDCardapio: Integer): TObjectList<TPRODUTO>;
  var
  aPRODUTOS:TObjectList<TPRODUTO>;
  aPRODUTO:TPRODUTO;
begin
  FSQL := 'SELECT P.ID AS ID, P.NOME AS NOME, P.ESTOQUE AS ESTOQUE,' +
          'P.CUSTO AS CUSTO, P.PERCENTUAL_LUCRO AS PERCENTUAL ' +
          'FROM CARDAPIO_PRODUTO CP ' +
          'LEFT JOIN CARDAPIOS C ON CP.ID_CARDAPIO = C.ID ' +
          'LEFT JOIN PRODUTOS P ON CP.ID_PRODUTO = P.ID ' +
          'WHERE C.ID = :ID_CARDAPIO';

  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('ID_CARDAPIO').Value := aIDCardapio;
    Open;

    aPRODUTOS := TObjectList<TPRODUTO>.Create;

     if RecordCount > 0 then
      First;
    while (not Eof) do
    begin
      aPRODUTO := TPRODUTO.Create;
      aPRODUTO.ID := FieldByName('ID').AsInteger;
      aPRODUTO.NOME := FieldByName('NOME').AsString;
      aPRODUTO.ESTOQUE := FieldByName('ESTOQUE').AsInteger;
      aPRODUTO.CUSTO := FieldByName('CUSTO').AsFloat;
      aPRODUTO.LUCRO := FieldByName('PERCENTUAL').AsFloat;

      aPRODUTOS.Add(aPRODUTO);
      Next;
    end;
  end;
  Result := aPRODUTOS;
end;

function TModelServerDeliveryCardapio.ListAll: TObjectList<TCARDAPIO>;
var
  aCardapio: TCARDAPIO;
begin
  FSQL := 'SELECT C.ID AS ID, C.DESCRICAO AS DESCRICAO, C.PRECO, T.DESCRICAO AS TIPO, T.ID AS ID_TIPO FROM CARDAPIOS C LEFT JOIN TIPOS_CARDAPIO T ON T.ID = C.TIPO ORDER BY C.ID';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    Open;

    if RecordCount > 0 then
      First;
    while (not Eof) do
    begin
      aCardapio := TCARDAPIO.Create;
      aCardapio.ID := FieldByName('ID').AsInteger;
      aCardapio.DESCRICAO := FieldByName('DESCRICAO').AsString;
      aCardapio.TIPO_CARDAPIO.ID := FieldByName('ID_TIPO').AsInteger;
      aCardapio.TIPO_CARDAPIO.DESCRICAO := FieldByName('TIPO').AsString;
      FCardapios.Add(aCardapio);
      Next;
    end;
  end;

  Result := FCardapios;
end;

function TModelServerDeliveryCardapio.ListByTipo(aID_TIPO: Integer): TObjectList<TCARDAPIO>;
var
  aCardapio: TCARDAPIO;
  aTipo: TTIPO_CARDAPIO;
  aProduto: TPRODUTO;
begin
  FSQL := 'SELECT C.ID, C.DESCRICAO, C.PRECO, T.DESCRICAO AS TIPO, T.ID AS ID_TIPO FROM CARDAPIOS C LEFT JOIN TIPOS_CARDAPIO T ON T.ID = C.TIPO WHERE C.ID = :ID;';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('ID').Value := aID_TIPO;
    Open;

    if RecordCount > 0 then
      First;
    while (not Eof) do
    begin
      aCardapio := TCARDAPIO.Create;
      aTipo := TTIPO_CARDAPIO.Create;
      aProduto := TPRODUTO.Create;
      aCardapio.ID := FieldByName('ID').AsInteger;
      aCardapio.DESCRICAO := FieldByName('DESCRICAO').AsString;
      aTipo.ID := FieldByName('ID_TIPO').AsInteger;
      aTipo.DESCRICAO := FieldByName('TIPO').AsString;
      aCardapio.TIPO_CARDAPIO := aTipo;
      aCardapio.PRODUTO := GetProdutoCardapio(aCardapio.ID);
      FCardapios.Add(aCardapio);
      Next;
    end;
  end;

  Result := FCardapios;
end;

function TModelServerDeliveryCardapio.ListOne(aID: Integer): TCARDAPIO;
begin

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

