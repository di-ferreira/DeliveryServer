unit Server.Delivery.Controller;

interface

uses
{(*}
  Server.Delivery.DTO,
  Server.Delivery.Controller.Interfaces,
  Server.Delivery.Model.Interfaces,
  Server.Delivery.Model.Produto,
  Server.Delivery.Model.Cliente,
  Server.Delivery.Model.Endereco,
  Server.Delivery.Model.TipoCardapio,
  Server.Delivery.Model.TipoPgto,
  Server.Delivery.Model.Cardapio,
  Server.Delivery.Model.Caixa,
  Server.Delivery.Model.Pedido,
  Server.Delivery.Model.ItemPedido;
  {*)}

type
  TControllerServerDelivery = class(TInterfacedObject, iControllerServerDelivery)
  private
    FPRODUTO: iModelServerDelivery<TPRODUTO>;
    FTPCARDAPIO: iModelServerDelivery<TTIPO_CARDAPIO>;
    FTPPGTO: iModelServerDelivery<TTIPOPGTO>;
    FCLIENTE: iModelServerDeliveryCliente<TCLIENTE>;
    FENDERECO: iModelServerDeliveryEndereco<TENDERECO>;
    FCARDAPIO: iModelServerDeliveryCardapio<TCARDAPIO>;
    FCAIXA: iModelServerDeliveryCaixa<TCAIXA>;
    FPEDIDO: iModelServerDeliveryPedido<TPEDIDO>;
    FITEM_PEDIDO: iModelServerDeliveryItemPedido<TITEM_PEDIDO>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iControllerServerDelivery;
    function PRODUTO: iModelServerDelivery<TPRODUTO>;
    function TIPO_CARDAPIO: iModelServerDelivery<TTIPO_CARDAPIO>;
    function TIPO_PGTO: iModelServerDelivery<TTIPOPGTO>;
    function CLIENTE: iModelServerDeliveryCliente<TCLIENTE>;
    function ENDERECO: iModelServerDeliveryEndereco<TENDERECO>;
    function CARDAPIO: iModelServerDeliveryCardapio<TCARDAPIO>;
    function CAIXA: iModelServerDeliveryCaixa<TCAIXA>;
    function PEDIDO: iModelServerDeliveryPedido<TPEDIDO>;
    function ITEM_PEDIDO: iModelServerDeliveryItemPedido<TITEM_PEDIDO>;
  end;

implementation

{ TControllerSistemaVenda }

function TControllerServerDelivery.CAIXA: iModelServerDeliveryCaixa<TCAIXA>;
begin
  if not Assigned(FCAIXA) then
    FCAIXA := TModelServerDeliveryCaixa.New;

  Result := FCAIXA;
end;

function TControllerServerDelivery.CARDAPIO: iModelServerDeliveryCardapio<TCARDAPIO>;
begin
  if not Assigned(FCARDAPIO) then
    FCARDAPIO := TModelServerDeliveryCardapio.New;

  Result := FCARDAPIO;
end;

function TControllerServerDelivery.CLIENTE: iModelServerDeliveryCliente<TCLIENTE>;
begin
  if not Assigned(FCLIENTE) then
    FCLIENTE := TModelServerDeliveryCliente.New;

  Result := FCLIENTE;
end;

constructor TControllerServerDelivery.Create;
begin

end;

destructor TControllerServerDelivery.Destroy;
begin

  inherited;
end;

function TControllerServerDelivery.ENDERECO: iModelServerDeliveryEndereco<TENDERECO>;
begin
  if not Assigned(FENDERECO) then
    FENDERECO := TModelServerDeliveryEndereco.New;

  Result := FENDERECO;
end;

function TControllerServerDelivery.ITEM_PEDIDO: iModelServerDeliveryItemPedido<TITEM_PEDIDO>;
begin
  if not Assigned(FITEM_PEDIDO) then
    FITEM_PEDIDO := TModelServerDeliveryItemPedido.New;

  Result := FITEM_PEDIDO;
end;

class function TControllerServerDelivery.New: iControllerServerDelivery;
begin
  Result := Self.Create;
end;

function TControllerServerDelivery.PEDIDO: iModelServerDeliveryPedido<TPEDIDO>;
begin
  if not Assigned(FPEDIDO) then
    FPEDIDO := TModelServerDeliveryPedido.New;

  Result := FPEDIDO;
end;

function TControllerServerDelivery.PRODUTO: iModelServerDelivery<TPRODUTO>;
begin
  if not Assigned(FPRODUTO) then
    FPRODUTO := TModelServerDeliveryProduto.New;

  Result := FPRODUTO;
end;

function TControllerServerDelivery.TIPO_CARDAPIO: iModelServerDelivery<TTIPO_CARDAPIO>;
begin
  if not Assigned(FTPCARDAPIO) then
    FTPCARDAPIO := TModelServerDeliveryTipoCardapio.New;

  Result := FTPCARDAPIO;
end;

function TControllerServerDelivery.TIPO_PGTO: iModelServerDelivery<TTIPOPGTO>;
begin
  if not Assigned(FTPPGTO) then
    FTPPGTO := TModelServerDeliveryTipoPgto.New;

  Result := FTPPGTO;
end;

end.

