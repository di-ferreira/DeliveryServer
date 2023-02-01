describe('Rotas Pedido', () => {

    let idCaixa: number;
    let idCliente: number;
    let idCliente2: number;
    let idEndereco: number;
    let idEndereco2: number;
    let idTipoPgto: number;
    let idTipoPgto2: number;
    let idProduto:number;
    let idProduto2:number;
    let idProduto3:number;
    let idProduto4:number;
    let idCardapio:number;
    let idCardapio2:number;
    let idCardapio3:number;
    let idPedido:number;
    let idPedido2: number;
    let idItemPedido: number;
    let idItemPedido2: number;
    let idItemPedido3: number;
    let idItemPedido4: number;

    before(() => {
        cy.request({
            method: 'POST',
            url: '/caixas',
            body: {
                "id": 0,
                "total": 0.00,
                "aberto": true
            },
            failOnStatusCode: false
        }).then((Response) => {
            idCaixa = Response.body[1].id;
        });

        cy.request({
            method: 'POST',
            url: '/clientes',
            body: {
                "nome": "Priscila G. Vieira",
                "contato": "55229785634"
            },
            failOnStatusCode: false
        }).then((Response) => {
            idCliente = Response.body[1].id;
        });
        
        cy.request({
            method: 'POST',
            url: '/clientes',
            body: {
                "nome": "Diego Ferreira",
                "contato": "5522988667744"
            },
            failOnStatusCode: false
        }).then((Response) => {
            idCliente2 = Response.body[1].id;
        });
        
        cy.request({
            method: 'POST',
            url: '/clientes/55229785634/enderecos',
            body: {
                "id": 0,
                "cliente": idCliente,
                "rua": "Av. Country Clube dos Engenheiros",
                "numero": "2042",
                "bairro": "Clube dos Engenheiros",
                "complemento": "Casa 120",
                "cidade": "Araruama",
                "estado": "RJ"
            },
            failOnStatusCode: false
        }).then((Response) => {
            idEndereco = Response.body[1].id;
        });
        
        cy.request({
            method: 'POST',
            url: '/clientes/55229785634/enderecos',
            body: {
                "id": idCliente2,
                "rua": "rua Érica Reis",
                "numero": "35",
                "bairro": "Outeiro",
                "complemento": "Casa 4",
                "cidade": "Belford Roxo",
                "estado": "RJ"
            },
            failOnStatusCode: false
        }).then((Response) => {
            idEndereco2 = Response.body[1].id;
        });
        
        cy.request({
            method: 'POST',
            url: '/tipo-pagamento',
            body: {
                "id": 0,
                "descricao": "dinheiro",
            },
            failOnStatusCode: false
        }).then((Response) => {
            idTipoPgto = Response.body[1].id;
        });
        
        cy.request({
            method: 'POST',
            url: '/tipo-pagamento',
            body: {
                "id": 0,
                "descricao": "débito",
            },
            failOnStatusCode: false
        }).then((Response) => {
            idTipoPgto2 = Response.body[1].id;
        });
        
        cy.request({
            method: 'POST',
            url: '/cardapios',
            body: {
                "id": 0,
                "preco": 0.00,
                "descricao": "x-tudo",
                "produto": [
                    {
                        "id": 0,
                        "nome": "x-tudo",
                        "custo": 10.00,
                        "percentual_lucro": 50.00,
                        "estoque": 50,
                    }
                ],
            },
            failOnStatusCode: false
        }).then((Response) => {
            idCardapio = Response.body[1].id;
            idProduto = Response.body[1].produto.id;
        });
        
        cy.request({
            method: 'POST',
            url: '/cardapios',
            body: {
                "id": 0,
                "preco": 20.00,
                "descricao": "combo hot-dog",
                "produto": [
                    {
                        "id": 0,
                        "nome": "hot-dog",
                        "custo": 5.00,
                        "percentual_lucro": 50.00,
                        "estoque": 50,
                    },
                    {
                        "id": 0,
                        "nome": "coca-cola",
                        "custo": 7.00,
                        "percentual_lucro": 25.00,
                        "estoque": 20,
                    }
                ],
            },
            failOnStatusCode: false
        }).then((Response) => {
            idCardapio2 = Response.body[1].id;
            idProduto2 = Response.body[1].produto[0].id;
            idProduto3 = Response.body[1].produto[1].id;
        });
    });

    it('Criar Pedido - completo', () => {
        cy.request({
            method: 'POST',
            url: '/pedidos',
            body: {
                "id": 0,
                "total": 0.00,
                "aberto": true,
                "cancelado": false,
                "obs":"",
                "cliente": {
                    "id":idCliente,
                    "nome": "Priscila G. Vieira",
                    "contato": "55229785634"
                },
                "endereco_entrega":
                {
                    "id": idEndereco,
                    "cliente": idCliente,
                    "rua": "Av. Country Clube dos Engenheiros",
                    "numero": "2042",
                    "bairro": "Clube dos Engenheiros",
                    "complemento": "Casa 120",
                    "cidade": "Araruama",
                    "estado": "RJ"
                },
                "tipo_pagamento": {
                    "id": idTipoPgto,
                    "descricao":"dinheiro"
                },
                "caixa": {
                    "id": idCaixa,
                    "total": 0.00,
                    "aberto": true
                },
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Pedido adicionado com sucesso!');
            expect(Response.body[1].cliente.id).to.equal(idCliente);
            expect(Response.body[1].endereco_entrega.id).to.equal(idEndereco);
            expect(Response.body[1].tipo_pagamento.id).to.equal(idTipoPgto);
            expect(Response.body[1].caixa.id).to.equal(idCaixa);
            idPedido = Response.body[1].id;
        });
    });

    it('Criar Item em Pedido 01', () => {
       cy.request({
            method: 'POST',
            url: `/pedidos/${idPedido}/items`,
            body: {
                "id": 0,
                "item_cardapio":idCardapio,
                "pedido": idPedido,
                "quantidade": 2,
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Item adicionado com sucesso!');
            expect(Response.body[1].total.id).to.equal(Response.body[1].item_cardapio.total*Response.body[1].quantidade);
            idItemPedido = Response.body[1].id;
        }); 
    });

    it('Criar Item2 em Pedido 01', () => {
       cy.request({
            method: 'POST',
            url: `/pedidos/${idPedido}/items`,
            body: {
                "id": 0,
                "item_cardapio":idCardapio2,
                "pedido": idPedido,
                "quantidade": 3,
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Item adicionado com sucesso!');
            expect(Response.body[1].total.id).to.equal(Response.body[1].item_cardapio.total*Response.body[1].quantidade);
            idItemPedido2 = Response.body[1].id;
        }); 
    });

    it('Criar Pedido - 02', () => {
        cy.request({
            method: 'POST',
            url: '/pedidos',
            body: {
                "id": 0,
                "total": 0.00,
                "aberto":true,
                "cancelado": false,
                "obs":"",
                "cliente": idCliente2,
                "endereco_entrega": idEndereco2,
                "tipo_pagamento":  idTipoPgto2,
                "caixa": idCaixa,
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Pedido adicionado com sucesso!');
            expect(Response.body[1].cliente.id).to.equal(idCliente2);
            expect(Response.body[1].endereco_entrega.id).to.equal(idEndereco2);
            expect(Response.body[1].tipo_pagamento.id).to.equal(idTipoPgto2);
            expect(Response.body[1].caixa.id).to.equal(idCaixa);
            idPedido2 = Response.body[1].id;
        });
    });

    it('Criar Item em Pedido 02', () => {
       cy.request({
            method: 'POST',
            url: `/pedidos/${idPedido2}/items`,
            body: {
                "id": 0,
                "item_cardapio":idCardapio,
                "pedido": idPedido2,
                "quantidade": 3,
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Item adicionado com sucesso!');
            expect(Response.body[1].total.id).to.equal(Response.body[1].item_cardapio.total*Response.body[1].quantidade);
            idItemPedido3 = Response.body[1].id;
        }); 
    });

    it('Criar Item2 em Pedido 02', () => {
       cy.request({
            method: 'POST',
            url: `/pedidos/${idPedido2}/items`,
            body: {
                "id": 0,
                "item_cardapio":idCardapio2,
                "pedido": idPedido2,
                "quantidade": 5,
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Item adicionado com sucesso!');
            expect(Response.body[1].total.id).to.equal(Response.body[1].item_cardapio.total*Response.body[1].quantidade);
            idItemPedido4 = Response.body[1].id;
        }); 
    });

    it('Buscar pedidos por caixa', () => {
        cy.request(`/caixa/${idCaixa}/pedidos`)
            .then((Response) => {
                expect(Response.status).to.equal(200);
                Response.body.forEach((pedido:any) => {
                    expect(pedido.caixa.id).to.equal(idCaixa);                    
                });
            });
    });
    
    it('Buscar pedidos cancelados', () => {
        cy.request(`/caixa/${idCaixa}/pedidos`)
            .then((Response) => {
                expect(Response.status).to.equal(200);
                Response.body.forEach((pedido:any) => {
                    expect(pedido.caixa.id).to.equal(idCaixa);                    
                    expect(pedido.aberto).to.equal(false);
                    expect(pedido.cancelado).to.equal(true);
                });
            });
    });
    
    it('Buscar pedidos abertos', () => {
        cy.request(`/caixa/${idCaixa}/pedidos`)
            .then((Response) => {
                expect(Response.status).to.equal(200);
                Response.body.forEach((pedido: any) => {
                    expect(pedido.caixa.id).to.equal(idCaixa);                   
                    expect(pedido.aberto).to.equal(true);
                    expect(pedido.cancelado).to.equal(false);                    
                });
            });
    });

    it('Buscar pedido por id 1', () => {
        cy.request(`/pedido/${idPedido}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(idPedido);
        });
    });

    it('Buscar pedido por id 2', () => {
        cy.request(`/pedido/${idPedido2}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(idPedido2);
        });
    });

    it('Update pedido cancelado', () => {
        cy.request({
            method: 'PUT',
            url: `/caixa/${idCaixa}/pedidos/${idPedido}`,
            body: {
                "id": idPedido,
                "cancelado": true,
                "obs":"Por que eu quis"
            }
        }).then(Response => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].message).to.equal('Pedido cancelado!');
            expect(Response.body[1].cancelado).to.equal(true);
            expect(Response.body[1].aberto).to.equal(false);
        });
    });

    it('Update pedido fechar conta', () => {
        cy.request({
            method: 'PUT',
            url: `/caixa/${idCaixa}/pedidos/${idPedido2}`,
            body: {
                "id": idPedido2,
                "total": 0.00,
                "aberto":true,
                "cancelado": false,
                "obs":"",
                "cliente": idCliente2,
                "endereco_entrega": idEndereco2,
                "tipo_pagamento":  idTipoPgto2,
                "caixa": idCaixa,
            }
        }).then(Response => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].message).to.equal('Pedido fechado!');
            expect(Response.body[1].cancelado).to.equal(false);
            expect(Response.body[1].aberto).to.equal(true);
        });
    });

    after(() => {
        cy.request({
            method: 'DELETE',
            url: `/clientes/${idCliente}`,
            failOnStatusCode: false
        });

        cy.request({
            method: 'DELETE',
            url: `/clientes/${idCliente2}`,
            failOnStatusCode: false
        });
    });

});