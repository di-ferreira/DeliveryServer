unit Controllers.Server.Delivery.Produtos.Test;

interface

uses
  DUnitX.TestFramework, Server.Delivery.Controller,
  Server.Delivery.Controller.Interfaces, Server.Delivery.Model.Interfaces,
  Server.Delivery.DTO;

type
  [TestFixture]
  TServerDeliveryProdutosTest = class
  public
    FController: iControllerServerDelivery;
    [Setup]
    procedure Setup;

    [Test]
    [TestCase('A', 'Coca-cola,100,2.00,150.00')]
    [TestCase('B', 'Pizza,15,20.00,50.00')]
    procedure TestSalvar(const aNome, aEstoque, aCusto, aLucro: string);

    [Test]
    procedure TestGetProduto;

    [Test]
    [TestCase('A', '1,"id":1')]
    [TestCase('B', '2,"id":2')]
    procedure TestGetProdutoByID(const aValue, Result: string);

    [Test]
    [TestCase('A', '1,Fanta Uva,150,3.00,100.00,Atualizado com sucesso!')]
    [TestCase('B', '2,Pizza Calabresa,15,20.00,50.00,Atualizado com sucesso!')]
    procedure TestUpdate(const aID, aNome, aEstoque, aCusto, aLucro, Result: string);

    [Test]
    [TestCase('A', '1,Excluido com sucesso!')]
    [TestCase('B', '22981817788,Excluido com sucesso!')]
    procedure TestDelete(const aValue, Result: string);
  end;

implementation

uses
  System.JSON, REST.Json, System.SysUtils;

{ TServerDeliveryProdutosTest }

procedure TServerDeliveryProdutosTest.Setup;
begin
  FController := TControllerServerDelivery.New;
end;

procedure TServerDeliveryProdutosTest.TestDelete(const aValue, Result: string);
begin

end;

procedure TServerDeliveryProdutosTest.TestGetProduto;
var
  aProdutos: iModelServerDelivery<TPRODUTO>;
  aResult:TJSONArray;
begin
  aProdutos := FController.PRODUTO;
  aResult := aProdutos.GetAll;
  Assert.IsTrue(aResult.Count >= 1, 'Get Produto Count ');
end;

procedure TServerDeliveryProdutosTest.TestGetProdutoByID(const aValue,
  Result: string);
var
  aProduto: iModelServerDelivery<TPRODUTO>;
begin
  aProduto := FController.PRODUTO;

  Assert.Contains(aProduto.GetByID(StrToInt(aValue)).ToJSON, Result, False);
end;

procedure TServerDeliveryProdutosTest.TestSalvar(const aNome, aEstoque, aCusto, aLucro: string);
var
  aProduto: iModelServerDelivery<TPRODUTO>;
  aProdutoValue: TPRODUTO;
  aProdutoJSON: TJSONObject;
begin
  aProduto := FController.PRODUTO;

  aProdutoJSON := TJSONObject.Create
                                .AddPair('ID', 0)
                                .AddPair('NOME', aNome)
                                .AddPair('ESTOQUE', aEstoque)
                                .AddPair('CUSTO', aCusto)
                                .AddPair('PERCENTUAL_LUCRO', aLucro);

  aProdutoValue := TJSON.JsonToObject<TPRODUTO>(aProdutoJSON);

  Assert.Contains(aProduto.Save(aProdutoValue).ToJSON, aNome, false);
end;

procedure TServerDeliveryProdutosTest.TestUpdate(const aID, aNome, aEstoque, aCusto, aLucro,
  Result: string);
var
  aProduto: iModelServerDelivery<TPRODUTO>;
  aProdutoValue: TPRODUTO;
  aResult,aProdutoJSON:TJSONObject;
begin
  aProduto := FController.PRODUTO;
  aProdutoJSON := TJSONObject.Create
                                .AddPair('ID', aID)
                                .AddPair('NOME', aNome)
                                .AddPair('ESTOQUE', aEstoque)
                                .AddPair('CUSTO', aCusto)
                                .AddPair('PERCENTUAL_LUCRO', aLucro);

  aProdutoValue := TJSON.JsonToObject<TPRODUTO>(aProdutoJSON);
  aResult := TJSONObject.Create.AddPair('RESULT', Result);

  Assert.AreEqual(aResult.ToJSON, aProduto.Update(aProdutoValue).ToJSON);
end;

initialization
  TDUnitX.RegisterTestFixture(TServerDeliveryProdutosTest);

end.

