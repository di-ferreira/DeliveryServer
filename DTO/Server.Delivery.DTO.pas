unit Server.Delivery.DTO;

interface

uses
  System.Generics.Collections, System.SysUtils;

{ (* }
// - [ ]  Cliente
// - [ ]  Endereços Cliente(Clientes podem ter mais de um endereço)
//-----------------------------------------------------------------------------
// - [ ]  Tipo Cardápio(Massas, bebidas, etc…)
// - [ ]  Produto
// - [ ]  Cardápio(o produto ou combo de produtos)
//-----------------------------------------------------------------------------
// - [ ]  Pedido
// - [ ]  Pedido Item
{ *) }

type
  TTIPOPGTO = class;

  TCLIENTE = class;

  TENDERECO = class;

  TTIPO_CARDAPIO = class;

  TPRODUTO = class;

  TCARDAPIO = class;

  TPEDIDO = class;

  TITEM_PEDIDO = class;

  TCAIXA = class;

  TCLIENTE = class
  private
    FCONTATO: string;
    FID: Integer;
    FNOME: string;
    procedure SetCONTATO(const Value: string);
    procedure SetID(const Value: Integer);
    procedure SetNOME(const Value: string);
  public
    property ID: Integer read FID write SetID;
    property NOME: string read FNOME write SetNOME;
    property CONTATO: string read FCONTATO write SetCONTATO;
  end;

  TENDERECO = class
  private
    FBAIRRO: string;
    FCLIENTE: TCLIENTE;
    FID: Integer;
    FNUMERO: string;
    FCOMPLEMENTO: string;
    FCIDADE: string;
    FESTADO: string;
    FRUA: string;
    procedure SetBAIRRO(const Value: string);
    procedure SetCIDADE(const Value: string);
    procedure SetCLIENTE(const Value: TCLIENTE);
    procedure SetCOMPLEMENTO(const Value: string);
    procedure SetESTADO(const Value: string);
    procedure SetID(const Value: Integer);
    procedure SetNUMERO(const Value: string);
    procedure SetRUA(const Value: string);
  public
    property ID: Integer read FID write SetID;
    property RUA: string read FRUA write SetRUA;
    property NUMERO: string read FNUMERO write SetNUMERO;
    property BAIRRO: string read FBAIRRO write SetBAIRRO;
    property CIDADE: string read FCIDADE write SetCIDADE;
    property ESTADO: string read FESTADO write SetESTADO;
    property COMPLEMENTO: string read FCOMPLEMENTO write SetCOMPLEMENTO;
    property CLIENTE: TCLIENTE read FCLIENTE write SetCLIENTE;
  end;

  TTIPOPGTO = class
  private
    FID: Integer;
    FDESCRICAO: string;
    FVALOR_PAGO: Double;
    procedure SetID(const Value: Integer);
    procedure SetDESCRICAO(const Value: string);
    procedure SetVALOR_PAGO(const Value: Double);
  public
    property ID: Integer read FID write SetID;
    property DESCRICAO: string read FDESCRICAO write SetDESCRICAO;
    property VALOR_PAGO: Double read FVALOR_PAGO write SetVALOR_PAGO;
  end;

  TTIPO_CARDAPIO = class
  private
    FDESCRICAO: string;
    FID: Integer;
    procedure SetDESCRICAO(const Value: string);
    procedure SetID(const Value: Integer);
  public
    property ID: Integer read FID write SetID;
    property DESCRICAO: string read FDESCRICAO write SetDESCRICAO;
  end;

  TPRODUTO = class
  private
    FESTOQUE: Integer;
    FID: Integer;
    FLUCRO: Double;
    FNOME: string;
    FCUSTO: Double;
    procedure SetCUSTO(const Value: Double);
    procedure SetESTOQUE(const Value: Integer);
    procedure SetID(const Value: Integer);
    procedure SetNOME(const Value: string);
    procedure SetLUCRO(const Value: Double);
  public
    property ID: Integer read FID write SetID;
    property NOME: string read FNOME write SetNOME;
    property ESTOQUE: Integer read FESTOQUE write SetESTOQUE;
    property CUSTO: Double read FCUSTO write SetCUSTO;
    property LUCRO: Double read FLUCRO write SetLUCRO;
  end;

  TCARDAPIO = class
  private
    FPRECO: Currency;
    FDESCRICAO: string;
    FID: Integer;
    FPRODUTO: TObjectList<TPRODUTO>;
    FTIPO_CARDAPIO: TTIPO_CARDAPIO;
    procedure SetDESCRICAO(const Value: string);
    procedure SetID(const Value: Integer);
    procedure SetPRODUTO(const Value: TObjectList<TPRODUTO>);
    procedure SetTIPO_CARDAPIO(const Value: TTIPO_CARDAPIO);
  public
    property ID: Integer read FID write SetID;
    property DESCRICAO: string read FDESCRICAO write SetDESCRICAO;
    property PRECO: Currency read FPRECO;
    property PRODUTO: TObjectList<TPRODUTO> read FPRODUTO write SetPRODUTO;
    property TIPO_CARDAPIO: TTIPO_CARDAPIO read FTIPO_CARDAPIO write SetTIPO_CARDAPIO;
  end;

  TPEDIDO = class
  private
    FCLIENTE: TCLIENTE;
    FTOTAL: Double;
    FID: Integer;
    FENDERECO_ENTREGA: TENDERECO;
    FDATA: TDateTime;
    FTIPO_PAGAMENTO: TObjectList<TTIPOPGTO>;
    FCAIXA: TCAIXA;
    FOBS: string;
    FCANCELADO: Boolean;
    FABERTO: Boolean;
    FITEMS: TObjectList<TITEM_PEDIDO>;
    procedure SetCLIENTE(const Value: TCLIENTE);
    procedure SetENDERECO_ENTREGA(const Value: TENDERECO);
    procedure SetID(const Value: Integer);
    procedure SetTIPO_PAGAMENTO(const Value: TObjectList<TTIPOPGTO>);
    procedure SetCAIXA(const Value: TCAIXA);
    procedure SetABERTO(const Value: Boolean);
    procedure SetCANCELADO(const Value: Boolean);
    procedure SetOBS(const Value: string);
    procedure SetITEMS(const Value: TObjectList<TITEM_PEDIDO>);
  public
    property ID: Integer read FID write SetID;
    property DATA: TDateTime read FDATA;
    property CLIENTE: TCLIENTE read FCLIENTE write SetCLIENTE;
    property TOTAL: Double read FTOTAL;
    property ABERTO: Boolean read FABERTO write SetABERTO;
    property CANCELADO: Boolean read FCANCELADO write SetCANCELADO;
    property OBS: string read FOBS write SetOBS;
    property TIPO_PAGAMENTO: TObjectList<TTIPOPGTO> read FTIPO_PAGAMENTO write SetTIPO_PAGAMENTO;
    property CAIXA: TCAIXA read FCAIXA write SetCAIXA;
    property ENDERECO_ENTREGA: TENDERECO read FENDERECO_ENTREGA write SetENDERECO_ENTREGA;
    property ITEMS: TObjectList<TITEM_PEDIDO> read FITEMS write SetITEMS;
  end;

  TITEM_PEDIDO = class
  private
    FITEM_CARDAPIO: TCARDAPIO;
    FPEDIDO: TPEDIDO;
    FTOTAL: Currency;
    FID: Integer;
    FQUANTIDADE: Integer;
    procedure SetID(const Value: Integer);
    procedure SetITEM_CARDAPIO(const Value: TCARDAPIO);
    procedure SetPEDIDO(const Value: TPEDIDO);
    procedure SetQUANTIDADE(const Value: Integer);
  public
    property ID: Integer read FID write SetID;
    property PEDIDO: TPEDIDO read FPEDIDO write SetPEDIDO;
    property ITEM_CARDAPIO: TCARDAPIO read FITEM_CARDAPIO write SetITEM_CARDAPIO;
    property QUANTIDADE: Integer read FQUANTIDADE write SetQUANTIDADE;
    property TOTAL: Currency read FTOTAL;
  end;

  TCAIXA = class
  private
    FTOTAL: Currency;
    FABERTO: Boolean;
    FDATA: TDate;
    FID: Integer;
    FPEDIDOS: TObjectList<TPEDIDO>;
    procedure SetABERTO(const Value: Boolean);
    procedure SetID(const Value: Integer);
    procedure SetPEDIDOS(const Value: TObjectList<TPEDIDO>);
  public
    property ID: Integer read FID write SetID;
    property DATA_ABERTURA: TDate read FDATA;
    property ABERTO: Boolean read FABERTO write SetABERTO;
    property TOTAL: Currency read FTOTAL;
    property PEDIDOS: TObjectList<TPEDIDO> read FPEDIDOS write SetPEDIDOS;
  end;

