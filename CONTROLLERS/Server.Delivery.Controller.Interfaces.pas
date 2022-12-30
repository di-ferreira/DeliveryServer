unit Server.Delivery.Controller.Interfaces;

interface

uses
  Server.Delivery.DTO, Server.Delivery.Model.Produto,
  Server.Delivery.Model.Interfaces;

type
  iControllerServerDelivery = interface
    ['{61D5253A-403D-4480-8D1D-F61B5C17F98F}']
    function PRODUTO: iModelServerDelivery<TPRODUTO>;
    function CLIENTE: iModelServerDeliveryCliente<TCLIENTE>;
    function ENDERECO: iModelServerDeliveryEndereco<TENDERECO>;
  end;

implementation

end.

