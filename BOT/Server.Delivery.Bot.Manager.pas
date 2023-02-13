unit Server.Delivery.Bot.Manager;

interface

uses
{(*}
  System.Classes,
  Vcl.ExtCtrls,
  System.Generics.Collections,
  Server.Delivery.Bot.Chat,
  uTInject,
  uTInject.classes;
{*)}

type
  TServerDeliveryBotManager = class(TComponent)
  private
    FSenhaADM: string;
    FSimultaneos: Integer;
    FTempoInatividade: Integer;
    FConversas: TObjectList<TServerDeliveryBotChat>;

    FOnInteracao: TNotifyConversa;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AdministrarChatList(AInject: TInject; AChats: TChatList);
    procedure ProcessarResposta(AMessagem: TMessagesClass);

    function BuscarConversa(AID: string): TServerDeliveryBotChat;
    function NovaConversa(AMessage: TMessagesClass): TServerDeliveryBotChat;
    function BuscarConversaEmEspera: TServerDeliveryBotChat;
    function AtenderProximoEmEspera: TServerDeliveryBotChat;

    property SenhaADM: string read FSenhaADM write FSenhaADM;
    property Simultaneos: Integer read FSimultaneos write FSimultaneos default 1;
    property Conversas: TObjectList<TServerDeliveryBotChat> read FConversas;
    property TempoInatividade: Integer read FTempoInatividade write FTempoInatividade;

    //Procedures notificadoras
    procedure ProcessarInteracao(Conversa: TServerDeliveryBotChat);
    procedure ConversaSituacaoAlterada(Conversa: TServerDeliveryBotChat);

    //Notify
    property OnInteracao: TNotifyConversa read FOnInteracao write FOnInteracao;
  end;

implementation

uses
  System.StrUtils, System.SysUtils;

{ TServerDeliveryBotManager }

constructor TServerDeliveryBotManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FConversas := TObjectList<TServerDeliveryBotChat>.Create;
end;

destructor TServerDeliveryBotManager.Destroy;
begin
  FreeAndNil(FConversas);
  inherited Destroy;
end;

procedure TServerDeliveryBotManager.AdministrarChatList(AInject: TInject; AChats: TChatList);
var
  AChat: TChatClass;
  AMessage: TMessagesClass;
begin
  //Loop em todos os chats
  for AChat in AChats.result do
  begin
    //Não considerar chats de grupos
    if not AChat.isGroup then
    begin
      //Define que a mensagem ja foi lida,
      //para evitar recarrega-la novamente.
      AInject.ReadMessages(AChat.id);

      //Pode haver mais de uma mensagem, pego a ultima
      AMessage := AChat.messages[Low(AChat.messages)];

      //Não considerar mensagens enviadas por mim
      if not AMessage.sender.isMe then
      begin
        //Carregar Conversa e passar a mensagem
        ProcessarResposta(AMessage);
      end;
    end;
  end;
end;

procedure TServerDeliveryBotManager.ProcessarResposta(AMessagem: TMessagesClass);
var
  AConversa: TServerDeliveryBotChat;
begin
  AConversa := BuscarConversa(AMessagem.sender.id);
  if not Assigned(AConversa) then
    AConversa := NovaConversa(AMessagem);

  //Tratando a situacao em que vem a mesma mensagem.
  if AConversa.IDMensagem <> AMessagem.T then
  begin
    AConversa.IDMensagem := AMessagem.t;
    AConversa.Resposta := AMessagem.body;
    AConversa.&type := AMessagem.&type;

    //Houve interacao, reinicia o timer de inatividade da conversa;
    AConversa.ReiniciarTimer;

    //Notifica mensagem recebida
    ProcessarInteracao(AConversa);
  end;
end;

function TServerDeliveryBotManager.BuscarConversa(AID: string): TServerDeliveryBotChat;
var
  AConversa: TServerDeliveryBotChat;
begin
  Result := nil;
  for AConversa in FConversas do
  begin
    if AConversa.ID = AID then
    begin
      Result := AConversa;
      Break;
    end;
  end;
end;

function TServerDeliveryBotManager.NovaConversa(AMessage: TMessagesClass): TServerDeliveryBotChat;
var
  ADisponivel: Boolean;
begin
  ADisponivel := (Conversas.Count < Simultaneos);

  Result := TServerDeliveryBotChat.Create(Self);
  with Result do
  begin

    TempoInatividade := Self.TempoInatividade;
    ID := AMessage.Sender.id;
    CLIENTE.CONTATO := Copy(AMessage.sender.id, 1, Pos('@', AMessage.sender.id) - 1);

    //Capturar nome publico, ou formatado (numero/nome).
    CLIENTE.NOME := IfThen(AMessage.sender.PushName <> EmptyStr, AMessage.sender.PushName, AMessage.sender.FormattedName);

    //Eventos para controle externos
    OnSituacaoAlterada := ConversaSituacaoAlterada;
    OnRespostaRecebida := ProcessarInteracao;
  end;
  FConversas.Add(Result);

  //Validando a disponibilidade ou tipo adm
  if (ADisponivel) then
    Result.Situacao := saNova
  else
    Result.Situacao := saNaFila;
end;

function TServerDeliveryBotManager.BuscarConversaEmEspera: TServerDeliveryBotChat;
var
  AConversa: TServerDeliveryBotChat;
begin
  Result := nil;
  for AConversa in FConversas do
  begin
    if AConversa.Situacao = saNaFila then
    begin
      Result := AConversa;
      Break;
    end;
  end;
end;

function TServerDeliveryBotManager.AtenderProximoEmEspera: TServerDeliveryBotChat;
var
  AConversa: TServerDeliveryBotChat;
begin
  Result := BuscarConversaEmEspera;

  if Assigned(Result) then
  begin
    Result.Situacao := saNova;
    Result.ReiniciarTimer;

    ProcessarInteracao(Result);
  end;
end;

procedure TServerDeliveryBotManager.ProcessarInteracao(Conversa: TServerDeliveryBotChat);
begin
  if Assigned(OnInteracao) then
    OnInteracao(Conversa);
end;

procedure TServerDeliveryBotManager.ConversaSituacaoAlterada(Conversa: TServerDeliveryBotChat);
begin
  //Se ficou inativo
  if Conversa.Situacao in [saInativa, saFinalizada] then
  begin
    //Encaminha
    OnInteracao(Conversa);

    //Destroy
    Conversas.Remove(Conversa);

    //Atende proximo da fila
    AtenderProximoEmEspera;
  end;
end;

end.