implementation

{ TCLIENTE }

procedure TCLIENTE.SetCONTATO(const Value: string);
begin
  FCONTATO := Value;
end;

procedure TCLIENTE.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TCLIENTE.SetNOME(const Value: string);
begin
  FNOME := Value;
end;

{ TENDERECO }

procedure TENDERECO.SetBAIRRO(const Value: string);
begin
  FBAIRRO := Value;
end;

procedure TENDERECO.SetCIDADE(const Value: string);
begin
  FCIDADE := Value;
end;

procedure TENDERECO.SetCLIENTE(const Value: TCLIENTE);
begin
  FCLIENTE := Value;
end;

procedure TENDERECO.SetCOMPLEMENTO(const Value: string);
begin
  FCOMPLEMENTO := Value;
end;

procedure TENDERECO.SetESTADO(const Value: string);
begin
  FESTADO := Value;
end;

procedure TENDERECO.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TENDERECO.SetNUMERO(const Value: string);
begin
  FNUMERO := Value;
end;

procedure TENDERECO.SetRUA(const Value: string);
begin
  FRUA := Value;
end;

{ TTIPO_CARDAPIO }

procedure TTIPO_CARDAPIO.SetDESCRICAO(const Value: string);
begin
  FDESCRICAO := Value;
end;

