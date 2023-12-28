unit DM.Server;

interface

uses
  System.SysUtils,
  System.Classes,
  Server.Delivery.Model.Interfaces,
  Server.Delivery.SQLite.Connection;

type
  TDataModuleServer = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public

    ServerConnection: iModelServerDeliveryConnection;
  end;

var
  DataModuleServer: TDataModuleServer;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

procedure TDataModuleServer.DataModuleCreate(Sender: TObject);
begin
  ServerConnection := TServerDeliverySQLiteConnection.New;
end;

end.
