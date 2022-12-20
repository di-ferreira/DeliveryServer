unit Controllers.Server.Delivery.Cliente.Test;

interface

uses
  DUnitX.TestFramework, System.Net.HttpClient, WebMock,
  Server.Delivery.Controller, Server.Delivery.Controller.Interfaces;

type
  [TestFixture]
  TServerDeliveryClienteTest = class
  private
    Client: THTTPClient;
    Path: string;
    FController: iControllerServerDelivery;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    [TestCase('A', 'Diego,22981815566,Salvo com sucesso!')]
    [TestCase('B', ',22981817788,Salvo com sucesso!')]
    procedure TestSalvar(const aNome, aContato, Result: string);

    [Test]
    [TestCase('Created', 'Diego,22981815566,201')]
    [TestCase('Fail', ',22981817788,400')]
    procedure SaveClient(const aNome, aContato: string; const aStatus: Integer);

    [Test]
    [TestCase('OK', '200')]
    [TestCase('No Content', '204')]
    procedure GetClientsReturns(aStatus: Integer);

    [Test]
    procedure TestGetCliente;

    [Test]
    [TestCase('A', '1,"ID":1')]
    [TestCase('B', '2,"ID":2')]
    procedure TestGetClienteByID(const aValue, Result: string);

    [Test]
    [TestCase('A', '22981815566,22981815566')]
    [TestCase('B', '22981817788,22981817788')]
    procedure TestGetClienteByContato(const aValue, Result: string);

    [Test]
    [TestCase('A', '1,Diego Ferreira,Atualizado com sucesso!')]
    [TestCase('B', '2,Priscila Gomes,Atualizado com sucesso!')]
    procedure TestUpdate(const aID, aValue, Result: string);

    [Test]
    [TestCase('A', '1,Excluido com sucesso!')]
    [TestCase('B', '22981817788,Excluido com sucesso!')]
    procedure TestDelete(const aValue, Result: string);
  end;

implementation

uses
  Server.Delivery.Model.Interfaces, Server.Delivery.DTO, System.JSON, REST.Json,
  System.SysUtils;


{ TServerDeliveryClienteTest }

procedure TServerDeliveryClienteTest.GetClientsReturns(aStatus: Integer);
var
  LRes: IHTTPResponse;
begin
  LRes := Client.Get(Path + '/cliente');

  Assert.AreEqual(aStatus, LRes.StatusCode);
end;

procedure TServerDeliveryClienteTest.SaveClient(const aNome, aContato: string; const aStatus: Integer);
var
  LRes: IHTTPResponse;
  aClienteJSON: TJSONObject;
begin
  aClienteJSON := TJSONObject.Create.AddPair('ID', 0).AddPair('NOME', aNome).AddPair('CONTATO', aContato);
  LRes := Client.Post(Path + '/cliente', aClienteJSON.ToJSON);

  Assert.AreEqual(aStatus, LRes.StatusCode);
end;

procedure TServerDeliveryClienteTest.Setup;
begin
  Client := THTTPClient.Create;
  Path := 'http://localhost:9000';
  FController := TControllerServerDelivery.New;
end;

procedure TServerDeliveryClienteTest.TearDown;
begin
  Client.Free;
end;

procedure TServerDeliveryClienteTest.TestDelete(const aValue, Result: string);
var
  aClientes: iModelServerDeliveryCliente<TCLIENTE>;
  aResult: TJSONObject;
begin
  aClientes := FController.CLIENTE;
  aResult := TJSONObject.Create.AddPair('RESULT', Result);

  Assert.AreEqual(aResult.ToJSON, aClientes.Delete(aValue).ToJSON);
end;

procedure TServerDeliveryClienteTest.TestGetCliente;
var
  aClientes: iModelServerDeliveryCliente<TCLIENTE>;
  aResult: TJSONArray;
begin
  aClientes := FController.CLIENTE;
  aResult := aClientes.GetAll;
  Assert.IsTrue(aResult.Count >= 1, 'Get Cliente Count ');
end;

procedure TServerDeliveryClienteTest.TestGetClienteByContato(const aValue, Result: string);
var
  aClientes: iModelServerDeliveryCliente<TCLIENTE>;
begin
  aClientes := FController.CLIENTE;

  Assert.Contains(aClientes.GetByContato(aValue).ToJSON, Result, false);
end;

procedure TServerDeliveryClienteTest.TestGetClienteByID(const aValue, Result: string);
var
  aClientes: iModelServerDeliveryCliente<TCLIENTE>;
begin
  aClientes := FController.CLIENTE;

  Assert.Contains(aClientes.GetByID(StrToInt(aValue)).ToJSON, Result);
end;

procedure TServerDeliveryClienteTest.TestSalvar(const aNome, aContato, Result: string);
var
  aClientes: iModelServerDeliveryCliente<TCLIENTE>;
  aClienteValue: TCLIENTE;
  aResult, aClienteJSON: TJSONObject;
begin
  aClientes := FController.CLIENTE;
  aClienteJSON := TJSONObject.Create.AddPair('ID', 0).AddPair('NOME', aNome).AddPair('CONTATO', aContato);
  aClienteValue := TJSON.JsonToObject<TCLIENTE>(aClienteJSON);
  aResult := TJSONObject.Create.AddPair('RESULT', Result);

  Assert.AreEqual(aResult.ToJSON, aClientes.Save(aClienteValue).ToJSON);
end;

procedure TServerDeliveryClienteTest.TestUpdate(const aID, aValue, Result: string);
var
  aClientes: iModelServerDeliveryCliente<TCLIENTE>;
  aClienteValue: TCLIENTE;
  aResult, aClienteJSON: TJSONObject;
begin
  aClientes := FController.CLIENTE;
  aClienteJSON := TJSONObject.Create.AddPair('ID', aID).AddPair('NOME', aValue);
  aClienteValue := TJSON.JsonToObject<TCLIENTE>(aClienteJSON);
  aResult := TJSONObject.Create.AddPair('RESULT', Result);

  Assert.AreEqual(aResult.ToJSON, aClientes.Update(aClienteValue).ToJSON);
end;

initialization
  TDUnitX.RegisterTestFixture(TServerDeliveryClienteTest);

end.