procedure TTIPO_CARDAPIO.SetID(const Value: Integer);
begin
  FID := Value;
end;

{ TPRODUTO }

procedure TPRODUTO.SetCUSTO(const Value: Double);
begin
  FCUSTO := Value;
end;

procedure TPRODUTO.SetESTOQUE(const Value: Integer);
begin
  FESTOQUE := Value;
end;

procedure TPRODUTO.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TPRODUTO.SetNOME(const Value: string);
begin
  FNOME := Value;
end;

procedure TPRODUTO.SetLUCRO(const Value: Double);
begin
  FLUCRO := Value;
end;

{ TCARDAPIO }

procedure TCARDAPIO.SetDESCRICAO(const Value: string);
begin
  FDESCRICAO := Value;
end;

procedure TCARDAPIO.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TCARDAPIO.SetPRODUTO(const Value: TObjectList<TPRODUTO>);
var
  lPRODUTO: TPRODUTO;
  lPRECO: Double;
begin
  FPRODUTO := Value;
  lPRECO := 0.00;
  for lPRODUTO in FPRODUTO do
  begin
    lPRECO := lPRECO + (lPRODUTO.CUSTO * lPRODUTO.FLUCRO) / 100 + lPRODUTO.CUSTO;
  end;

  FPRECO := lPRECO;
end;

procedure TCARDAPIO.SetTIPO_CARDAPIO(const Value: TTIPO_CARDAPIO);
begin
  FTIPO_CARDAPIO := Value;
end;

{ TPEDIDO }

procedure TPEDIDO.SetABERTO(const Value: Boolean);
begin
  FABERTO := Value;
end;

procedure TPEDIDO.SetCAIXA(const Value: TCAIXA);
begin
  FCAIXA := Value;
end;

procedure TPEDIDO.SetCANCELADO(const Value: Boolean);
begin
  FCANCELADO := Value;
  FABERTO := TRUE;
  if FCANCELADO then
    FABERTO := FALSE;
end;

procedure TPEDIDO.SetCLIENTE(const Value: TCLIENTE);
begin
  FCLIENTE := Value;
  FDATA := Date();
end;

procedure TPEDIDO.SetENDERECO_ENTREGA(const Value: TENDERECO);
begin
  FENDERECO_ENTREGA := Value;
end;

procedure TPEDIDO.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TPEDIDO.SetITEMS(const Value: TObjectList<TITEM_PEDIDO>);
var
  lITEM: TITEM_PEDIDO;
  lTOTAL: Double;
begin
  FITEMS := Value;
  lTOTAL := 0.00;

  for lITEM in FITEMS do
  begin
    lTOTAL := lTOTAL + lITEM.FTOTAL;
  end;

  FTOTAL := lTOTAL;
end;

procedure TPEDIDO.SetOBS(const Value: string);
begin
  FOBS := Value;
end;

procedure TPEDIDO.SetTIPO_PAGAMENTO(const Value: TObjectList<TTIPOPGTO>);
begin
  FTIPO_PAGAMENTO := Value;
end;

{ TITEM_PEDIDO }

procedure TITEM_PEDIDO.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TITEM_PEDIDO.SetITEM_CARDAPIO(const Value: TCARDAPIO);
begin
  FITEM_CARDAPIO := Value;
  FTOTAL := FloatToCurr(FITEM_CARDAPIO.PRECO * FQUANTIDADE);
end;

procedure TITEM_PEDIDO.SetPEDIDO(const Value: TPEDIDO);
begin
  FPEDIDO := Value;
end;

procedure TITEM_PEDIDO.SetQUANTIDADE(const Value: Integer);
begin
  FQUANTIDADE := Value;
  FTOTAL := FloatToCurr(FITEM_CARDAPIO.PRECO * FQUANTIDADE);
end;

{ TTIPOPGTO }

procedure TTIPOPGTO.SetDESCRICAO(const Value: string);
begin
  FDESCRICAO := Value;
end;

procedure TTIPOPGTO.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TTIPOPGTO.SetVALOR_PAGO(const Value: Double);
begin
  FVALOR_PAGO := Value;
end;

{ TCAIXA }

procedure TCAIXA.SetABERTO(const Value: Boolean);
begin
  FABERTO := Value;
  FDATA := Date();
end;

procedure TCAIXA.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TCAIXA.SetPEDIDOS(const Value: TObjectList<TPEDIDO>);
var
  lPEDIDO: TPEDIDO;
  lTOTAL: Double;
begin
  FPEDIDOS := Value;
  lTOTAL := 0.00;

  for lPEDIDO in FPEDIDOS do
  begin
    lTOTAL := lTOTAL + lPEDIDO.FTOTAL;
  end;

  FTOTAL := lTOTAL;
end;

end.

