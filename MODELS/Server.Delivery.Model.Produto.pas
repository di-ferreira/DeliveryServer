unit Server.Delivery.Model.Produto;

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
  TModelSistemaVendaProduto = class(TInterfacedObject, iModelServerDelivery<TPRODUTO>)
  private
    FConnection: iModelServerDeliveryConnection;
    FQuery: TFDQuery;
    FSQL: string;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iModelServerDelivery<TPRODUTO>;
    function Save(aValue: TPRODUTO): TJSONObject;
    function GetAll: TJSONArray;
    function GetByID(aID: Integer): TJSONObject;
    function Update(aValue: TPRODUTO): TJSONObject;
    function Delete(aID: Integer): TJSONObject;
  end;

implementation
{ TModelSistemaVendaProduto }

constructor TModelSistemaVendaProduto.Create;
begin
  FConnection := TServerDeliverySQLiteConnection.New;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection.Connection;
  FConnection.Connection.TxOptions.AutoCommit := False;
end;

function TModelSistemaVendaProduto.Delete(aID: Integer): TJSONObject;
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
    except
      on E: Exception do
      begin
        Connection.Rollback;
//        ShowMessage('Erro ao excluir produto: ' + E.Message);
      end;
    end;
  end;
  Result := TJSONObject.Create;
end;

destructor TModelSistemaVendaProduto.Destroy;
begin
  FreeAndNil(FQuery);
  inherited;
end;

function TModelSistemaVendaProduto.GetAll: TJSONArray;
begin
  FSQL := 'SELECT ID, NOME, ESTOQUE, CUSTO, PERCENTUAL_LUCRO FROM PRODUTOS';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    Open;
  end;
  Result := FQuery.ToJSONArray();
end;

function TModelSistemaVendaProduto.GetByID(aID: Integer): TJSONObject;
begin
  FSQL := 'SELECT ID, NOME, ESTOQUE, CUSTO, PERCENTUAL_LUCRO FROM PRODUTOS WHERE ID=:ID';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('ID').Value := aID;
    Open;
  end;
  Result := FQuery.ToJSONObject();
end;

class function TModelSistemaVendaProduto.New: iModelServerDelivery<TPRODUTO>;
begin
  Result := Self.Create;
end;

function TModelSistemaVendaProduto.Save(aValue: TPRODUTO): TJSONObject;
begin
  FSQL := 'INSERT INTO PRODUTOS (ID, NOME, ESTOQUE, CUSTO, PERCENTUAL_LUCRO) VALUES (Null, :NOME, :ESTOQUE, :CUSTO, :PERCENTUAL_LUCRO);';

  try
    with FQuery do
    begin
      Connection.StartTransaction;
      SQL.Text := FSQL;
      ParamByName('NOME').Value := aValue.NOME;
      ParamByName('ESTOQUE').Value := aValue.ESTOQUE;
      ParamByName('CUSTO').Value := aValue.CUSTO;
      ParamByName('PERCENTUAL_LUCRO').Value := aValue.PERCENTUAL_LUCRO;
      ExecSQL;
      Connection.Commit;

      FSQL := 'SELECT ID, NOME, ESTOQUE, CUSTO, PERCENTUAL_LUCRO FROM PRODUTOS WHERE ID=last_insert_rowid();';

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

function TModelSistemaVendaProduto.Update(aValue: TPRODUTO): TJSONObject;
begin
//  FSQL := 'UPDATE PRODUTOS SET nome = :nome, preco = :preco, estoque = :estoque WHERE id = :id';
//  with FQuery do
//  begin
//    Connection.StartTransaction;
//    SQL.Text := FSQL;
//    try
//      try
//        ParamByName('id').Value := aValue.ID;
//        ParamByName('nome').Value := aValue.NOME;
//        ParamByName('preco').Value := aValue.PRECO;
//        ParamByName('estoque').Value := aValue.ESTOQUE;
//        ExecSQL;
//        Connection.Commit;
//      except
//        on E: Exception do
//        begin
//          Connection.Rollback;
//          ShowMessage('Erro ao atualizar produto: ' + E.Message);
//        end;
//      end;
//    finally
//      FSQL := 'SELECT id, nome, preco, estoque FROM PRODUTOS WHERE id=' + aValue.ID.ToString;
//      with FQuery do
//      begin
//        Close;
//        SQL.Text := FSQL;
//        Open;
//
//        FProduto.ID := FieldByName('id').AsInteger;
//        FProduto.NOME := FieldByName('nome').AsString;
//        FProduto.PRECO := FieldByName('preco').AsFloat;
//        FProduto.ESTOQUE := FieldByName('estoque').AsInteger;
//      end;
//      Result := FProduto;
//    end;
//  end;
  Result := TJSONObject.Create;
end;

end.

