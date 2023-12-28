program Server.Delivery;

uses
  Vcl.Forms,
  uTInject.ConfigCEF,
  View.Main.Server in 'View.Main.Server.pas' {ViewMainServer},
  DM.Server in 'DM.Server.pas' {DataModuleServer: TDataModule},
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
  Server.Delivery.Model.Endereco in 'MODELS\Server.Delivery.Model.Endereco.pas',
  Controllers.Server.Delivery.Produto.Route in 'CONTROLLERS\Controllers.Server.Delivery.Produto.Route.pas',
  Controllers.Server.Delivery.TipoCardapio.Route in 'CONTROLLERS\Controllers.Server.Delivery.TipoCardapio.Route.pas',
  Server.Delivery.Model.TipoCardapio in 'MODELS\Server.Delivery.Model.TipoCardapio.pas',
  Server.Delivery.Model.TipoPgto in 'MODELS\Server.Delivery.Model.TipoPgto.pas',
  Controllers.Server.Delivery.TipoPgto.Route in 'CONTROLLERS\Controllers.Server.Delivery.TipoPgto.Route.pas',
  Controllers.Server.Delivery.Cardapio.Route in 'CONTROLLERS\Controllers.Server.Delivery.Cardapio.Route.pas',
  Server.Delivery.Model.Cardapio in 'MODELS\Server.Delivery.Model.Cardapio.pas',
  Server.Delivery.Model.Caixa in 'MODELS\Server.Delivery.Model.Caixa.pas',
  Controllers.Server.Delivery.Caixa.Route in 'CONTROLLERS\Controllers.Server.Delivery.Caixa.Route.pas',
  Fnc_Utils in 'UTILS\Fnc_Utils.pas',
  Server.Delivery.Model.Pedido in 'MODELS\Server.Delivery.Model.Pedido.pas',
  Server.Delivery.Model.ItemPedido in 'MODELS\Server.Delivery.Model.ItemPedido.pas',
  Controllers.Server.Delivery.Pedido.Route in 'CONTROLLERS\Controllers.Server.Delivery.Pedido.Route.pas',
  Server.Delivery.Bot.Chat in 'BOT\Server.Delivery.Bot.Chat.pas',
  Server.Delivery.Bot.Manager in 'BOT\Server.Delivery.Bot.Manager.pas',
  Server.Delivery.Bot.Resposta.Chat in 'BOT\Server.Delivery.Bot.Resposta.Chat.pas',
  Server.Delivery.Controller.Bot in 'BOT\Server.Delivery.Controller.Bot.pas';

{$R *.res}

begin

  if not GlobalCEFApp.StartMainProcess then
    Exit;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TViewMainServer, ViewMainServer);
  Application.CreateForm(TDataModuleServer, DataModuleServer);
  Application.Run;

end.
