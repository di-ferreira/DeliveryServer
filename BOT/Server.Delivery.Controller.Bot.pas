unit Server.Delivery.Controller.Bot;

interface

uses
  System.Classes, Server.Delivery.Bot.Manager;

type
  iServerDeliveryControllerBot = interface
    ['{811BB036-D040-49A2-B1BF-D7433C2A6749}']
    function NewBotManager(AOwner: TComponent):TServerDeliveryBotManager;
  end;

  TServerDeliveryControllerBot = class(TInterfacedObject, iServerDeliveryControllerBot)
  private
  public
  function NewBotManager(AOwner: TComponent):TServerDeliveryBotManager;
  end;

implementation

{ TServerDeliveryControllerBot }

function TServerDeliveryControllerBot.NewBotManager(
  AOwner: TComponent): TServerDeliveryBotManager;
begin

end;

end.

