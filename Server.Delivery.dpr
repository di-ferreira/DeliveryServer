program Server.Delivery;

uses
  Vcl.Forms,
  View.Main.Server in 'View.Main.Server.pas' {ViewMainServer},
  DM.Server in 'DM.Server.pas' {DataModule1: TDataModule},
  Server.Delivery.SQLite.Connection in 'MODELS\Server.Delivery.SQLite.Connection.pas',
  Server.Delivery.Model.Interfaces in 'MODELS\Server.Delivery.Model.Interfaces.pas',
  Server.Delivery.Model.Produto in 'MODELS\Server.Delivery.Model.Produto.pas',
  Server.Delivery.DTO in 'DTO\Server.Delivery.DTO.pas',
  Server.Delivery.Controller.Interfaces in 'CONTROLLERS\Server.Delivery.Controller.Interfaces.pas',
  Server.Delivery.Controller in 'CONTROLLERS\Server.Delivery.Controller.pas',
  Server.Delivery.MySQL.Connection in 'MODELS\Server.Delivery.MySQL.Connection.pas',
  Server.Delivery.Model.Cliente in 'MODELS\Server.Delivery.Model.Cliente.pas',
  Controllers.Server.Delivery.Cliente.Route in 'CONTROLLERS\Controllers.Server.Delivery.Cliente.Route.pas',
  Server.Delivery.Controller.Routes in 'CONTROLLERS\Server.Delivery.Controller.Routes.pas',
  Controllers.Server.Delivery.Endereco.Route in 'CONTROLLERS\Controllers.Server.Delivery.Endereco.Route.pas',
  Server.Delivery.Model.Endereco in 'MODELS\Server.Delivery.Model.Endereco.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TViewMainServer, ViewMainServer);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.Run;
end.
