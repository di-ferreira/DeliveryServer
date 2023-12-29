unit Server.Delivery.MySQL.Connection;

interface

uses
  Server.Delivery.Model.Interfaces,
  {FIREDAC CONNECTION}
  System.SysUtils, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL, FireDAC.Comp.UI, Data.DB,
  FireDAC.Comp.Client, cqlbr.Interfaces;

type
  TServerDeliveryMySQLConnection = class(TInterfacedObject,
    iModelServerDeliveryConnection)
  private
    FConnection: TFDConnection;
    FWaitCursor: TFDGUIxWaitCursor;
    FDriveLink: TFDPhysMySQLDriverLink;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iModelServerDeliveryConnection;
    function Connection: TFDConnection;
    procedure AfterConnection(Sender: TObject);
    function SQL: ICQL;
  end;

implementation

uses
  criteria.query.language;

{ TServerDeliveryMySQLConnection }

procedure TServerDeliveryMySQLConnection.AfterConnection(Sender: TObject);
begin
  // Cria tabelas de Produtos
  FConnection.ExecSQL
    ('CREATE TABLE IF NOT EXISTS PRODUTOS (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, nome STRING NOT NULL, preco DECIMAL (10, 2) NOT NULL, estoque INTEGER NOT NULL DEFAULT (0));');
end;

function TServerDeliveryMySQLConnection.Connection: TFDConnection;
begin
  Result := FConnection;
end;

constructor TServerDeliveryMySQLConnection.Create;
var
  aDir: string;
begin
  FConnection := TFDConnection.Create(nil);
  FWaitCursor := TFDGUIxWaitCursor.Create(nil);
  FDriveLink := TFDPhysMySQLDriverLink.Create(nil);
  // Configura o tipo de banco de dados

  FConnection.Connected := True;

  FConnection.AfterConnect := AfterConnection;
end;

destructor TServerDeliveryMySQLConnection.Destroy;
begin
  FreeAndNil(FConnection);
  FreeAndNil(FWaitCursor);
  FreeAndNil(FDriveLink);
  inherited;
end;

class function TServerDeliveryMySQLConnection.New
  : iModelServerDeliveryConnection;
begin
  Result := Self.Create;
end;

function TServerDeliveryMySQLConnection.SQL: ICQL;
begin
  Result := TCQL.New(dbnMySQL);
end;

end.
