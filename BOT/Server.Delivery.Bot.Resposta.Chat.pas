unit Server.Delivery.Bot.Resposta.Chat;

interface

uses
  System.Classes, uTInject, Server.Delivery.Bot.Chat;

type
  TServerDeliveryBotRespostaChat = class
  private
    FBot: TInject;
    FCurrentChat: TServerDeliveryBotChat;
    procedure SetBot(const Value: TInject);
    procedure SetCurrentChat(const Value: TServerDeliveryBotChat);
  public
    constructor Create;
    destructor Destroy; override;
    property Bot: TInject read FBot write SetBot;
    property CurrentChat: TServerDeliveryBotChat read FCurrentChat write SetCurrentChat;
    procedure SendMessage(aStep: Integer; aMessage: string; aAttach: string = ''; aType: Integer = 0);
  end;

implementation

{ TServerDeliveryBotRespostaChat }


constructor TServerDeliveryBotRespostaChat.Create;
begin

end;

destructor TServerDeliveryBotRespostaChat.Destroy;
begin

  inherited;
end;

procedure TServerDeliveryBotRespostaChat.SetBot(const Value: TInject);
begin
  FBot := Value;
end;

procedure TServerDeliveryBotRespostaChat.SetCurrentChat(const Value: TServerDeliveryBotChat);
begin
  FCurrentChat := Value;
end;

procedure TServerDeliveryBotRespostaChat.SendMessage(aStep: Integer; aMessage, aAttach: string; aType: Integer);
begin
  FCurrentChat.Etapa := aStep;
  FCurrentChat.Pergunta := aMessage;
  FCurrentChat.Resposta := '';

  if aAttach <> '' then
    FBot.SendFile(FCurrentChat.ID, aAttach, FCurrentChat.Pergunta)
  else if aMessage <> '' then
    FBot.Send(FCurrentChat.ID, FCurrentChat.Pergunta);
end;

end.

