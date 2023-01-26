unit Server.Delivery.Controller.Interfaces;

interface

uses
  Server.Delivery.DTO, Server.Delivery.Model.Interfaces;

type
  iControllerServerDelivery = interface
    ['{61D5253A-403D-4480-8D1D-F61B5C17F98F}']
    function PRODUTO: iModelServerDelivery<TPRODUTO>;
    function CLIENTE: iModelServerDeliveryCliente<TCLIENTE>;
    function ENDERECO: iModelServerDeliveryEndereco<TENDERECO>;
    function TIPO_CARDAPIO: iModelServerDelivery<TTIPO_CARDAPIO>;
    function TIPO_PGTO: iModelServerDelivery<TTIPOPGTO>;
    function CARDAPIO: iModelServerDeliveryCardapio<TCARDAPIO>;
    function CAIXA: iModelServerDeliveryCaixa<TCAIXA>;
//    function PEDIDO: iModelServerDelivery<TPEDIDO>;
//    function ITEM_PEDIDO: iModelServerDelivery<TITEM_PEDIDO>;
  end;

implementation

end.

