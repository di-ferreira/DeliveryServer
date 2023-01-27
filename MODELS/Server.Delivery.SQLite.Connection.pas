unit Server.Delivery.SQLite.Connection;

interface

uses
{(*}
  Server.Delivery.Model.Interfaces,
  {FIREDAC CONNECTION}
  System.SysUtils, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLite, FireDAC.Comp.UI,
  Data.DB, FireDAC.Comp.Client;
{*)}

type
  TServerDeliverySQLiteConnection = class(TInterfacedObject, iModelServerDeliveryConnection)
  private
    FConnection: TFDConnection;
    FWaitCursor: TFDGUIxWaitCursor;
    FDriveLink: TFDPhysSQLiteDriverLink;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iModelServerDeliveryConnection;
    function Connection: TFDConnection;
    procedure AfterConnection(Sender: TObject);
  end;

implementation

{ TServerDeliverySQLiteConnection }

procedure TServerDeliverySQLiteConnection.AfterConnection(Sender: TObject);
begin
  FConnection.ExecSQL('CREATE TABLE IF NOT EXISTS TIPOS_PAGAMENTO (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, DESCRICAO STRING NOT NULL);');
  FConnection.ExecSQL('CREATE TABLE IF NOT EXISTS TIPOS_CARDAPIO (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, DESCRICAO STRING NOT NULL);');
  FConnection.ExecSQL('CREATE TABLE IF NOT EXISTS PRODUTOS (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, NOME STRING NOT NULL, ESTOQUE INTEGER NOT NULL DEFAULT (0), CUSTO DECIMAL(10, 2) NOT NULL DEFAULT (0.0), PERCENTUAL_LUCRO DECIMAL (10, 2) NOT NULL DEFAULT (0.0));');
  FConnection.ExecSQL('CREATE TABLE IF NOT EXISTS CLIENTES (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, nome STRING NOT NULL, contato STRING  NOT NULL UNIQUE);');
  FConnection.ExecSQL('CREATE TABLE IF NOT EXISTS CAIXAS (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, DATA DATE DEFAULT (CURRENT_TIMESTAMP) NOT NULL, ABERTO BOOLEAN NOT NULL DEFAULT (true),TOTAL  DECIMAL (10, 2) DEFAULT (0.00));');
  FConnection.ExecSQL('CREATE TABLE IF NOT EXISTS CARDAPIOS (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, DESCRICAO STRING  NOT NULL, PRECO DECIMAL (10, 2) NOT NULL DEFAULT (0.0), TIPO INTEGER NOT NULL DEFAULT (1) REFERENCES TIPOS_CARDAPIO (ID));');
  FConnection.ExecSQL('CREATE TABLE IF NOT EXISTS CARDAPIO_PRODUTO (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, ID_CARDAPIO INTEGER NOT NULL DEFAULT (0) REFERENCES CARDAPIOS (ID), ID_PRODUTO INTEGER NOT NULL DEFAULT (0) REFERENCES PRODUTOS (ID));');
  FConnection.ExecSQL('CREATE TABLE IF NOT EXISTS ENDERECOS (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, RUA STRING NOT NULL, NUMERO STRING NOT NULL, BAIRRO STRING NOT NULL, ' + 'COMPLEMENTO STRING, CIDADE STRING, ESTADO STRING, ID_CLIENTE INTEGER NOT NULL REFERENCES CLIENTES (id) ON DELETE CASCADE);');
  FConnection.ExecSQL('CREATE TABLE IF NOT EXISTS PEDIDOS (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, DATA DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),TOTAL DECIMAL (10, 2) NOT NULL DEFAULT (0.0), CANCELADO BOOLEAN NOT NULL DEFAULT (false),' + 'ABERTO BOOLEAN NOT NULL DEFAULT (true), OBS TEXT, TIPO_PAGAMENTO INTEGER  REFERENCES TIPOS_PAGAMENTO (ID) NOT NULL,' + ' CAIXA INTEGER NOT NULL REFERENCES CAIXA (id), CLIENTE INTEGER NOT NULL REFERENCES CLIENTES (id), ENDERECO_ENTREGA INTEGER NOT NULL REFERENCES ENDERECOS (ID));');
  FConnection.ExecSQL('CREATE TABLE IF NOT EXISTS CAIXA_PEDIDO (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, ID_CAIXA INTEGER REFERENCES CAIXA (id) NOT NULL, ID_PEDIDO INTEGER NOT NULL);');
  FConnection.ExecSQL('CREATE TABLE IF NOT EXISTS ITEMS_PEDIDO (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, ' + 'TOTAL DECIMAL (10, 2) NOT NULL DEFAULT (0.0), QUANTIDADE INTEGER NOT NULL DEFAULT (1), ITEM_CARDAPIO INTEGER REFERENCES CARDAPIOS (ID) NOT NULL, PEDIDO INTEGER REFERENCES PEDIDOS (ID) NOT NULL);');
end;

function TServerDeliverySQLiteConnection.Connection: TFDConnection;
begin
  Result := FConnection;
end;

constructor TServerDeliverySQLiteConnection.Create;
var
  aDir: string;
begin
  FConnection := TFDConnection.Create(nil);
  FWaitCursor := TFDGUIxWaitCursor.Create(nil);
  FDriveLink := TFDPhysSQLiteDriverLink.Create(nil);
    //Configura o tipo de banco de dados
  FConnection.DriverName := 'SQLite';
  FConnection.LoginPrompt := False;
  aDir := System.SysUtils.GetCurrentDir + '\DB';

  if not DirectoryExists(aDir) then
    ForceDirectories(aDir);

  FConnection.Params.Values['Database'] := aDir + '\Server_Delivery.db';

  FConnection.AfterConnect := AfterConnection;
  FConnection.Connected := True;
end;

destructor TServerDeliverySQLiteConnection.Destroy;
begin
  FreeAndNil(FConnection);
  FreeAndNil(FWaitCursor);
  FreeAndNil(FDriveLink);
  inherited;
end;

class function TServerDeliverySQLiteConnection.New: iModelServerDeliveryConnection;
begin
  Result := Self.Create;
end;

end.

