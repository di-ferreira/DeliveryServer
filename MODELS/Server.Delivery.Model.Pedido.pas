unit Server.Delivery.Model.Pedido;

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
  TModelServerDeliveryPedido = class(TInterfacedObject, iModelServerDeliveryPedido<TPEDIDO>)
  private
    FConnection: iModelServerDeliveryConnection;
    FQuery: TFDQuery;
    FSQL: string;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iModelServerDeliveryPedido<TPEDIDO>;
    function Save(aValue: TPEDIDO): TJSONObject;
    function CreateWithItems(aValue: TPEDIDO): TJSONObject;
    function GetAll: TJSONArray;
    function GetByID(aID: Integer): TJSONObject;
    function Update(aValue: TPEDIDO): TJSONObject;
    function Delete(aID: Integer): TJSONObject;
    function GetByCaixa(aIDCaixa: Integer): TJSONArray;
    function GetByCliente(aIDCliente: Integer): TJSONArray;
  end;

implementation
{ TModelServerDeliveryPedido }

constructor TModelServerDeliveryPedido.Create;
begin
  FConnection := TServerDeliverySQLiteConnection.New;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection.Connection;
  FConnection.Connection.TxOptions.AutoCommit := False;
end;

function TModelServerDeliveryPedido.CreateWithItems(aValue: TPEDIDO): TJSONObject;
var
  CaixaJSON, ClienteJSON, EnderecoJSON, PedidoJSON, PedidoResultJSON: TJSONObject;
begin
  FSQL := 'INSERT INTO PEDIDOS ("DATA", TOTAL, CANCELADO, ABERTO, OBS, CAIXA, CLIENTE, ENDERECO_ENTREGA) VALUES(CURRENT_TIMESTAMP, :TOTAL, :CANCELADO, :ABERTO, :OBS, :CAIXA, :CLIENTE, :ENDERECO_ENTREGA);';

  try
    with FQuery do
    begin
      Connection.StartTransaction;
      SQL.Text := FSQL;
      ParamByName('TOTAL').Value := aValue.TOTAL;
      ParamByName('CANCELADO').Value := aValue.CANCELADO;
      ParamByName('ABERTO').Value := aValue.ABERTO;
      ParamByName('OBS').Value := aValue.OBS;
      ParamByName('CAIXA').Value := aValue.CAIXA.ID;
      ParamByName('CLIENTE').Value := aValue.CLIENTE.ID;
      ParamByName('ENDERECO_ENTREGA').Value := aValue.ENDERECO_ENTREGA.ID;
      ExecSQL;

      CaixaJSON := TJSONObject.Create;
      ClienteJSON := TJSONObject.Create;
      EnderecoJSON := TJSONObject.Create;
      PedidoJSON := TJSONObject.Create;
      PedidoResultJSON := TJSONObject.Create;

      FSQL := 'SELECT ID, "DATA" AS DATA_PEDIDO, TOTAL, CANCELADO, ABERTO, OBS, CAIXA, CLIENTE, ENDERECO_ENTREGA FROM PEDIDOS ORDER BY ID DESC LIMIT 1;';

      Close;
      SQL.Text := FSQL;
      Open;
      PedidoJSON := FQuery.ToJSONObject();

      FSQL := 'SELECT ID, "DATA" AS DATA_ABERTURA, ABERTO, TOTAL FROM CAIXAS WHERE ID = :ID;';

      Close;
      SQL.Text := FSQL;
      ParamByName('ID').Value := PedidoJSON.GetValue<integer>('caixa');
      Open;
      CaixaJSON := FQuery.ToJSONObject();

      FSQL := 'SELECT id AS ID, nome AS NOME, contato AS CONTATO FROM CLIENTES WHERE ID = :ID;';

      Close;
      SQL.Text := FSQL;
      ParamByName('ID').Value := PedidoJSON.GetValue<integer>('cliente');
      Open;
      ClienteJSON := FQuery.ToJSONObject();

      FSQL := 'SELECT ID, RUA, NUMERO, BAIRRO, COMPLEMENTO, CIDADE, ESTADO FROM ENDERECOS WHERE ID = :ID;';

      Close;
      SQL.Text := FSQL;
      ParamByName('ID').Value := PedidoJSON.GetValue<integer>('enderecoEntrega');
      Open;
      EnderecoJSON := FQuery.ToJSONObject();

      PedidoResultJSON.AddPair('id', PedidoJSON.GetValue<integer>('id')).AddPair('dataPedido', FormatDateTime('dd-mm-yy hh:mm:ss', PedidoJSON.GetValue<TDateTime>('dataPedido'))).AddPair('total', PedidoJSON.GetValue<Double>('total')).AddPair('cancelado', PedidoJSON.GetValue<Boolean>('cancelado')).AddPair('aberto', PedidoJSON.GetValue<Boolean>('aberto')).AddPair('obs', PedidoJSON.GetValue<string>('obs')).AddPair('cliente', ClienteJSON).AddPair('enderecoEntrega', EnderecoJSON).AddPair('caixa', CaixaJSON);

      Connection.Commit;
    end;
    Result := PedidoResultJSON;
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

