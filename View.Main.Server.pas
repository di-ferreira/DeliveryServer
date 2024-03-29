unit View.Main.Server;

interface
{(*}
uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Horse,
  Horse.CORS,
  Horse.Exception,
  Horse.Compression,
  Horse.Jhonson,
  Horse.OctetStream,
  Vcl.StdCtrls,
  Vcl.Mask,
  Vcl.ExtCtrls,
  Vcl.AppEvnts,
  Vcl.Menus,
  uTInject.ConfigCEF,
  uTInject,
  uTInject.Constant,
  uTInject.JS,
  uInjectDecryptFile,
  uTInject.Console,
  uTInject.Diversos,
  uTInject.AdjustNumber,
  uTInject.Config, uTInject.Classes,
  Server.Delivery.Controller.Routes,
  Server.Delivery.Bot.Manager,
  Server.Delivery.Bot.Resposta.Chat,
  Server.Delivery.Bot.Chat,
  System.StrUtils;
{*)}

type
  TViewMainServer = class(TForm)
    BtnServer: TButton;
    BtnBot: TButton;
    EdtPorta: TLabeledEdit;
    TrayIcon: TTrayIcon;
    ApplicationEvents: TApplicationEvents;
    PopupMenu: TPopupMenu;
    PPServer: TMenuItem;
    PPBot: TMenuItem;
    EdtSimultaneos: TLabeledEdit;
    EdtTempoInatividade: TLabeledEdit;
    Bot: TInject;
    procedure BtnServerClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ApplicationEventsMinimize(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure PPServerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnBotClick(Sender: TObject);
    procedure BotGetUnReadMessages(const Chats: TChatList);
  private
    pManagerBot: TServerDeliveryBotManager;
    pRespostas: TServerDeliveryBotRespostaChat;
    pCurrentChat: TServerDeliveryBotChat;
    procedure CreateServer;
    procedure StartServer;
    procedure StopServer;
    procedure StatusServer;
    procedure StartBot;
    procedure ManagerInteraction(aChat: TServerDeliveryBotChat);
  public
    { Public declarations }
  end;

var
  ViewMainServer: TViewMainServer;

const
  CONVERTO_TO_MILISEGUNDOS = 60000;

implementation

{$R *.dfm}

{ TViewMainServer }

procedure TViewMainServer.ApplicationEventsMinimize(Sender: TObject);
begin
  Self.Hide();
  Self.WindowState := TWindowState.wsMinimized;
  TrayIcon.Visible := True;
  TrayIcon.Animate := True;
  TrayIcon.ShowBalloonHint;
end;

procedure TViewMainServer.BotGetUnReadMessages(const Chats: TChatList);
begin
  pManagerBot.AdministrarChatList(Bot, Chats);
end;

procedure TViewMainServer.BtnBotClick(Sender: TObject);
begin
  if Bot.IsConnected then
  begin
    BtnBot.Caption := 'DISCONNECT BOT';
    Bot.Disconnect;
    exit;
  end;
  BtnBot.Caption := 'CONNECT BOT';
  StartBot;
end;

procedure TViewMainServer.BtnServerClick(Sender: TObject);
begin
  StatusServer;
end;

procedure TViewMainServer.CreateServer;
begin
  THorse.Use(Cors).Use(Compression()).Use(Jhonson('UTF-8'));
end;

procedure TViewMainServer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if THorse.IsRunning then
  begin
    StopServer;
  end;
end;

procedure TViewMainServer.FormCreate(Sender: TObject);
begin
  StatusServer;
end;

procedure TViewMainServer.ManagerInteraction(aChat: TServerDeliveryBotChat);
var
  NumeroResposta: integer;
  ValueResposta: string;
begin
  pCurrentChat := aChat;
  pRespostas.CurrentChat := pCurrentChat;

  case aChat.Situacao of
    saIndefinido:
      ;
    saNova:
      begin
        pCurrentChat := pRespostas.WelcomeMessage(aChat);
      end;
    saNaFila:
      ;
    saEmAtendimento:
      begin
        case aChat.Etapa of
          // envia lista com card�pio por tipo
          1:
            case AnsiIndexStr(aChat.Resposta, ['1', '2']) of
              0:
                pCurrentChat := pRespostas.SendCardapio(aChat);
            else
              pCurrentChat := pRespostas.SendMensagemInvalida(aChat);
            end;
          // envia lista com itens do tipo card�pio
          2:
            begin
              ValueResposta := aChat.Resposta;

              if TryStrToInt(ValueResposta, NumeroResposta) and (NumeroResposta > 0) then
                pCurrentChat := pRespostas.SendItensCardapio(aChat, NumeroResposta)
              else if TryStrToInt(ValueResposta, NumeroResposta) and (NumeroResposta = 0) then
                pCurrentChat := pRespostas.SendCardapio(aChat)
              else
                pCurrentChat := pRespostas.SendMensagemInvalida(aChat);
            end;
        end;
      end;
    saAguardandoPedido:
      ;
    saFinalizada:
      ;
    saAtendente:
      ;
    saInativa:
      ;
  end;
end;

procedure TViewMainServer.PPServerClick(Sender: TObject);
begin
  StatusServer;
end;

procedure TViewMainServer.StartBot;
begin
  pManagerBot := TServerDeliveryBotManager.Create(Self);
  pManagerBot.OnInteracao := ManagerInteraction;
  pManagerBot.Simultaneos := StrToInt(EdtSimultaneos.EditText);
  pManagerBot.TempoInatividade := (StrToInt(EdtTempoInatividade.EditText) * CONVERTO_TO_MILISEGUNDOS);

  pRespostas := TServerDeliveryBotRespostaChat.Create;
  pRespostas.Bot := Bot;

  if not Bot.Auth(False) then
  begin
    Bot.FormQrCodeType := TFormQrCodeType(ft_http);
    Bot.FormQrCodeStart;
  end;

  if not Bot.FormQrCodeShowing then
    Bot.FormQrCodeShowing := True;
end;

procedure TViewMainServer.StartServer;
begin
  Server.Delivery.Controller.Routes.Registry;

  THorse.Listen(StrToInt(EdtPorta.Text));

  BtnServer.Caption := 'SERVER RUNNING';
  PPServer.Caption := 'SERVER RUNNING';
  EdtPorta.Enabled := False;
end;

procedure TViewMainServer.StatusServer;
begin
  if THorse.IsRunning then
    StopServer
  else
    StartServer;
end;

procedure TViewMainServer.StopServer;
begin
  THorse.StopListen;
  BtnServer.Caption := 'SERVER STOPED';
  PPServer.Caption := 'SERVER STOPED';
  EdtPorta.Enabled := True;
end;

procedure TViewMainServer.TrayIconDblClick(Sender: TObject);
begin
  TrayIcon.Visible := False;
  Show();
  WindowState := TWindowState.wsNormal;
  Application.BringToFront();
end;

end.

