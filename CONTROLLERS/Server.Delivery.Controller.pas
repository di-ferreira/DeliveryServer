unit Server.Delivery.Controller;

interface

uses
  Server.Delivery.DTO, Server.Delivery.Controller.Interfaces,
  Server.Delivery.Model.Interfaces, Server.Delivery.Model.Produto,
  Server.Delivery.Model.Cliente;

type
  TControllerServerDelivery = class(TInterfacedObject, iControllerServerDelivery)
  private
    FPRODUTO: iModelServerDelivery<TPRODUTO>;
    FCLIENTE: iModelServerDeliveryCliente<TCLIENTE>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iControllerServerDelivery;
    function PRODUTO: iModelServerDelivery<TPRODUTO>;
    function CLIENTE: iModelServerDeliveryCliente<TCLIENTE>;
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

class function TControllerServerDelivery.New: iControllerServerDelivery;
begin
  Result := Self.Create;
end;

function TControllerServerDelivery.PRODUTO: iModelServerDelivery<TPRODUTO>;
begin
  if not Assigned(FPRODUTO) then
    FPRODUTO := TModelSistemaVendaProduto.New;

  Result := FPRODUTO;
end;

end.