function TModelServerDeliveryPedido.Delete(aID: Integer): TJSONObject;
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

destructor TModelServerDeliveryPedido.Destroy;
begin
  FreeAndNil(FQuery);
  inherited;
end;

function TModelServerDeliveryPedido.GetAll: TJSONArray;
begin
  FSQL := 'SELECT ID, NOME, ESTOQUE, CUSTO, PERCENTUAL_LUCRO AS LUCRO FROM PRODUTOS';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    Open;
  end;
  Result := FQuery.ToJSONArray();
end;

function TModelServerDeliveryPedido.GetByCaixa(aIDCaixa: Integer): TJSONArray;
begin

end;

function TModelServerDeliveryPedido.GetByCliente(aIDCliente: Integer): TJSONArray;
begin

end;

function TModelServerDeliveryPedido.GetByID(aID: Integer): TJSONObject;
begin
  FSQL := 'SELECT ID, NOME, ESTOQUE, CUSTO, PERCENTUAL_LUCRO AS LUCRO FROM PRODUTOS WHERE ID=:ID';
  with FQuery do
  begin
    Close;
    SQL.Text := FSQL;
    ParamByName('ID').Value := aID;
    Open;
  end;
  Result := FQuery.ToJSONObject();
end;

class function TModelServerDeliveryPedido.New: iModelServerDeliveryPedido<TPEDIDO>;
begin
  Result := Self.Create;
end;

function TModelServerDeliveryPedido.Save(aValue: TPEDIDO): TJSONObject;
var
  CaixaJSON, ClienteJSON, EnderecoJSON, PedidoJSON, PedidoResultJSON: TJSONObject;
