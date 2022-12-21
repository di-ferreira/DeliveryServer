unit Server.Delivery.Controller.Routes;

interface

uses
  Horse, Controllers.Server.Delivery.Cliente.Route,
  Controllers.Server.Delivery.Endereco.Route;

procedure Registry;

implementation

procedure Registry;
begin
  Controllers.Server.Delivery.Cliente.Route.Registry;
  Controllers.Server.Delivery.Endereco.Route.Registry;
end;

end.

