unit Server.Delivery.Bot.Resposta.Chat;

interface

uses
{(*}
  uTInject,
  Vcl.Forms,
  System.Classes,
  System.SysUtils,
  System.AnsiStrings,
  System.Generics.Collections,
  Server.Delivery.DTO,
  Server.Delivery.Bot.Chat,
  Server.Delivery.Controller,
  Server.Delivery.Controller.Interfaces;
 {*)}
type
  TServerDeliveryBotRespostaChat = class
  private
    FBot: TInject;
    FCurrentChat: TServerDeliveryBotChat;
    FController: iControllerServerDelivery;
    procedure SetBot(const Value: TInject);
    procedure SetCurrentChat(const Value: TServerDeliveryBotChat);
    procedure SendMessage(aStep: Integer; aMessage: string; aAttach: string = ''; aType: Integer = 0);
  public
    constructor Create;
    destructor Destroy; override;
    property Bot: TInject read FBot write SetBot;
    property CurrentChat: TServerDeliveryBotChat read FCurrentChat write SetCurrentChat;
    function WelcomeMessage(aChat: TServerDeliveryBotChat): TServerDeliveryBotChat;
    function SendCardapio(aChat: TServerDeliveryBotChat): TServerDeliveryBotChat;
  end;

implementation

{ TServerDeliveryBotRespostaChat }

constructor TServerDeliveryBotRespostaChat.Create;
begin
  FCurrentChat := TServerDeliveryBotChat.Create(nil);
  FController := TControllerServerDelivery.New;
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

function TServerDeliveryBotRespostaChat.WelcomeMessage(aChat: TServerDeliveryBotChat): TServerDeliveryBotChat;
var
  aMsg, aPath: string;
begin
  aChat.Situacao := saEmAtendimento;

  aMsg := 'Olá *' + aChat.CLIENTE.NOME + '*! \n ';
  aMsg := aMsg + 'Bem vindo ao *ASTROBURGUER* \n ';
  aMsg := aMsg + 'Por favor *digite* um número como opção:\n\n ';

  //OPÇÔES
  aMsg := aMsg + '*1* - ' + ' Ver Cardápio \n ';
  aMsg := aMsg + '*2* - ' + ' Consultar meu pedido';

  aPath := ExtractFileDir(Application.ExeName) + '\ASSETS\IMAGES\BOT\astro-burguer.png';

  SendMessage(1, aMsg, aPath);
  Result := FCurrentChat;
end;

function TServerDeliveryBotRespostaChat.SendCardapio(aChat: TServerDeliveryBotChat): TServerDeliveryBotChat;
var
  aMsg: string;
  aTipos: TObjectList<TTIPO_CARDAPIO>;
  aCardapios: TObjectList<TCARDAPIO>;
  aCardapio: TCARDAPIO;
  I:Integer;
begin
//  aChat.Situacao := saEmAtendimento;
  aChat.Situacao := saNova;

  aTipos := FController.TIPO_CARDAPIO.ListAll;

  aMsg := '-- *CARDÁPIO* -- \n \n';

  for I := 0 to Pred(aTipos.Count) do
  begin
      aCardapios := FController.CARDAPIO.ListByTipo(aTipos.Items[I].ID);

      aMsg := aMsg + '- *' + Trim(aTipos.Items[I].DESCRICAO.ToUpper) + '* - \n ';

      for aCardapio in aCardapios do
      begin
        aMsg := aMsg + '*' + Trim(aCardapio.DESCRICAO) + '*  _______  ' + FormatFloat('R$ #,##0.00', aCardapio.PRECO) + ' \n';
      end;
      aMsg := aMsg + '\n';
  end;

  SendMessage(2, aMsg);
  Result := FCurrentChat;
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