begin
  FSQL := 'INSERT INTO PEDIDOS ("DATA", TOTAL, CANCELADO, ABERTO, OBS, CAIXA, CLIENTE, ENDERECO_ENTREGA) VALUES(CURRENT_TIMESTAMP, :TOTAL, :CANCELADO, :ABERTO, :OBS, :CAIXA, :CLIENTE, :ENDERECO_ENTREGA);';

  try
    with FQuery do
    begin
      Connection.StartTransaction;
      SQL.Text := FSQL;
      ParamByName('TOTAL').Value := aValue.TOTAL;
      ParamByName('CANCELADO').Value := aValue.CANCELADO;
      ParamByName('ABERTO').Value := aValue.ABERTO;
      ParamByName('OBS').Value := aValue.OBS;
      ParamByName('CAIXA').Value := aValue.CAIXA.ID;
      ParamByName('CLIENTE').Value := aValue.CLIENTE.ID;
      ParamByName('ENDERECO_ENTREGA').Value := aValue.ENDERECO_ENTREGA.ID;
      ExecSQL;

      CaixaJSON := TJSONObject.Create;
      ClienteJSON := TJSONObject.Create;
      EnderecoJSON := TJSONObject.Create;
      PedidoJSON := TJSONObject.Create;
      PedidoResultJSON := TJSONObject.Create;

      FSQL := 'SELECT ID, "DATA" AS DATA_PEDIDO, TOTAL, CANCELADO, ABERTO, OBS, CAIXA, CLIENTE, ENDERECO_ENTREGA FROM PEDIDOS ORDER BY ID DESC LIMIT 1;';

      Close;
      SQL.Text := FSQL;
      Open;
      PedidoJSON := FQuery.ToJSONObject();

      FSQL := 'SELECT ID, "DATA" AS DATA_ABERTURA, ABERTO, TOTAL FROM CAIXAS WHERE ID = :ID;';

      Close;
      SQL.Text := FSQL;
      ParamByName('ID').Value := PedidoJSON.GetValue<integer>('caixa');
      Open;
      CaixaJSON := FQuery.ToJSONObject();

      FSQL := 'SELECT id AS ID, nome AS NOME, contato AS CONTATO FROM CLIENTES WHERE ID = :ID;';

      Close;
      SQL.Text := FSQL;
      ParamByName('ID').Value := PedidoJSON.GetValue<integer>('cliente');
      Open;
      ClienteJSON := FQuery.ToJSONObject();

      FSQL := 'SELECT ID, RUA, NUMERO, BAIRRO, COMPLEMENTO, CIDADE, ESTADO FROM ENDERECOS WHERE ID = :ID;';

      Close;
      SQL.Text := FSQL;
      ParamByName('ID').Value := PedidoJSON.GetValue<integer>('enderecoEntrega');
      Open;
      EnderecoJSON := FQuery.ToJSONObject();

      PedidoResultJSON.AddPair('id', PedidoJSON.GetValue<integer>('id')).AddPair('dataPedido', FormatDateTime('dd-mm-yy hh:mm:ss', PedidoJSON.GetValue<TDateTime>('dataPedido'))).AddPair('total', PedidoJSON.GetValue<Double>('total')).AddPair('cancelado', PedidoJSON.GetValue<Boolean>('cancelado')).AddPair('aberto', PedidoJSON.GetValue<Boolean>('aberto')).AddPair('obs', PedidoJSON.GetValue<string>('obs')).AddPair('cliente', ClienteJSON).AddPair('enderecoEntrega', EnderecoJSON).AddPair('caixa', CaixaJSON);

      Connection.Commit;
    end;
    Result := PedidoResultJSON;
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

function TModelServerDeliveryPedido.Update(aValue: TPEDIDO): TJSONObject;
begin
//  FSQL := 'UPDATE PRODUTOS SET nome = :nome, ESTOQUE = :ESTOQUE, CUSTO = :CUSTO, PERCENTUAL_LUCRO = :PERCENTUAL_LUCRO WHERE id = :id';
//  try
//    with FQuery do
//    begin
//      Connection.StartTransaction;
//      SQL.Text := FSQL;
//
//      ParamByName('id').Value := aValue.ID;
//      ParamByName('nome').Value := aValue.NOME;
//      ParamByName('ESTOQUE').Value := aValue.ESTOQUE;
//      ParamByName('CUSTO').Value := aValue.CUSTO;
//      ParamByName('PERCENTUAL_LUCRO').Value := aValue.LUCRO;
//      ExecSQL;
//      Connection.Commit;
//
//      FSQL := 'SELECT ID, NOME, ESTOQUE, CUSTO, PERCENTUAL_LUCRO AS LUCRO FROM PRODUTOS WHERE ID=:ID;';
//
//      Close;
//      SQL.Text := FSQL;
//      ParamByName('ID').Value := aValue.ID;
//      Open;
//    end;
//    Result := FQuery.ToJSONObject();
//  except
//    on E: Exception do
//    begin
//      with FQuery do
//      begin
//        Connection.Rollback;
//        Result := TJSONObject.Create;
//      end;
//    end;
//  end;
end;

end.

