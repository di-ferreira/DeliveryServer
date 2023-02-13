unit Server.Delivery.Bot.Chat;

interface

uses
  System.Classes,
  Vcl.ExtCtrls,
  uTInject,
  Server.Delivery.DTO,
  System.Generics.Collections;

type
{(*}
  TSituacaoChat = (saIndefinido,
                   saNova,
                   saNaFila,
                   saEmAtendimento,
                   saAguardandoPedido,
                   saFinalizada,
                   saAtendente,
                   saInativa);

  TServerDeliveryBotChat = class;

  TNotifyConversa = procedure(Conversa: TServerDeliveryBotChat) of object;

  {*)}
  TServerDeliveryBotChat = class(TComponent)
  private
    FID: string;
    FIDMensagem: Extended;
    FPergunta:string;
    FResposta:string;
    FSituacao: TSituacaoChat;
    FTimerSleep: TTimer;
    FTempoInatividade: Integer;
    FEtapa: Integer;
    FOnSituacaoAlterada: TNotifyConversa;
    FOnRespostaRecebida: TNotifyConversa;
    FCLIENTE: TCLIENTE;
    FTIPO_PAGAMENTO: TObjectList<TTIPOPGTO>;
    FITEMS: TObjectList<TITEM_PEDIDO>;
    FENDERECO: TENDERECO;
    FOBS: string;
    FType: string;
    procedure TimerSleepExecute(Sender: TObject);
    procedure SetSituacao(const Value: TSituacaoChat);
    procedure SetTempoInatividade(const Value: Integer);
    procedure SetCLIENTE(const Value: TCLIENTE);
    procedure SetENDERECO(const Value: TENDERECO);
    procedure SetITEMS(const Value: TObjectList<TITEM_PEDIDO>);
    procedure SetTIPO_PAGAMENTO(const Value: TObjectList<TTIPOPGTO>);
    procedure SetOBS(const Value: string);
  public
    //Construtores destrutores
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property CLIENTE:TCLIENTE read FCLIENTE write SetCLIENTE;
    property ENDERECO:TENDERECO read FENDERECO write SetENDERECO;
    property TIPO_PAGAMENTO:TObjectList<TTIPOPGTO> read FTIPO_PAGAMENTO write SetTIPO_PAGAMENTO;
    property ITEMS: TObjectList<TITEM_PEDIDO> read FITEMS write SetITEMS;
    property OBS: string read FOBS write SetOBS;

    property Situacao: TSituacaoChat read FSituacao write SetSituacao default saIndefinido;
    property ID: string read FID write FID;
    property IDMensagem: Extended read FIDMensagem write FIDMensagem;
    property &type: string read FType write FType;
    property Etapa: Integer read FEtapa write FEtapa default 0;
    property Pergunta: string read FPergunta write FPergunta;
    property Resposta: string read FResposta write FResposta;
    property TempoInatividade: Integer read FTempoInatividade write SetTempoInatividade;
    property OnSituacaoAlterada: TNotifyConversa read FOnSituacaoAlterada write FOnSituacaoAlterada;
    property OnRespostaRecebida: TNotifyConversa read FOnRespostaRecebida write FOnRespostaRecebida;
    procedure ReiniciarTimer;
  end;

implementation

uses
  System.SysUtils;

{ TServerDeliveryBotChat }

constructor TServerDeliveryBotChat.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  //Prepara Timer
  FTimerSleep := TTimer.Create(Self);
  with FTimerSleep do
  begin
    Enabled := False;
    Interval := TempoInatividade;
    OnTimer := TimerSleepExecute;
  end;
  FCLIENTE := TCLIENTE.Create;
  FTIPO_PAGAMENTO := TObjectList<TTIPOPGTO>.Create;
  FITEMS := TObjectList<TITEM_PEDIDO>.Create;
  FENDERECO := TENDERECO.Create;
end;

destructor TServerDeliveryBotChat.Destroy;
begin
  FTimerSleep.Free;
  FCLIENTE.Free;
  FTIPO_PAGAMENTO.Free;
  FITEMS.Free;
  FENDERECO.Free;
  inherited Destroy;
end;

procedure TServerDeliveryBotChat.SetCLIENTE(const Value: TCLIENTE);
begin
  FCLIENTE := Value;
end;

procedure TServerDeliveryBotChat.SetENDERECO(const Value: TENDERECO);
begin
  FENDERECO := Value;
end;

procedure TServerDeliveryBotChat.SetITEMS(const Value: TObjectList<TITEM_PEDIDO>);
begin
  FITEMS := Value;
end;

procedure TServerDeliveryBotChat.SetOBS(const Value: string);
begin
  FOBS := Value;
end;

procedure TServerDeliveryBotChat.SetSituacao(const Value: TSituacaoChat);
begin
  //DoChange
  if FSituacao <> Value then
  begin
    FSituacao := Value;

    //Habilita Time se situacao ativa.
    if FSituacao <> saAtendente then
    begin
      FTimerSleep.Enabled := FSituacao = saEmAtendimento;

      if Assigned(OnSituacaoAlterada) then
        OnSituacaoAlterada(Self);
    end;
  end;
end;

procedure TServerDeliveryBotChat.SetTempoInatividade(const Value: Integer);
begin
  FTempoInatividade := Value;
  FTimerSleep.Interval := FTempoInatividade;
end;

procedure TServerDeliveryBotChat.SetTIPO_PAGAMENTO(const Value: TObjectList<TTIPOPGTO>);
begin
  FTIPO_PAGAMENTO := Value;
end;

procedure TServerDeliveryBotChat.TimerSleepExecute(Sender: TObject);
begin
  Self.Situacao := saInativa;
end;

procedure TServerDeliveryBotChat.ReiniciarTimer;
begin
    //Se estiver em atendimento reinicia o timer de inatividade
  if Situacao in [saNova, saEmAtendimento, saAtendente] then
  begin
    FTimerSleep.Enabled := False;
    FTimerSleep.Enabled := True;
  end;
end;

end.

