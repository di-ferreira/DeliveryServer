unit Server.Delivery.Controller.Routes;

interface

uses
  Horse, Controllers.Server.Delivery.Cliente.Route;

procedure Registry;

implementation

procedure Registry;
begin
  Controllers.Server.Delivery.Cliente.Route.Registry;
end;

end.

