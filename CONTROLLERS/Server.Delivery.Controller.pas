unit Server.Delivery.Controller;

interface

uses
  Server.Delivery.DTO, Server.Delivery.Controller.Interfaces,
  Server.Delivery.Model.Interfaces, Server.Delivery.Model.Produto,
  Server.Delivery.Model.Cliente, Server.Delivery.Model.Endereco;

type
  TControllerServerDelivery = class(TInterfacedObject, iControllerServerDelivery)
  private
    FPRODUTO: iModelServerDelivery<TPRODUTO>;
    FCLIENTE: iModelServerDeliveryCliente<TCLIENTE>;
    FENDERECO:  iModelServerDeliveryEndereco<TENDERECO>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iControllerServerDelivery;
    function PRODUTO: iModelServerDelivery<TPRODUTO>;
    function CLIENTE: iModelServerDeliveryCliente<TCLIENTE>;
    function ENDERECO: iModelServerDeliveryEndereco<TENDERECO>;
  end;

implementation

{ TControllerSistemaVenda }

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

class function TControllerServerDelivery.New: iControllerServerDelivery;
begin
  Result := Self.Create;
end;

function TControllerServerDelivery.PRODUTO: iModelServerDelivery<TPRODUTO>;
begin
  if not Assigned(FPRODUTO) then
    FPRODUTO := TModelServerDeliveryProduto.New;

  Result := FPRODUTO;
end;

end.

