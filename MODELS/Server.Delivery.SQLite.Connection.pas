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
  FConnection.ExecSQL('CREATE TABLE IF NOT EXISTS PRODUTOS (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, NOME STRING NOT NULL, ESTOQUE INTEGER NOT NULL DEFAULT (0), CUSTO DECIMAL(10, 2) NOT NULL DEFAULT (0.0), PERCENTUAL_LUCRO DECIMAL (10, 2) NOT NULL DEFAULT (0.0));');
  FConnection.ExecSQL('CREATE TABLE IF NOT EXISTS CLIENTES (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, nome STRING NOT NULL, contato STRING  NOT NULL UNIQUE);');
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

